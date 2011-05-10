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
	final public class TypeConversions
	{
		
		
		
		public static function toXMLList(a:Object):XMLList
		{
			if(a is XMLList){
				return a as XMLList;
			}else if(a is XML){
				return XMLList(a);
			}else{
				throw new TypeError("Cannot convert '"+a+"' to an XMLList.");
			}
		}
		
		public static function toString(a:Object):String
		{
			if(a is String){
				return a as String;
			}else if(a is Boolean){
				return a ? "true" : "false";
			}else if(a is Number){
				return a.toString();
			}else if(a is XMLList){
				if(a.length() == 0){
					return "";
				}else{
					return xmlToString(a[0] as XML);
				}
			}else if(a is XML){
				return xmlToString(a as XML);
			}else{
				return a.toString();
			}
		}
		
		private static function xmlToString(xml:XML):String
		{
			// temporarily disable pretty printing. We need to have consistent string representations
			// in order to do string comparisons
			var oldPrettyPrint:Boolean = XML.prettyPrinting;
			var str:String;
			XML.prettyPrinting = false;
			// TODO: test that this meets the spec requirements
			str = xml.toString();
			XML.prettyPrinting = oldPrettyPrint;
			return str;
		}
		
		public static function toNumber(a:Object):Number
		{
			if(a is Number){
				return a as Number;
			}else if(a is String){
				return parseFloat(a as String);
			}else if(a is Boolean){
				return a ? 1 : 0;
			}else 
			{ 	// if a is XMLList, XML or any other object
				// if(a is XMLList || a is XML){
				return parseFloat(toString(a));
			}
		}
		
		
		
		public static function toBoolean(a:Object):Boolean
		{
			if(a is Boolean){
				return a as Boolean;
			//}else if(a is Number){
			//	return Boolean(a);
			//}else if(a is String){
			//	return a != "";
			}else if(a is XMLList){
				return XMLList(a).length() > 0;
			}else if(a is XML){
				return true;
			}else{
				return Boolean(a);
			}
		}
	}
}