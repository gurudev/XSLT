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
	
	import memorphic.parser.ParseError;
	import memorphic.parser.Token;
	import memorphic.parser.TokenMetrics;
	import memorphic.parser.TokenPattern;
	import memorphic.parser.Tokenizer;
	import memorphic.xpath.model.AxisNames;
	import memorphic.xpath.model.NodeTypes;
	import memorphic.xpath.model.Operators;

	/**
	 * W3C XPath 1.0 Recommendation at http://www.w3.org/TR/xpath
	 *
	 * The Tokenizer is responsible for breaking up the rawData input stream into tokens and identifying
	 * their types.
	 */
	final public class XPathTokenizer extends Tokenizer
	{

		namespace pattern;
		use namespace pattern;

		private var lastMatchType:String;

		// XML types
		// see:
		//	 - http://www.w3.org/TR/REC-xml
		//	 - http://www.w3.org/TR/REC-xml-names
		// N.B. NCName is implemented using easiest solution that seems to work, as opposed to precise
		// specification. So checking is required for unicode support etc

		pattern static const NCName:String = "(?:_|[^\\d\\s\\W])[\\w_\\-]*";
		
		// QName
		// The ":" character delimits the prefix and localName parts
		
		pattern static const _QName_delimiter:String = "\\:";
		
		
		// XPath Types
		// (see http://www.w3.org/TR/xpath)


	
		/**
			[39] ExprWhitespace	::=
					S
		*/
		pattern static const ExprWhitespace:String = "\\s+";
			

		/**
			[38] NodeType ::=
					'comment'
					| 'text'
					| 'processing-instruction'
					| 'node'
			
		  	This is now matched in resolveNCName()
		  	@see NodeTypes#isNodeType
		*/
//		pattern static const NodeType:String = 
//			buildRegExpORList2(NodeTypes.COMMENT, NodeTypes.TEXT, NodeTypes.PROCESSING_INSTRUCTION, NodeTypes.NODE);

		
		/**
			[37] NameTest ::=
					'*'
					| NCName ':' '*'
					| QName
			 
			@see XPathSyntaxTree	 
		*/	
			
		
		/**
			[36] VariableReference ::=
					'$' QName
			 
			VariableReference is now moved to grammar tree. Just detect the $ in the tokenizer.,
			 
			@see #createToken() 	 
		*/
		


		/**
			[35] FunctionName ::=
					QName - NodeType
		*/
		private static function isFunctionName(type:String, value:String):Boolean
		{
			return (type == XPathToken.NCNAME && !NodeTypes.isNodeType(value));
		}


		/**
			[34] MultiplyOperator ::=
					'*'
		*/
		pattern static const MultiplyOperator:String = "\\*";

		/**
			[33] OperatorName ::=
					'and' | 'or' | 'mod' | 'div'
		*/
		pattern static const OperatorName:String = "and | or | mod | div";

		/**
			[32 Operator ::=
					OperatorName
					| MultiplyOperator
					| '/' | '//' | '|' | '+' | '-' | '=' | '!=' | '<' | '<=' | '>' | '>='
			 
			Note: //,/ <, <= and >= are in size order, to ensure largest match (TODO: find out why this is necessary)		
		*/
		pattern static const Operator:String = MultiplyOperator + "|" + buildRegExpORList("// / | + - = != <= >= < >");

		/**
			[31] Digits ::=
					[0-9]+
		*/
		pattern static const Digits:String = "\\d+";

		/**
			[30] Number	::=
					Digits ('.' Digits?)?
					| '.' Digits
		*/
		pattern static const Num:String = Digits + " (?:\\. " + Digits + ")? | \\. " + Digits;
		//Digits + " (\\. " + Digits + "?)? | \\. " + Digits;

		/**
			[29] Literal ::=
					'"' [^"]* '"'
					| "'" [^']* "'"
		*/
		pattern static const Literal:String = "\\\" [^\\\"]* \\\"  | \\\' [^\\\']* \\\'";

				
		/**
			[28] ExprToken ::=
				'(' | ')' | '[' | ']' | '.' | '..' | '@' | ',' | '::'
				| NodeType
				| NameTest
				| Operator
				| FunctionName
				| AxisName
				| Literal
				| Number
				| VariableReference
			
			 @see #isExprToken
			
			Note: ".." comes before "." to ensure that biggest is matched.
			 
		*/
		pattern static const ExprToken_misc:String = buildRegExpORList("$ ( ) [ ] .. . @ , ::");
													
		

		/**
			[6] AxisName	::=
		 			'ancestor'
		  			| 'ancestor-or-self'
		  			| 'attribute'
		  			| 'child'
		  			| 'descendant'
		  			| 'descendant-or-self'
		  			| 'following'
		  			| 'following-sibling'
		  			| 'namespace'
		  			| 'parent'
		  			| 'preceding'
		  			| 'preceding-sibling'
		  			| 'self'
		  			  
		  	This is now matched in resolveNCName()
		  	@see resolveNCName
		  	@see AxisNames#isAxisName
		*/
//		pattern static const AxisName:String = "ancestor\\-or\\-self | ancestor | attribute | child" +
//				"| descendant\\-or\\-self | descendant | following\\-sibling | following | namespace" +
//				"| parent | preceding\\-sibling | preceding | self";
		

		
				
		/**
		 * 
		 * 
		 */
		public function XPathTokenizer(){

			addTokenPattern(new TokenPattern(XPathToken._EXPR_TOKEN_MISC, ExprToken_misc));
			addTokenPattern(new TokenPattern(XPathToken.LITERAL, Literal));
			addTokenPattern(new TokenPattern(XPathToken.NUMBER, Num));
			addTokenPattern(new TokenPattern(XPathToken.DIGITS, Digits));
			addTokenPattern(new TokenPattern(XPathToken.OPERATOR, Operator));
			addTokenPattern(new TokenPattern(XPathToken.NCNAME, NCName));
			addTokenPattern(new TokenPattern(XPathToken.EXPR_WHITESPACE, ExprWhitespace, false, true ));
			addTokenPattern(new TokenPattern(XPathToken._QNAME_DELIMITER, _QName_delimiter));

		}



		/**
			[28] ExprToken ::=
					'(' | ')' | '[' | ']' | '.' | '..' | '@' | ',' | '::'
					| NameTest
					| NodeType
					| Operator
					| FunctionName
					| AxisName
					| Literal
					| Number
					| VariableReference
		*/
		private function isExprToken(type:String):Boolean
		{
			switch (type){
			
			// ExprToken_misc is for the extra un-named values for ExprToken
			case XPathToken._EXPR_TOKEN_MISC:
			case XPathToken.NAME_TEST:
			case XPathToken.NODE_TYPE:
			case XPathToken.OPERATOR:
			case XPathToken.OPERATOR_NAME:
			case XPathToken.FUNCTION_NAME:
			case XPathToken.AXIS_NAME:
			case XPathToken.LITERAL:
			case XPathToken.NUMBER:
			case XPathToken.VARIABLE_REFERENCE:
				return true;
			default:
				return false;
			}
		}


		/*
			NB. The spec is unclear about the treatment of ":". It does not say anything about it except that it
			is used in QNames and wildcared pseudo-QNames for NameTests. However, it really has to be treated
			like an operator.
		*/
		private static function tokenMayPrecedeOperator(token:Token) : Boolean
		{
			switch (token.value){
			case "@": case "::": case "(": case "[": case ",":
			case ":": case "/": case "//":
				return false;
			default:
				if (token.tokenType == XPathToken.OPERATOR || token.tokenType == XPathToken.OPERATOR_NAME){
					return false;
				} else {
					return true;
				}
			}
		}

		/**
		 *
		 * [from spec]
		 * 
		 * For readability, whitespace may be used in expressions even though not explicitly
		 * allowed by the grammar: ExprWhitespace may be freely added within patterns before
		 * or after any ExprToken.
		 * 
		 * 
		 * The following special tokenization rules must be applied in the order specified to
		 * disambiguate the ExprToken grammar:
		 * 		* If there is a preceding token and the preceding token is not one of @, ::,
		 *		      (, [, , or an Operator, then a * must be recognized as a MultiplyOperator and
		 *		      an NCName must be recognized as an OperatorName.
		 *		    * If the character following an NCName (possibly after intervening
		 *		      ExprWhitespace) is (, then the token must be recognized as a NodeType or a
		 *		      FunctionName.
		 *		    * If the two characters following an NCName (possibly after intervening
		 *		      ExprWhitespace) are ::, then the token must be recognized as an AxisName.
		 *		    * Otherwise, the token must not be recognized as a MultiplyOperator, an
		 *		      OperatorName, a NodeType, a FunctionName, or an AxisName.
		 * 
		 */
		protected override function createToken(production:TokenPattern, value:String, sourceIndex:int, prev:Token=null):Token
		{
			var type:String = lastMatchType = production.name;

			/*	
				// TODO: investigate if there is a problem with just ignoring all whitespace
				// (i.e. just returning null in this case)
			*/

			if (type == XPathToken.EXPR_WHITESPACE)
			{
				var next:Token = lookAhead();
				if((prev == null || isExprToken(prev.tokenType))
					|| (next == null || isExprToken(next.tokenType)))
				{
					// discard the whitespace here
					return null;
				}else{
					var metrics:TokenMetrics = getTokenMetrics(prev);
					metrics.column += prev.value.length;
					throw new ParseError("Whitespace is not permitted here.", metrics);
				}
				/**/
			} else {
				
				if(type==XPathToken.NCNAME){
					return resolveNCName(value, sourceIndex);
				}
				else if (value == "*")
				{
					if(prev != null && tokenMayPrecedeOperator(prev)){
						return new XPathToken(XPathToken.MULTIPLY_OPERATOR, value, sourceIndex);
					} else{
						return resolveNCName(value, sourceIndex);
					}
					
				}else if(value == "$"){
					var next1:Token = lookAhead(1);
					if(next1 is QNameToken){
						next1.tokenType = XPathToken.VARIABLE_REFERENCE;
						skipAhead(1);
						return next1;
					}else{
						throw new SyntaxError();
					}
				}else if(type==XPathToken.LITERAL){
					// remove the quotes from string literals
					// value = value.substr(1, value.length-2);
					// UPDATE:  DO NOT remove quotes because the string "/" will be interpreted as a path!
				}
			}
			
			return new XPathToken(type, value, sourceIndex);
		}
		
		
		
		/*
			TODO: I think this will be a lot cleaner if we just emit NCNames and have the SyntaxTree
			construct QNames instead.
		*/
		private function resolveNCName(value:String, sourceIndex:int):Token
		{
			// I'm not really sure about this....
			if(AxisNames.isAxisName(value)){
				if(lookAhead(1).value == "::"){
					// skipAhead(1);
					return new XPathToken(XPathToken.AXIS_NAME, value, sourceIndex);
				}
				// else, I don't think it's an axis name...
			}
			
			var prev:Token = this.token;
			
			if(prev != null){
				
				if(tokenMayPrecedeOperator(prev)){
					return new XPathToken(XPathToken.OPERATOR_NAME, value, sourceIndex);
					
				}else if(prev.value == ":"){
					// even though we are creating this, we will discard it later.
					// it is the localName part of a QNameToken, and - if we are here -
					// we are inside a lookAhead 
					return new XPathToken(XPathToken.NCNAME, value, sourceIndex);
				}
			}
	
			
			var next1:Token = lookAhead(1);
			
			if(next1.value == "("){
				if(NodeTypes.isNodeType(value)){
					return new XPathToken(XPathToken.NODE_TYPE, value, sourceIndex);
				}else{
					return new XPathToken(XPathToken.FUNCTION_NAME, value, sourceIndex);
				}
				
//			}else if(next1.value == "::"){
//				skipAhead(1);
//				return new XPathToken(XPathToken.AXIS_NAME, value, sourceIndex);
				
			}else if(next1.value == ":"){
				var next2:Token = lookAhead(2);
				
				if(next2.value == "*" || next2.tokenType == XPathToken.NCNAME){
					skipAhead(2);
					return new QNameToken(XPathToken.NAME_TEST, value, next2.value, sourceIndex);
				}else{
					// XXX: should this be "" or "*" ??
					return new QNameToken(XPathToken.NAME_TEST, "", value, sourceIndex);
				}
			}else {
				return new QNameToken(XPathToken.NAME_TEST, "", value, sourceIndex);
			}	
		}
	

	}
	
	

}

