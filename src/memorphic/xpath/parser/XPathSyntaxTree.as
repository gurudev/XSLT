/*
	Copyright (c) 2007 Memorphic Ltd. All rights reserved.
	
	Redistribution and use in source and binary forms, with or without 
	modification, are permitted provided that the following conditions 
	are met:
	
		* Redistributions of source code must retain the above copyright 
		notice, this list of conditions and the following disclaimer.
	    	
	    * Redistributions in binary form must reproduce the above 
	    copyright notice, this list of conditions and the following 
	    disclaimer in the documentation and/or other materials provided 
	    with the distribution.
	    	
	    * Neither the name of MEMORPHIC LTD nor the names of its 
	    contributors may be used to endorse or promote products derived 
	    from this software without specific prior written permission.
	
	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
	"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
	LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
	A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT 
	OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
	SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
	LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
	DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY 
	THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
	OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

package memorphic.xpath.parser
{
	import flash.errors.EOFError;
	
	import memorphic.parser.ParseError;
	import memorphic.parser.SyntaxTree;
	import memorphic.parser.SyntaxTreeItem;
	import memorphic.parser.SyntaxTreeState;
	import memorphic.parser.Token;
	import memorphic.parser.Tokenizer;
	import memorphic.parser.TokenizerState;

	/**
	 * NOTE: All methods in the "rule" namespace are XPath lexical and grammar rules taken from
	 * W3C XPath 1.0 Recommendation at http://www.w3.org/TR/xpath
	 * or from the W3C XML Namespaces 1.0 recommendation http://www.w3.org/TR/REC-xml-names/
	 * 
	 * The appropriate specification snippets are shown above each method
	 *
	 * TODO: some optimizations:
	 * 	- where logic is unaffected, re-order the tests to check most common (or quickest) matches first
	 */
	final public class XPathSyntaxTree extends SyntaxTree
	{
		
		public namespace rule = "http://memorphic.com/ns/2007/xpath-grammar";
		use namespace rule;
		
		// XPath tokens
		public static const LOCATION_PATH:String = "LocationPath";
		public static const ABSOLUTE_LOCATION_PATH:String = "AbsoluteLocationPath";
		public static const RELATIVE_LOCATION_PATH:String = "RelativeLocationPath";
		public static const STEP:String = "Step";
		public static const AXIS_SPECIFIER:String = "AxisSpecifier";
		public static const NODE_TEST:String = "NodeTest";
		public static const PREDICATE:String = "Predicate";
		public static const PREDICATE_EXPR:String = "PredicateExpr";
		public static const ABBREVIATED_ABSOLUTE_LOCATION_PATH:String = "AbbreviatedAbsoluteLocationPath";
		public static const ABBREVIATED_RELATIVE_LOCATION_PATH:String = "AbbreviatedRelativeLocationPath";
		public static const ABBREVIATED_STEP:String = "AbbreviatedStep";
		public static const ABBREVIATED_AXIS_SPECIFIER:String = "AbbreviatedAxisSpecifier";
		public static const EXPR:String = "Expr";
		public static const PRIMARY_EXPR:String = "PrimaryExpr";
		public static const FUNCTION_CALL:String = "FunctionCall";
		public static const ARGUMENT:String = "Argument";
		public static const UNION_EXPR:String = "UnionExpr";
		public static const PATH_EXPR:String = "PathExpr";
		public static const FILTER_EXPR:String = "FilterExpr";
		public static const OR_EXPR:String = "OrExpr";
		public static const AND_EXPR:String = "AndExpr";
		public static const EQUALITY_EXP:String = "EqualityExpr";
		public static const RELATIONAL_EXP:String = "RelationalExpr";
		public static const ADDITIVE_EXPR:String = "AdditiveExpr";
		public static const MULTIPLICATIVE_EXPR:String = "MultiplicativeExpr";
		public static const UNARY_EXPR:String = "UnaryExpr";
		
		public static const QNAME:String = "QName";
		public static const NAME_TEST:String = "NameTest";
		
		
		

		public function XPathSyntaxTree(tokenizer:XPathTokenizer){
			super(tokenizer);
		}

		
		public override function getTree():SyntaxTreeItem
		{
			Expr();
			return super.getTree();
		}
		
		
		
		/**
		 * [1] LocationPath ::=
		 * 			RelativeLocationPath
		 * 			| AbsoluteLocationPath
		 */
		rule function LocationPath():Boolean
		{
			startRule(LOCATION_PATH);
			if(RelativeLocationPath() || AbsoluteLocationPath()){
				return match();
			}
			return didntMatch();
		}
		
		


		/**
		 * [2] AbsoluteLocationPath ::=
		 * 			'/' RelativeLocationPath?
		 * 			| AbbreviatedAbsoluteLocationPath
		 */
		rule function AbsoluteLocationPath():Boolean
		{
			startRule(ABSOLUTE_LOCATION_PATH);
			var state:SyntaxTreeState = getState();
			try{
				if(nextToken().value == "/"){
					discardToken();
					RelativeLocationPath();
					return match();
				}
			}catch(e:EOFError){
				// carry on
			}
			restoreState(state);
			if(AbbreviatedAbsoluteLocationPath()){
				return match();
			}
			return didntMatch();
		}
		
		
		

		/**
		 * [3]  RelativeLocationPath ::=
		 *    		Step
		 * 			| RelativeLocationPath '/' Step
		 * 			| AbbreviatedRelativeLocationPath
		 * 
		 * 
		 * which is equivalent to :
		 *    		(Step | AbbreviatedRelativeLocationPath) ('/' Step)*
		 * 
		 * which is equivalent to:
		 *    		Step (('/' | '//') Step)*
		 * 
		 * 
		 * Some unpleasantness was required to make sure that "/" is discarded, but "//" is left intact
		 * so that it can be expanded later (to /descendent-or-self::node()/)
		 */
		rule function RelativeLocationPath():Boolean
		{
			startRule(RELATIVE_LOCATION_PATH);
			if(!Step()){
				return didntMatch();
			}
			var state:SyntaxTreeState;
			while(true){
				state = getState();
				try{
					nextToken();
				}catch(e:EOFError){
					break;
				}
				if(token.value == "/"){
					discardToken();
					if(Step()){
						continue;
					}
				}else if(token.value == "//" && Step()){
					continue;
				}
				break;
				
			}
			restoreState(state);
			return match();
		}



		/**
		 * [4] Step ::=
		 * 			AxisSpecifier NodeTest Predicate*
		 * 			| AbbreviatedStep
		 */
		rule function Step():Boolean
		{
			startRule(STEP);
			if(AxisSpecifier()){
				if(NodeTest()){
					while(true){
						if(!Predicate()){
							break;
						}
					}
					return match();
				}
			}
			restartRule();
			if(AbbreviatedStep()){
				return match();
			}
			return didntMatch();
		}



		/**
		 * [5] AxisSpecifier ::=
		 * 			AxisName '::'
		 * 			| AbbreviatedAxisSpecifier
		 */
		rule function AxisSpecifier():Boolean
		{
			startRule(AXIS_SPECIFIER);
			var axisNameToken:Token;
			//var state:SyntaxTreeState = getState();
			try {
				if(nextToken().tokenType == XPathToken.AXIS_NAME){
					axisNameToken = token;
					if(nextToken().value == "::"){
						discardToken();
						return match();
					}else{
						throw new SyntaxError("Found Axis name '" + axisNameToken.value + "' without '::'. If '"+axisNameToken.value+"'" + 
								"is meant to be an XML node name, it's a reserved word, and perhaps you meant to use '/child::"+axisNameToken.value+"'");
					}
				}
			}catch(e:EOFError){
				// carry on
			}
			//restoreState(state);
			restartRule();
			if(AbbreviatedAxisSpecifier()){
				return match();
			}
			return didntMatch();
		}






		/**
		 * [7] NodeTest ::=
		 * 			NameTest
		 * 			| NodeType '(' ')'
		 * 			| 'processing-instruction' '(' Literal ')'
		 */
		rule function NodeTest():Boolean
		{
			startRule(NODE_TEST);
			try{
				nextToken();
				if(token.tokenType == XPathToken.NAME_TEST){
					return match();
				}
				if(token.tokenType == XPathToken.NODE_TYPE){
					if(nextToken().value == "("){
						discardToken();
						if(token.value == "processing-instruction"){
							// processing-instruction requires a literal argument
							if(nextToken().tokenType != XPathToken.LITERAL){
								return didntMatch();
							}
						}
						if(nextToken().value == ")"){
							discardToken();
							return match();
						}
					}
				}
				
			}catch(e:EOFError){
				// didn't match - carry on
			}
			return didntMatch();
		}




		/**
		 * [8] Predicate ::=
		 * 			'[' PredicateExpr ']'
		 */
		rule function Predicate():Boolean
		{
			startRule(PREDICATE);
			try{
				if(nextToken().value == "["){
					discardToken();
					if(PredicateExpr()){
						if(nextToken().value == "]"){
							discardToken();
							return match();
						}
					}

				}
				
			}catch(e:EOFError){
				// continue - didn't match
		 	}
			return didntMatch();
		}




		/**
		 * [9] PredicateExpr ::=
		 * 			Expr
		 */
		rule function PredicateExpr():Boolean
		{
			startRule(PREDICATE_EXPR);
			if(Expr()){
				return match();
			}
			return didntMatch();
		}



		/**
		 * [10] AbbreviatedAbsoluteLocationPath ::=
		 * 			'//' RelativeLocationPath
		 */
		rule function AbbreviatedAbsoluteLocationPath():Boolean
		{
			startRule(ABBREVIATED_ABSOLUTE_LOCATION_PATH);
			try{
				if(nextToken().value == "//"){
					// discardToken();
					if(RelativeLocationPath()){
						return match();
					}
				}
			}catch(e:EOFError){
				// carry on - didn't match
			}
			return didntMatch();
		}


		/**
		 * [11] AbbreviatedRelativeLocationPath	::=
		 * 			RelativeLocationPath '//' Step
		 */
		rule function AbbreviatedRelativeLocationPath():Boolean
		{
			startRule(ABBREVIATED_RELATIVE_LOCATION_PATH);
			try{
				if(RelativeLocationPath()){
					if(nextToken().value == "//"){
						if(Step()){
							return match();
						}
					}
				}
			}catch(e:EOFError){
				// carry on - didn't match
			}
			return didntMatch();
		}


		/**
		 * [12] AbbreviatedStep ::=
		 * 		   	'.'
		 * 			| '..'
		 */
		rule function AbbreviatedStep():Boolean
		{
			startRule(ABBREVIATED_STEP);
			try {
				nextToken();
				if(token.value == "." || token.value == ".."){
					return match();
				}
			}catch(e:EOFError){
				// carry on...
			}
			return didntMatch();
		}


		/**
		 * [13] AbbreviatedAxisSpecifier ::=
		 * 		   	'@'?
		 * 
		 */
		rule function AbbreviatedAxisSpecifier():Boolean
		{
			startRule(ABBREVIATED_AXIS_SPECIFIER);
			try {
				if(nextToken().value != "@"){
					restartRule();
				}
			}catch(e:EOFError){
				// carry on
			}
			return match();
		}



		/**
		 * [14] Expr ::=
		 * 			OrExpr
		 * 
		 */
		rule function Expr():Boolean
		{
			startRule(EXPR);
			if(OrExpr()){
				return match();
			}
			return didntMatch();
		}



		/**
		 * [15] PrimaryExpr ::=
		 * 			VariableReference
		 * 			| '(' Expr ')'
		 * 			| Literal
		 * 			| Number
		 * 			| FunctionCall
		 */
		rule function PrimaryExpr():Boolean
		{
			startRule(PRIMARY_EXPR);
			
			// changed the order to prevent the need for an extra state reset
			if(FunctionCall()){
				return match();
			}
			
			try {
				nextToken();
				if(token.tokenType == XPathToken.VARIABLE_REFERENCE){
					return match();
				}
			}catch(e:EOFError){
				return didntMatch();
			}
			if(token.value == "("){
				discardToken();
				try {
					if(Expr() && nextToken().value == ")"){
						discardToken();
						return match();
					}
				}catch(e:EOFError){
					// ran out of tokens so didn't match
				}
				return didntMatch();
				
			}else if(token.tokenType == XPathToken.LITERAL
				|| token.tokenType == XPathToken.NUMBER){
				return match();
			}
			return didntMatch();
		}



		/**
		 * [16] FunctionCall ::=
		 * 			FunctionName '(' ( Argument ( ',' Argument )* )? ')'
		 * 
		 */
		rule function FunctionCall():Boolean
		{
			startRule(FUNCTION_CALL);
			try {
				if(nextToken().tokenType == XPathToken.FUNCTION_NAME){
					if(nextToken().value == "("){
						discardToken();
						if(Argument()){
							while(true){
								// this does not need it's own try/catch because an
								// eof here also means there cannot be a matching ")"
								nextToken();
								if(token.value == ","){
									discardToken();
									if(!Argument()){
										throw new SyntaxError("Missing argument after ','.");
									}
								}else{
									break;
								}
							}
						}else{
							nextToken();
						}
						if(token.value == ")"){
							discardToken();
							return match();
						}else{
							throw new SyntaxError("Expected ')'.");
						}
					}
				}
			}catch(e:EOFError){
				// didn't match
			}
			return didntMatch();
		}



		/**
		 * [17] Argument ::=
		 * 			Expr
		 */
		rule function Argument():Boolean
		{
			startRule(ARGUMENT);
			if(Expr()){
				return match();
			}
			return didntMatch();
		}


		/**
		 * [18] UnionExpr ::=
		 * 			PathExpr
		 * 			| UnionExpr '|' PathExpr
		 * 
		 * which is equivalent to:
		 * 		PathExpr ('|' PathExpr)*
		 */
		rule function UnionExpr():Boolean
		{
			startRule(UNION_EXPR);
			var state:SyntaxTreeState;
			if(!PathExpr()){
				return didntMatch();
			}
			try {
				while(true){
					state = getState();
					if(nextToken().value == "|" && PathExpr()){
					}else{
						break;
					}
				}
			}catch(e:EOFError){
				// no more "|", but it still matches
			}
			restoreState(state);
			return match();
		}


		/**
		 * [19] PathExpr ::=
		 * 			LocationPath
		 * 			| FilterExpr
		 * 			| FilterExpr '/' RelativeLocationPath
		 * 			| FilterExpr '//' RelativeLocationPath
		 * 
		 * which is equivalent to:
		 * 			LocationPath
		 * 			| FilterExpr ( ('/' | '//' ) RelativeLocationPath )?
		 * 
		 */
		rule function PathExpr():Boolean
		{
			startRule(PATH_EXPR);
			if(LocationPath()){
				return match();
			}
			if(!FilterExpr()){
				return didntMatch();
			}
			var state:SyntaxTreeState = getState();
			try{
				nextToken();
				switch(token.value){
				case "/":
					discardToken();
				case "//":
					if(RelativeLocationPath()){
						return match();
					}
				}
			}catch(e:EOFError){
				// carry on
			}
			
			restoreState(state);
			return match();
			
		}



		/**
		 * [20] FilterExpr ::=
		 * 				PrimaryExpr
		 * 				| FilterExpr Predicate
		 * 
		 * which is equivalent to:
		 * 		PrimaryExpr Predicate*
		 */
		rule function FilterExpr():Boolean
		{
			startRule(FILTER_EXPR);
			if(PrimaryExpr()){
			}else{
				return didntMatch();
			}
			while(true){
				if(!Predicate()){
					break;
				}
			}
			return match();
		}



		/**
		 * [21] OrExpr ::=
		 * 			AndExpr
		 * 			| OrExpr 'or' AndExpr
		 * 
		 * which is (almost) equivalent to:
		 * 			AndExpr ( 'or' AndExpr )*
		 * 
		 * ...at the loss of associativity enforcement. 
		 * Associativity is left-right and is enforced in the parser now.
		 */
		rule function OrExpr():Boolean
		{
			startRule(OR_EXPR);
			if(!AndExpr()){
				return didntMatch();
			}
			var state:SyntaxTreeState;
			try{
				while(true){
					state = getState();
					if(nextToken().value == "or"){
						if(!AndExpr()){
							break;
						}
					}else{
						break;
					}
				}
			}catch(e:EOFError){
				// carry on
			}
			restoreState(state);
			return match();
		}



		/**
		 * [22] AndExpr ::=
		 * 			EqualityExpr
		 * 			| AndExpr 'and' EqualityExpr
		 * 
		 * which is equivalent to:
		 * 			EqualityExpr ( 'and' EqualityExpr )*
		 * 
		 * ...at the loss of associativity enforcement. 
		 * Associativity is left-right and is enforced in the parser now.
		 */
		rule function AndExpr():Boolean
		{
			startRule(AND_EXPR);
			if(!EqualityExpr()){
				return didntMatch();
			}
			var state:SyntaxTreeState;
			try{
				while(true){
					state = getState();
					if(nextToken().value == "and" && EqualityExpr() ){
					}else{
						break;
					}
				}
			}catch(e:EOFError){
				// carry on
			}
			restoreState(state);
			return match();
		}


		/**
		 * [23] EqualityExpr ::=
		 * 			RelationalExpr
		 * 			| EqualityExpr '=' RelationalExpr
		 * 			| EqualityExpr '!=' RelationalExpr
		 * 
		 * which is equivalent to:
		 * 			RelationalExpr ( ( '=' | '!=' ) RelationalExpr )*
		 * 
		 * ...at the loss of associativity enforcement. 
		 * Associativity is left-right and is enforced in the parser now.
		 */
		rule function EqualityExpr():Boolean
		{
			startRule(EQUALITY_EXP);
			if(RelationalExpr()){
			}else{
				return didntMatch();
			}
			var state:SyntaxTreeState;
			try {
				while(true){
					state = getState();
					nextToken();
					if( (token.value == "=" || token.value == "!=") 
						&& RelationalExpr()){
						//
					}else{
						break;
					}
				}
			}catch(e:EOFError){
				// carry on
			}
			restoreState(state);
			return match();
		}



		/**
		 * [24] RelationalExpr ::=
		 * 			AdditiveExpr
		 * 			| RelationalExpr '<' AdditiveExpr
		 * 			| RelationalExpr '>' AdditiveExpr
		 * 			| RelationalExpr '<=' AdditiveExpr
		 * 			| RelationalExpr '>=' AdditiveExpr
		 * 
		 * which is equivalent to:
		 * 			AdditiveExpr ( ( '<' | '>' | '<=' | '>=') AdditiveExpr)*
		 * 
		 * 
		 * ...at the loss of associativity enforcement. 
		 * Associativity is left-right and is enforced in the parser now.
		 */
		rule function RelationalExpr():Boolean
		{
			startRule(RELATIONAL_EXP);
			if(!AdditiveExpr()){
				return didntMatch();
			}
			var state:SyntaxTreeState;
			try{
				expr: while(true){
					state = getState();
					nextToken();
					var val:String = token.value;
		//			sub: switch(val){
		//				case "<": case ">": case "<=": case ">=":
		//				if(AdditiveExpr()){
		//					continue;
		//				}
		//				default:
		//				break expr;
		//			}
					
					if( (token.value == "<" || token.value == ">" || token.value == "<=" || token.value == ">=") 
						&& AdditiveExpr())
					{
					}else{
						break expr;
					}
				}
			}catch(e:EOFError){
				// carry on
			}
			restoreState(state);
			return match();
		} 



		/**
		 * [25] AdditiveExpr ::=
		 *    		MultiplicativeExpr
		 * 			| AdditiveExpr '+' MultiplicativeExpr
		 * 			| AdditiveExpr '-' MultiplicativeExpr
		 * 
		 * which is equivalent to:
		 * 			MultiplicativeExpr ( ('+' | '-') MultiplicativeExpr)*
		 */
		rule function AdditiveExpr():Boolean
		{
			startRule(ADDITIVE_EXPR);
			if(!MultiplicativeExpr()){
				return didntMatch();
			}
			var state:SyntaxTreeState;
			try{
				while(true){
					state = getState();
					nextToken();
					if( (token.value == "+" || token.value == "-") 
						&& MultiplicativeExpr()){
						//
					}else{
						break;
					}
				}
			}catch(e:EOFError){
				// carry on
			}
			restoreState(state);
			return match();
		}



		/**
		 * [26] MultiplicativeExpr ::=
		 * 			UnaryExpr
		 * 			| MultiplicativeExpr MultiplyOperator UnaryExpr
		 * 			| MultiplicativeExpr 'div' UnaryExpr
		 * 			| MultiplicativeExpr 'mod' UnaryExpr
		 * 
		 * which is equivalent to:
		 * 			UnaryExpr ((MultiplyOperator | 'div' | 'mod') UnaryExpr)*
		 * 
		 * ...at the loss of associativity enforcement. 
		 * Associativity is left-right and is enforced in the parser now.
		 */
		rule function MultiplicativeExpr():Boolean
		{
			startRule(MULTIPLICATIVE_EXPR);
			if(!UnaryExpr()){
				return didntMatch();
			}
			var state:SyntaxTreeState;
			try {
				while(true){
					state = getState();
					nextToken();
					if(((/*token.tokenType == XPathToken.OPERATOR && */token.value == "*")
						|| token.value == "div"
						|| token.value == "mod" )
							&& UnaryExpr())
					{		
					//	carry on and maybe match more
					}else{
						break;
					}
				}
			}catch(e:EOFError){
				// carry on
			}
			restoreState(state);
			return match();
		}



		/**
		 * [27] UnaryExpr ::=
		 * 			UnionExpr
		 * 			| '-' UnaryExpr
		 * 
		 * which is equivalent to:
		 * 			UnionExpr | '-' UnionExpr
		 * 
		 * XXX: I am slightly not sure about this simplification - something feels dodgy...
		 */
		rule function UnaryExpr():Boolean
		{
			startRule(UNARY_EXPR);
			if(UnionExpr()){
				return match();
			}
			try{
				if(nextToken().value == "-"){
					if(UnionExpr()){
					//	condenseToken();
						return match();
					}
				}
			}catch(e:EOFError){
				// didn't match so continue...
			}
			return didntMatch();
		}

		/**
		 * [37] NameTest ::=
		 *			'*'
		 *			| NCName ':' '*'
		 *			| QName
		 *	 
		 *	@see #createToken() 	 
		 */			
	/*	rule function NameTest():Boolean
		{
			startRule(NAME_TEST);
			if(QName()){
				return match();
			}else{
				try {
					nextToken();
					if(token.value == "*"){
						return match();
					}else if(token.tokenType == XPathToken.NCNAME){
						if(nextToken().value == ":"){
							discardToken();
							if(nextToken().value == "*"){
								return match();
							}
						}
					}
				}catch(e:EOFError){
					// continue and don't match
				}
			}
			
			return didntMatch();
		}*/
		
		
		/**
		 * From my understanding...
		 * 
		 * 		QName ::= 
		 * 			NCName ':' NCName
		 * 			| NCName
		 */ 
/*		rule function QName():Boolean
		{
			startRule(QNAME);
			try {
				if(nextToken().tokenType != XPathToken.NCNAME){
					return didntMatch();
				}
			}catch(e:EOFError){
				return didntMatch();
			}
			try {
				var state:SyntaxTreeState = getState();
				if(nextToken().value == ":"){
					discardToken();
					if(nextToken().tokenType == XPathToken.NCNAME){
						return match();
					}else{
						throw new SyntaxError("Expected local-name after ':'.")
					}
				}
			}catch(e:EOFError){
				// didn't match
			}
			restoreState(state);
			return match();
		}
		*/
		
		
		/**
		 * 
		 */
		protected override function ruleMatched(item:SyntaxTreeItem):void
		{
		}
		


	}
}