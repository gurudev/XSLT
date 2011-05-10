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
	import memorphic.xpath.model.XPathContext;
	
	/**
	 * 
	 * @see INodeTest
	 * 
	 */ 
	final public class NameTest implements INodeTest {
		
		
		private var prefix:String;
		private var localName:String;
		
		public function NameTest(prefix:String, localName:String)
		{
			this.prefix = prefix;
			this.localName = localName;
			
		}
		
		
		/**
		 * 
		 * @param context
		 * @return true if the context node's name matches prefix and localName; otherwise false
		 * 
		 */		
		public function test(context:XPathContext):Boolean
		{
			var node:XML = context.contextNode;
			
			// only elements and attributes can have names
			if(!(node.nodeKind() == "element" || node.nodeKind() == "attribute")){
				// XXX: what about processing-instruction??
				return false;
			}
			
			// before we look at namespaces, eliminate cases where the local name is different...
			if(localName != "*" && node.localName() != localName){
				return false;
			}
			// See issue #19 (http://code.google.com/p/xpath-as3/issues/detail?id=19)
			if(localName == "*" && !prefix){
				return true;
			}
			// ...so from now on, we are just looking at namespaces
			
			// in these cases the namespace can be ignored
			if(context.openAllNamespaces || prefix=="*"){
				return true;
			}

			var nodeNsURI:String = (node.name() as QName).uri;
			
			// NOTE: This will only check that the namespace of node has the correct URI, irrespective
			// of the prefix used. The actual prefix information cannot be discovered for that
			// particular node and, if the document has multiple declarations for the same namespace, we
			// cannot distinguish between them. This should only be a problem if namespaces are used in a
			// way which fundamentally misunderstands the purpose and rationale for namespaces (ie treating
			// the prefix as the namespace, rather than as a document-local shortcut for it).
			if(prefix)
			{
				return nodeNsURI == context.getNamespaceURI(prefix);
			}
			else
			{
				// if you don't use a prefix in the XPath NameTest then you will match either the default
				// namespace or the empty namespace (which are usually the same thing).
				// We will check for the empty NS first, since getDefaultNamespaceURI() is relatively more 
				// expensive when context.useSourceNamespacePrefixes is set to true.
				return nodeNsURI == "" || nodeNsURI == context.getDefaultNamespaceURI();
			}
		}
		
	}

}