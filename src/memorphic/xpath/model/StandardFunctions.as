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

package memorphic.xpath.model
{
	import memorphic.utils.XMLUtil;
	
	
	/**
	 *  See http://www.w3.org/TR/xpath#corelib
	 * 
	 * These are all of the standard functions that you can use in an XPath query, as defined
	 * by the spec. You can add more custom functions via the <code>XPathContext.functions</code>
	 * property.
	 */	
	dynamic public class StandardFunctions
	{
		
	
		public function StandardFunctions()
		{
			// use a hash for names that have hyphens or AS3 syntax conflicts
			this["local-name"] = localName;
			this["namespace-uri"] = namespaceURI;
			this["starts-with"] = startsWith;
			this["substring-before"] = substringBefore;
			this["substring-after"] = substringAfter;
			this["string-length"] = stringLength;
			this["normalize-space"] = normalizeSpace;
			this["true"] = boolTrue;
			this["false"] = boolFalse;
		}


///////////////////////////////////////////////////////////////////////////////////
//
//	4.1 Node Set Functions
//
///////////////////////////////////////////////////////////////////////////////////
		
		
		/**
		 * 	Returns a number equal to the context size from the expression evaluation context. 
		 */		
		public function last(context:XPathContext):int
		{
			return context.last();
		}
		
		
		/**
		 * 	Returns a number equal to the context position from the expression evaluation context. 
		 */	
		public function position(context:XPathContext):int
		{
			return context.position();
		}
		
		
		/**
		 * 	Returns the number of nodes in the argument node-set.
		 */	
		public function count(context:XPathContext, nodeSet:XMLList):int
		{
			return nodeSet.length();
		}
		
		
		
		/**
		 * 	Selects elements by their unique ID (see [5.2.1 Unique IDs]). When the argument to id is of type node-set, 
		 * then the result is the union of the result of applying id to the string-value of each of the nodes in the 
		 * argument node-set. When the argument to id is of any other type, the argument is converted to a string as 
		 * if by a call to the string function; the string is split into a whitespace-separated list of tokens 
		 * (whitespace is any sequence of characters matching the production S); the result is a node-set containing 
		 * the elements in the same document as the context node that have a unique ID equal to any of the tokens in 
		 * the list.
		 *
		 * 		id("foo") selects the element with unique ID foo
		 * 
		 * 		id("foo")/child::para[position()=5] selects the fifth para child of the element with unique ID foo
		 * 
		 * 
		 * Contrary to the spec, I have permitted id to reside in any namespace, as opposed to xml:id, which does not
		 * reflect the vast majority of usage. TODO: Perhaps this could be made into an optional feature via a flag? 
		 */
		public function id(context:XPathContext, idArg:Object):XMLList
		{
			var result:XMLList;
			if(idArg is XMLList){
				result = new XMLList();
				for each(var idNode:XML in idArg){
					result += id(context, idNode);
				}
			}else{
				idArg = idArg.toString();
				result = XMLUtil.rootNode(context.contextNode).descendants().(attribute("id") == idArg);
				if(result.length() > 0){
					result = XMLList(result[0]);
				}
			
			}
			return result;
		}
		
	
		
		/**
		 * Returns the local part of the expanded-name of the node in the argument node-set that is first in document 
		 * order. If the argument node-set is empty or the first node has no expanded-name, an empty string is returned.
		 * If the argument is omitted, it defaults to a node-set with the context node as its only member.
		 * 
		 * N.B.This method is private because it is added via array access as "local-name".
		 */	
		private function localName(context:XPathContext, nodeSet:XMLList=null):String
		{
			if(nodeSet == null){
				return context.contextNode.localName();
			}else if(nodeSet.length() == 0){
				return "";
			}else{
				var firstNode:XML = nodeSet[0];
				var name:String = firstNode.localName();
				if(name == null){
					return "";
				}else{
					return name;
				}
			}
		}
		
		/**
		 * The namespace-uri function returns the namespace URI of the expanded-name of the node in the argument 
		 * node-set that is first in document order. If the argument node-set is empty, the first node has no 
		 * expanded-name, or the namespace URI of the expanded-name is null, an empty string is returned. If the 
		 * argument is omitted, it defaults to a node-set with the context node as its only member.
		 * 
		 * NOTE: The string returned by the namespace-uri function will be empty except for element nodes and 
		 * attribute nodes.
		 * 
		 * N.B.This method is private because it is added via array access as "namespace-uri".
		 */ 
		private function namespaceURI(context:XPathContext, nodeSet:XMLList=null):String
		{
			var node:XML;
			if(nodeSet == null){
				node = context.contextNode;
			}else if (nodeSet.length() > 0){
				node = nodeSet[0];
			}else{
				return "";
			}
			return node.namespace().uri;
		}
		
		
		/**
		 * The name function returns a string containing a QName representing the expanded-name of the node in the 
		 * argument node-set that is first in document order. The QName must represent the expanded-name with respect 
		 * to the namespace declarations in effect on the node whose expanded-name is being represented. Typically, 
		 * this will be the QName that occurred in the XML source. This need not be the case if there are namespace 
		 * declarations in effect on the node that associate multiple prefixes with the same namespace. However, an 
		 * implementation may include information about the original prefix in its representation of nodes; in this 
		 * case, an implementation can ensure that the returned string is always the same as the QName used in the 
		 * XML source. If the argument node-set is empty or the first node has no expanded-name, an empty string is 
		 * returned. If the argument it omitted, it defaults to a node-set with the context node as its only member.
		 * 
		 * NOTE: The string returned by the name function will be the same as the string returned by the local-name 
		 * function except for element nodes and attribute nodes.
		 */
		public function name(context:XPathContext, nodeSet:XMLList=null):String
		{
			var node:XML;
			if(nodeSet == null){
				node = context.contextNode;
			}else if(nodeSet.length() == 0){
				return "";
			}else{
				node = nodeSet[0];
			}
			if(node.nodeKind() == "element"){
				var uri:String = node.namespace().uri;
				if(uri){
					return uri + ":" + node.localName();
				}else{
					return node.localName();
				}
			}else{
				return "";
			}
		}





///////////////////////////////////////////////////////////////////////////////////
//
//	4.2 String Functions
//
///////////////////////////////////////////////////////////////////////////////////


	
		/**
		 * The string function converts an object to a string as follows:
		 * 
		 * A node-set is converted to a string by returning the string-value of the node in the node-set that is 
		 * first in document order. If the node-set is empty, an empty string is returned.
		 * A number is converted to a string as follows
		 * 	o NaN is converted to the string NaN
		 *  o positive zero is converted to the string 0    
		 *  o negative zero is converted to the string 0     
		 *  o positive infinity is converted to the string Infinity
		 *  o negative infinity is converted to the string -Infinity
		 *  o if the number is an integer, the number is represented in decimal form as a Number with no decimal 
		 * 		point and no leading zeros, preceded by a minus sign (-) if the number is negative
		 *  o otherwise, the number is represented in decimal form as a Number including a decimal point with at least 
		 * 		one digit before the decimal point and at least one digit after the decimal point, preceded by a minus 
		 * 		sign (-) if the number is negative; there must be no leading zeros before the decimal point apart 
		 * 		possibly from the one required digit immediately before the decimal point; beyond the one required 
		 * 		digit after the decimal point there must be as many, but only as many, more digits as are needed to 
		 * 		uniquely distinguish the number from all other IEEE 754 numeric values.
		 * 
		 * The boolean false value is converted to the string false. The boolean true value is converted to the 
		 * string true.
		 * 
		 * An object of a type other than the four basic types is converted to a string in a way that is dependent 
		 * on that type. 
		 * 
		 * If the argument is omitted, it defaults to a node-set with the context node as its only member.
		 * 
		 */  
		public function string(context:XPathContext, arg:Object=null):String
		{
			if(arg == null){
				return TypeConversions.toString(context.contextNode.toString());
			}else{
				return TypeConversions.toString(arg);
			}
		}
		
		/**
		 * The concat function returns the string concatenation of its arguments.
		 */ 
		public function concat(context:XPathContext, s1:*, s2:*, ...rest):String
		{
			var result:String = TypeConversions.toString(s1) + TypeConversions.toString(s2);
			var n:int = rest.length;
			for(var i:int=0; i<n; i++){
				result += TypeConversions.toString(rest[i]);
			}
			return result;
		}
		
		/**
		 * The starts-with function returns true if the first argument string starts with the second argument 
		 * string, and otherwise returns false.
		 * 
		 * N.B.This method is private because it is added via array access as "starts-with".
		 */
		private function startsWith(context:XPathContext, a:*, b:*):Boolean
		{
			var haystack:String = TypeConversions.toString(a);
			var needle:String = TypeConversions.toString(b);
			if(a.substr(0, b.length) == b){
				return true;
			}else{
				return false;
			}
		} 
		
		
		/**
		 * The contains function returns true if the first argument string contains the second argument string, 
		 * and otherwise returns false.
		 */
		public function contains(context:XPathContext, a:*, b:*):Boolean
		{
			var basket:String = TypeConversions.toString(a);
			var apple:String = TypeConversions.toString(b);
			return basket.indexOf(apple) > -1;
		} 

			
		/**
		 * The substring-before function returns the substring of the first argument string that precedes the 
		 * first occurrence of the second argument string in the first argument string, or the empty string if 
		 * the first argument string does not contain the second argument string. For example, 
		 * substring-before("1999/04/01","/") returns 1999.
		 * 
		 * N.B.This method is private because it is added via array access as "substring-before".
		 */ 
		private function substringBefore(context:XPathContext, a:*, b:*):String
		{
			var basket:String = TypeConversions.toString(a);
			var apple:String = TypeConversions.toString(b);
			var index:int = basket.indexOf(apple);
			if(index == -1){
				return "";
			}else{
				return basket.substr(0, index);
			}
		}
		
				
		/**
		 * The substring-after function returns the substring of the first argument string that follows the 
		 * first occurrence of the second argument string in the first argument string, or the empty string if 
		 * the first argument string does not contain the second argument string. For example, 
		 * substring-after("1999/04/01","/") returns 04/01, and substring-after("1999/04/01","19") returns 
		 * 99/04/01.
		 * 
		 * N.B.This method is private because it is added via array access as "substring-after".
		 */ 
		private function substringAfter(context:XPathContext, a:*, b:*):String
		{
			var basket:String = TypeConversions.toString(a);
			var apple:String = TypeConversions.toString(b);
			var index:int = basket.indexOf(apple);
			if(index == -1){
				return "";
			}else{
				return basket.substr(index+ apple.length);
			}
		}
		
		
		/**
		 * The substring function returns the substring of the first argument starting at the position specified 
		 * in the second argument with length specified in the third argument. For example, substring("12345",2,3) 
		 * returns "234". If the third argument is not specified, it returns the substring starting at the 
		 * position specified in the second argument and continuing to the end of the string. For example, 
		 * substring("12345",2) returns "2345".
		 */
		public function substring(context:XPathContext, string:*, from:*, length:*=null):String
		{
			if(length == null){
				return TypeConversions.toString(string).substr(TypeConversions.toNumber(from)-1);
			}else{
				return TypeConversions.toString(string).substr(TypeConversions.toNumber(from)-1, TypeConversions.toNumber(length));
			}
		}
		
		/**
		 * The string-length returns the number of characters in the string (see [3.6 Strings]). If the argument 
		 * is omitted, it defaults to the context node converted to a string, in other words the string-value of 
		 * the context node.
		 * 
		 * N.B.This method is private because it is added via array access as "string-length".
		 */
		private function stringLength(context:XPathContext, string:*=null):int
		{
			if(string == null){
				string = context.contextNode;
			}
			return TypeConversions.toString(string).length;
		}
		
		
		/**
		 * The normalize-space function returns the argument string with whitespace normalized by stripping leading 
		 * and trailing whitespace and replacing sequences of whitespace characters by a single space. Whitespace 
		 * characters are the same as those allowed by the S production in XML. If the argument is omitted, it 
		 * defaults to the context node converted to a string, in other words the string-value of the context node.
		 * 
		 * N.B.This method is private because it is added via array access as "normalize-space".
		 */ 
		private function normalizeSpace(context:XPathContext, string:*=null):String
		{
			if(string == null){
				string = context.contextNode;
			}
			var str:String = TypeConversions.toString(string);
			if(str == ""){
				return "";
			}
			// replace any blocks of whitespace with a single space
			str = str.replace(/\s+/g, " ");
			// now trim the ends
			var r:RegExp = /^\s?(\S.*\S)\s?$/;
			var matches:Object = r.exec(str);
			if(matches){
				return matches[1];
			}else{
				return "";
			}
		}
		
		
		
		/**
		 * The translate function returns the first argument string with occurrences of characters in the second 
		 * argument string replaced by the character at the corresponding position in the third argument string. For 
		 * example, translate("bar","abc","ABC") returns the string BAr. If there is a character in the second 
		 * argument string with no character at a corresponding position in the third argument string (because the 
		 * second argument string is longer than the third argument string), then occurrences of that character in 
		 * the first argument string are removed. For example, translate("--aaa--","abc-","ABC") returns "AAA". If a 
		 * character occurs more than once in the second argument string, then the first occurrence determines the 
		 * replacement character. If the third argument string is longer than the second argument string, then excess 
		 * characters are ignored.
		 * 
		 * NOTE: The translate function is not a sufficient solution for case conversion in all languages. A future 
		 * version of XPath may provide additional functions for case conversion.
		 * 
		 */
		public function translate(context:XPathContext, str1:*, str2:*, str3:*):String
		{
			str1 = TypeConversions.toString(str1);
			str2 = TypeConversions.toString(str2);
			str3 = TypeConversions.toString(str3);
			var result:String = "";
			var len:int = str1.length;
			var ind:int;
			var char:String;
			for(var i:int=0; i<len; i++){
				char = str1.charAt(i);
				ind = str2.indexOf(char);
				if(ind == -1){
					result += char;
				}else if(ind < str3.length){
					result += str3.charAt(ind);
				}
			}
			return result;
		}
		
		
		
		
///////////////////////////////////////////////////////////////////////////////////
//
//	4.3 Boolean Functions
//
///////////////////////////////////////////////////////////////////////////////////		


		/**
		 * The boolean function converts its argument to a boolean as follows:
		 * 
		 * 	-	a number is true if and only if it is neither positive or negative zero nor NaN
		 * 	-	a node-set is true if and only if it is non-empty
		 * 	-	a string is true if and only if its length is non-zero
		 * 	-	an object of a type other than the four basic types is converted to a boolean in a way that is 
		 * 		dependent on that type
		 * 
		 * @see TypeConversions#toBoolean
		 * 
		 */
		public function boolean(context:XPathContext, obj:*):Boolean
		{
			return TypeConversions.toBoolean(obj);
		}
		
		
		/**
		 * The not function returns true if its argument is false, and false otherwise.
		 */
		public function not(context:XPathContext, obj:*):Boolean
		{
			return !TypeConversions.toBoolean(obj);
		}
		
		/**
		 * N.B.This method is private because it is added via array access as "true".
		 * 
		 */ 
		private function boolTrue(context:XPathContext):Boolean
		{
			return true;
		}  
		
		/**
		 * N.B.This method is private because it is added via array access as "false".
		 * 
		 */ 
		private function boolFalse(context:XPathContext):Boolean
		{
			return false;
		}  
		
		
		
		/**
		 * The lang function returns true or false depending on whether the language of the context node as specified 
		 * by xml:lang attributes is the same as or is a sublanguage of the language specified by the argument string. 
		 * The language of the context node is determined by the value of the xml:lang attribute on the context node, 
		 * or, if the context node has no xml:lang attribute, by the value of the xml:lang attribute on the nearest 
		 * ancestor of the context node that has an xml:lang attribute. If there is no such attribute, then lang 
		 * returns false. If there is such an attribute, then lang returns true if the attribute value is equal to the 
		 * argument ignoring case, or if there is some suffix starting with - such that the attribute value is equal 
		 * to the argument ignoring that suffix of the attribute value and ignoring case. For example, lang("en") 
		 * would return true if the context node is any of these five elements:
		 * 
		 * <para xml:lang="en"/>
		 * <div xml:lang="en"><para/></div>
		 * <para xml:lang="EN"/>
		 * <para xml:lang="en-us"/>
		 * 
		 */
		public function lang(context:XPathContext, langSymbol:*):Boolean
		{
			var xml:Namespace = new Namespace(context.namespaces.xml);
			var lan:String = TypeConversions.toString(langSymbol).toLowerCase();
			var p:XML = context.contextNode;
			var contextLang:String;
			do{
				if(p.@xml::lang){
					contextLang = p.@xml::lang.toString().toLowerCase();
					break;
				}
				
			}while(p = p.parent());
			if(!contextLang){
				return false;
			}
			if(lan == contextLang
				|| contextLang.substr(0,lan.length+1) == lan + "-"
			){
				return true;
			}
			return false;
		}
		
		
		
		
///////////////////////////////////////////////////////////////////////////////////
//
//	4.4 Number Functions
//
///////////////////////////////////////////////////////////////////////////////////		
		
		
		
		/**
		 * The number function converts its argument to a number as follows: 
		 * 
		 * 	- a string that consists of optional whitespace followed by an optional minus sign followed by a 
		 * 		Number followed by whitespace is converted to the IEEE 754 number that is nearest (according to 
		 * 		the IEEE 754 round-to-nearest rule) to the mathematical value represented by the string; any other 
		 * 		string is converted to NaN
		 * 	- boolean true is converted to 1; boolean false is converted to 0
		 *  - a node-set is first converted to a string as if by a call to the string function and then converted 
		 * 		in the same way as a string argument
		 *  - an object of a type other than the four basic types is converted to a number in a way that is 
		 * 		dependent on that type
		 *  - If the argument is omitted, it defaults to a node-set with the context node as its only member.
		 * 
		 * NOTE: The number function should not be used for conversion of numeric data occurring in an element in 
		 * an XML document unless the element is of a type that represents numeric data in a language-neutral format 
		 * (which would typically be transformed into a language-specific format for presentation to a user). In 
		 * addition, the number function cannot be used unless the language-neutral format used by the element is 
		 * consistent with the XPath syntax for a Number.
		 * 
		 * @see TypeConversions#toNumber
		 */
		public function number(context:XPathContext,  num:*):Number
		{
			return TypeConversions.toNumber(num);
		}
		
		
		
		/**
		 * The sum function returns the sum, for each node in the argument node-set, of the result of converting 
		 * the string-values of the node to a number.
		 */
		public function sum(context:XPathContext, nodeSet:XMLList):Number
		{
			var result:Number = 0;
			for each(var node:XML in nodeSet){
				result += TypeConversions.toNumber(node);
			}
			return result;
		} 
		
		/**
		 * The floor function returns the largest (closest to positive infinity) number that is not greater than 
		 * the argument and that is an integer.
		 */ 
		public function floor(context:XPathContext, num:*):Number
		{
			return Math.floor(TypeConversions.toNumber(num)); 
		}
		
		/**
		 * The ceiling function returns the smallest (closest to negative infinity) number that is not less than 
		 * the argument and that is an integer.
		 */
		public function ceiling(context:XPathContext, num:*):Number
		{
			return Math.ceil(TypeConversions.toNumber(num));
		}
		
		
		/**
		 * The round function returns the number that is closest to the argument and that is an integer. If there 
		 * are two such numbers, then the one that is closest to positive infinity is returned. If the argument is 
		 * NaN, then NaN is returned. If the argument is positive infinity, then positive infinity is returned. If 
		 * the argument is negative infinity, then negative infinity is returned. If the argument is positive zero, 
		 * then positive zero is returned. If the argument is negative zero, then negative zero is returned. If the 
		 * argument is less than zero, but greater than or equal to -0.5, then negative zero is returned.
		 * 
		 * NOTE: For these last two cases, the result of calling the round function is not the same as the result 
		 * of adding 0.5 and then calling the floor function.
		 */
		public function round(context:XPathContext, num:*):Number
		{
			return Math.round(TypeConversions.toNumber(num));
		}
		
		
		
///////////////////////////////////////////////////////////////////////////////////
//
//	Misc non-spec Functions
//
///////////////////////////////////////////////////////////////////////////////////		


		/**
		 * Used for debugging purposes. The print() function traces a message to the Flash log. Since this function
		 * will be used in predicate conditions, it returns the message (which would normally evaluate to "true").
		 */ 
		public function print(context:XPathContext, message:*):Boolean
		{
			trace.call(null, message);
			return message;
		}
	}
}