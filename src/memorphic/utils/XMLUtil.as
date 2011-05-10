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

package memorphic.utils
{
	import flash.utils.Dictionary;
	
	public class XMLUtil
	{
		
		
		public static function rootNode(node:XML):XML
		{
			var p:XML = node;
			while(p = p.parent()){
				node = p;
			}
			return node;
		}
		
		
		
		public static function concatXMLLists(a:XMLList, b:XMLList):XMLList
		{
			for each(var node:XML in b){
			//	if(!a.contains(node)){
			//		a += node;
			//	}
				if(!contains(a, node)){
					a += node;
				}
			
			}
			return a;
		}
		
		
		/**
		 * @param a May be XML or XMLList
		 */
		public static function contains(a:*, b:XML):Boolean
		{
			for each(var x:XML in a){
				if(x === b){
					return true;
				}
			}
			return false;
		}
		
		
		
		public static function insertChildAtIndex(parent:XML, child:XML, index:int):int
		{
			var prevSibling:XML = null;
			if(parent.hasComplexContent() && index > 0){
				prevSibling = parent.children()[index-1];
			} // otherwise prevSibling is null, so it will be inserted as first child
			parent.insertChildAfter(prevSibling, child);
			return parent.children().length();
		}
		
		
		/**
		 * Replacement for builtin (broken?) XML.contains() method
		 */
		public static function elementIsAncestorOf(element:XML, child:XML):Boolean
		{
			var p:XML = child;
			while((p=p.parent())){
				if(p === element){
					return true;
				}
			}
			return false;
		}
		
		
		public static function commonAncestor(node1:XML, node2:XML):XML
		{
			var node1Ancestors:Array = new Array();
			var p:XML = node1;
			// first make a list of all of node1's ancestors
			while((p=p.parent())){
				node1Ancestors.push(p);
			}
			p = node2;
			// then compare node2's ancestors in order
			while((p=p.parent())){
				if(node1Ancestors.indexOf(p) > -1){
					return p;
				}
			}
			return null;
		}
	}
}