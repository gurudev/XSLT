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
	import flash.utils.Dictionary;
	
	import memorphic.parser.TreeWalker;
	import memorphic.xpath.model.Axis;
	import memorphic.xpath.model.AxisNames;
	import memorphic.xpath.model.BinaryOperation;
	import memorphic.xpath.model.FilterExpr;
	import memorphic.xpath.model.FunctionCall;
	import memorphic.xpath.model.IExpression;
	import memorphic.xpath.model.INodeTest;
	import memorphic.xpath.model.LocationPath;
	import memorphic.xpath.model.NameTest;
	import memorphic.xpath.model.NodeTypeTest;
	import memorphic.xpath.model.NodeTypes;
	import memorphic.xpath.model.PathExpr;
	import memorphic.xpath.model.Predicate;
	import memorphic.xpath.model.PredicateList;
	import memorphic.xpath.model.PrimitiveValue;
	import memorphic.xpath.model.QueryRoot;
	import memorphic.xpath.model.Step;
	import memorphic.xpath.model.VariableReference;
	import memorphic.parser.ParseError;
	import memorphic.parser.TokenMetrics;
	import memorphic.parser.Token;
	import memorphic.xpath.model.Operators;
	import memorphic.xpath.model.SimplePositionPredicate;

	final public class XPathParser
	{
		
		public var tokenizer:XPathTokenizer;
		public var syntaxTree:XPathSyntaxTree;
		
		private var modelMap:Dictionary;
		
		private var treeWalker:TreeWalker;
		
		private var currentToken:Token;
		
		private var treeRoot:Token;
		


		public function XPathParser(){
		}


		public function parseXPath(source:String):QueryRoot
		{
//			try {
				tokenizer = new XPathTokenizer();
				syntaxTree = new XPathSyntaxTree(tokenizer);
				modelMap = new Dictionary();
				tokenizer.rawData = source;
				treeRoot = syntaxTree.getTree();
				syntaxTree.verifyTree();
				treeWalker = new TreeWalker(treeRoot);
				walkTree();
				var path:IExpression = IExpression( getModel(treeRoot) );
				var queryRoot:QueryRoot = new QueryRoot(path);
				cleanUp();
				return queryRoot;
//			}catch(e:Error){
				// rethrow the error so the stack trace is a bit more friendly
//				throw e;
//			}
//			return null;
		}
		
		
	
		
		
		private function cleanUp():void
		{
			tokenizer = null;
			syntaxTree = null;
			modelMap = null;
			treeWalker = null;
			currentToken = null;
			treeRoot = null;
		}
		
		
		
		private function eachToken():void
		{
			const tokenType:String = currentToken.tokenType;
			switch(tokenType){
			case XPathSyntaxTree.LOCATION_PATH:
				parseLocationPath();
				break;
			case XPathSyntaxTree.RELATIVE_LOCATION_PATH:
				parseRelativeLocationPath();
				break;
			case XPathSyntaxTree.ABSOLUTE_LOCATION_PATH:
				parseAbsoluteLocationPath();
				break;
			case XPathSyntaxTree.ABBREVIATED_ABSOLUTE_LOCATION_PATH:
				parseAbbreviatedAbsoluteLocationPath();
				break;
			case XPathSyntaxTree.STEP:
				parseStep();
				break;
			case XPathToken.NODE_TYPE:
				setModel(new NodeTypeTest(currentToken.value));
				break;
			case XPathSyntaxTree.NODE_TEST:
				condenseToken();
				break;
			case XPathToken.NAME_TEST:
				parseNameTest();
				break;
			case XPathToken.AXIS_NAME:
				setModel(currentToken.value);
				break
			case XPathSyntaxTree.ABBREVIATED_AXIS_SPECIFIER:
				parseAbbreviatedAxisSpecifier();
				break;
			case XPathSyntaxTree.AXIS_SPECIFIER:
				setModel(new Axis(getModel(currentToken.children[0]) as String));
				break;
			case XPathToken.OPERATOR:
			case XPathToken.OPERATOR_NAME:
				parseOperator();
				break;
			case XPathSyntaxTree.EXPR:
			case XPathSyntaxTree.PRIMARY_EXPR:
				condenseToken();
				break;
			case XPathToken.MULTIPLY_OPERATOR:
				// ignore it. MULTIPLICATIVE_EXPR will find it as a child
				break;
			case XPathSyntaxTree.OR_EXPR:
			case XPathSyntaxTree.AND_EXPR:
			case XPathSyntaxTree.EQUALITY_EXP:
			case XPathSyntaxTree.RELATIONAL_EXP:
			case XPathSyntaxTree.MULTIPLICATIVE_EXPR:
			case XPathSyntaxTree.ADDITIVE_EXPR:
			case XPathSyntaxTree.UNION_EXPR:
				parseBinaryOperation();
				break;
			case XPathSyntaxTree.UNARY_EXPR:
				parseUnaryExpr();
				break;
			case XPathToken.LITERAL:
				// slice() removes the quotes
				setModel(new PrimitiveValue(currentToken.value.slice(1, -1)));
				break;
			case XPathToken.NUMBER:
				setModel(new PrimitiveValue(parseFloat(currentToken.value)));
				break;
			case XPathSyntaxTree.FILTER_EXPR:
				parseFilterExpr();
				break;
			case XPathSyntaxTree.PATH_EXPR:
				parsePathExpr();
				break;
			case XPathSyntaxTree.PREDICATE:
				parsePredicate();
				break;
			case XPathSyntaxTree.PREDICATE_EXPR:
				condenseToken();
				break;
			case XPathSyntaxTree.FUNCTION_CALL:
				parseFunctionCall();
				break;
			case XPathToken.FUNCTION_NAME:
				setModel(currentToken.value);
				break;
			case XPathSyntaxTree.ARGUMENT:
				parseFunctionArgument();
				break;
			case XPathSyntaxTree.ABBREVIATED_STEP:
				parseAbbreviatedStep();
				break;
			case XPathToken._EXPR_TOKEN_MISC:
				// ignore: these tokens are interpreted when the parent is parsed
				// parseMiscToken();
				break;
			case XPathToken.VARIABLE_REFERENCE:
				setModel(new VariableReference(QNameToken(currentToken).prefix, QNameToken(currentToken).localName));
				break;
			default:
				// All tokens outputted by the tokenizer are now supported so we shouldn't reach this point
				throw new SyntaxError(currentToken.tokenType + " is not yet supported");
			}	
		}
		

		
		private function walkTree():void
		{
			do {
				currentToken = treeWalker.nextItem();
				// TODO: replace this with a (hopefully faster) function look-up
				eachToken();
			}while(treeRoot != currentToken);
		}
		
		
		
		private function parseLocationPath():void
		{
			setModel(getModel(currentToken.children[0]));
		}
		
		
		private function parseAbsoluteLocationPath():void
		{
			var path:LocationPath;
			
			if(currentToken.children.length > 0){
				path = LocationPath(getModel(currentToken.children[0]));
				path.absolute = true;
			}else{
				path = new LocationPath(true);
				path.steps.push(Step.ABBREVIATED_CHILD);
			}
			setModel(path);
		}
		
		
		private function parseAbbreviatedAbsoluteLocationPath():void
		{
			var step:Step = Step(getModel(currentToken.children[0]));
			var path:LocationPath = LocationPath(getModel(currentToken.children[1]));
			path.absolute = true;
			path.steps.unshift(step);
			setModel(path);
		}
		
		private function parseRelativeLocationPath():void
		{
			var path:LocationPath = new LocationPath(false);
			var children:Array = currentToken.children;
			var n:int = children.length;
			for(var i:int=0; i<n; i++){
				path.steps.push(Step(getModel(children[i])));
			}	
			setModel(path);
		}
		

		
		private function parseStep():void
		{
			var children:Array = currentToken.children;
			if(children.length == 1){
				// then it's an abbreviated step, which we have already parsed
				setModel(getModel(children[0]));
			}else{
				var axis:Axis = getModel(children[0]) as Axis;
				var nodeTest:INodeTest = getModel(children[1]) as INodeTest;
				var step:Step = new Step(axis, nodeTest, collectPredicates(children.slice(2)));
				setModel(step);
			}
		}
		
		private function collectPredicates(children:Array):PredicateList
		{
			var predicates:Array = new Array();
			var n:int = children.length;
			for(var i:int=0; i<n; i++){
				predicates.push(getModel(children[i]));
			}
			if(predicates.length > 0){
				return new PredicateList(predicates);
			}else{
				return null;
			}
		}
		
		
		private function parseAbbreviatedStep():void
		{
			var abbr:String = currentToken.children[0].value;
			if(abbr == ".."){
				//setModel(new Step(new Axis(AxisNames.PARENT), new NodeTypeTest(NodeTypes.NODE), null));
				setModel(Step.ABBREVIATED_PARENT);
			}else if(abbr == "."){
				setModel(Step.ABBREVIATED_SELF);
			}else{
				throw new Error("A token was parsed as an abbeviated step, but it was neither of '.' or '..'");
			}
		}
		
		
//		// nothing realy happens here... it's for debuggin really...
//		private function parseMiscToken():void
//		{
//			switch(currentToken.value){
//			case "..":
//			case ".":
//			case "@":
//				break;
//			default:
//				throw new Error("this token isn't implemented: " + currentToken.tokenType + " " + currentToken.value);
//			}
//		}
		
		
		
				
		private function parsePredicate():void
		{
			var expr:IExpression = getModel(currentToken.children[0]) as IExpression;
			var primExpr:PrimitiveValue;
			if((primExpr = (expr as PrimitiveValue)) && primExpr.value is uint){
				setModel(new SimplePositionPredicate(uint(primExpr.value)));
			}else{
				setModel(new Predicate(expr));
			}
		}
		

		
		private function parsePathExpr():void
		{
			var children:Array = currentToken.children;
			var n:int = children.length;
			if(n==1){
				// this is just a single LocationPath or FilterExpr
				condenseToken();
				return;
			}
			// if n==2 then it's a FilterExpr followed by a LocationPath
			var filterExpr:IExpression = getModel(children[0]) as IExpression;
			var path:LocationPath = getModel(children[n-1]) as LocationPath;
			if(n==3){
				// if n==2 then it's a FilterExpr followed by a "//" step, then a LocationPath
				// so just add the step on to the start of the path
				var step:Step = getModel(children[1]) as Step;
				path.steps.unshift(step);
			}
			setModel(new PathExpr(filterExpr, path));
		}
		
		
		
		private function parseFilterExpr():void
		{
			var children:Array = currentToken.children;
			if(children.length == 1){
				// just treat a FilterExpression as normal primary expression if there are no predicates
				condenseToken();
			}else{
				var primaryExpr:IExpression = getModel(children[0]) as IExpression;
				setModel(new FilterExpr(primaryExpr, collectPredicates(children.splice(1))));
			}
		}
		
		private function parseFunctionArgument():void
		{
			// argument is just an expression, so use the thing we parsed already
			setModel(getModel(currentToken.children[0]));
		}
		
		private function parseFunctionCall():void
		{
			var children:Array = currentToken.children;
			var funcName:String = getModel(children[0]) as String;
			var funcArgs:Array = new Array();
			var n:int = children.length;
			for(var i:int=1; i<n; i++){
				funcArgs.push(getModel(children[i]));
			}
			setModel(new FunctionCall(funcName, funcArgs));
		}
		
		
		
		
		private function parseNameTest():void
		{
			if(currentToken is QNameToken){
				var qName:QNameToken = QNameToken(currentToken); 
				setModel(new NameTest(qName.prefix, qName.localName));
			}else{
				// should be * at this point
				setModel(new NameTest(qName.prefix, qName.localName));
			}
		}
		
		
		
		private function parseBinaryOperation():void
		{
			if(condenseToken()){
				return;
			}
			// We stripped out associativity enforcement from the grammar, so we need to add it back
			// by nesting operations in groups. Note, this only applies to operators at the same
			// precedence since precedence is still enforced by the grammar.
			// All binary operators are left-associative in XPath.
			var children:Array = currentToken.children;
			var n:int = children.length;
			var leftArg:IExpression = getModel(children[0]) as IExpression;
			var rightArg:IExpression;
			var operator:String;
			var expr:BinaryOperation;
			for(var i:int=1; i<n;){
				operator = children[i++].value;
				rightArg = getModel(children[i++]) as IExpression;
				expr = new BinaryOperation(leftArg, rightArg, operator);
				// use new expr as left operand of parent expression 
				leftArg = expr;
			}
			setModel(expr);
		}
		
		
		private function parseUnaryExpr():void
		{
			if(condenseToken()){
				return;
			}
			// expand "-Expr" to "0 - Expr"
			var leftArg:IExpression = PrimitiveValue.ZERO;
			var rightArg:IExpression = getModel(currentToken.children[1]) as IExpression;
//			var op:String = currentToken.children[0].value;
			var op:String = "-";
			setModel(new BinaryOperation(leftArg, rightArg, op));
		}
		
		
		private function parseAbbreviatedAxisSpecifier():void
		{
			if(currentToken.children.length > 0){
				// child is always "@" so don't bother checking
				//if(Token(currentToken.children[0]).value == "@"){
					setModel(AxisNames.ATTRIBUTE);
				//}
			}else{
				setModel(AxisNames.CHILD);
			}
		}
		
	
		
		
		private function parseOperator():void
		{
			// n.b. We only need to deal with "//" here. 
			// "/" is removed by the Syntax Tree and all other operators are binary, have no special meaning 
			// apart from their token value, and thus are dealt with as child tokens in parseBinaryOperation().
			switch(currentToken.value){
			case "//":
				// "//" is equivalent to "/descendant-or-self::node()/"
				setModel(Step.ABBREVIATED_DESC_OR_SELF);
				break;
			default:
				if(!Operators.isOperator(currentToken.value)){
					// check for erroneous operators - they can get to this point
					throw new SyntaxError("Invalid operator: '" + currentToken.value + "'.");
				}
			}
		}
		
		
		
		
		protected function condenseToken():Object
		{
			var model:Object;
			if(currentToken.children.length == 1){
				setModel(model = getModel(currentToken.children[0]));
				return model;
			}else return null;
		}
		
		protected function getModel(token:Token):Object
		{
			if(modelMap[token] == null){
				throw new Error("There is no model for token: " + token);
			}else{
				return modelMap[token];
			}
			
		}
		protected function setModel(model:Object):void
		{
			modelMap[currentToken] = model;
		}
	}
}