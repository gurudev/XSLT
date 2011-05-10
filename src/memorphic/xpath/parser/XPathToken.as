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
	import memorphic.parser.Token;

	public class XPathToken extends Token
	{
		
		// XML types
		// see:
		//	 - http://www.w3.org/TR/REC-xml
		//	 - http://www.w3.org/TR/REC-xml-names
		
		public static const NCNAME:String = "NCName";
		
		// QName is never explicitly created
		//public static var QNAME:String = "QName";
		// but we need the delimiter
		public static const _QNAME_DELIMITER:String = "_QName_delimiter";
		
		
		// XPath Types
		// (see http://www.w3.org/TR/xpath)

		// [6]
		public static const AXIS_NAME:String = "AxisName";
		
		// [28] 
		//public static const EXPR_TOKEN:String = "ExprToken";
		
		// [Not directly from spec]
		public static const _EXPR_TOKEN_MISC:String = "ExprToken_misc";

		// [29]
		public static const LITERAL:String = "Literal";

		// [30] 
		public static const NUMBER:String = "Number";

		// [31] 
		public static const DIGITS:String = "Digits";

		// [32] 
		public static const OPERATOR:String = "Operator";

		// [33]
		public static const OPERATOR_NAME:String = "OperatorName";
			
		// [34] 
		public static const MULTIPLY_OPERATOR:String = "MultiplyOperator";
		
		//	[35] 
		public static const FUNCTION_NAME:String = "FunctionName";
			
		// [36]  
		public static const VARIABLE_REFERENCE:String = "VariableReference";
			
		// [37] 
		public static const NAME_TEST:String = "NameTest";

		// [38]
		public static const NODE_TYPE:String = "NodeType";
	
		// [39]
		public static const EXPR_WHITESPACE:String = "ExprWhitespace";
		
		
		
		public function XPathToken(type:String, value:String, sourceIndex:int)
		{
			super(type, value, sourceIndex);
		}
	}
}