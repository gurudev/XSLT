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
	
	/**
	 * 2.3 Node Tests
	 * 
	 * Every axis has a principal node type. If an axis can contain elements, then the principal node type is element; 
	 * otherwise, it is the type of the nodes that the axis can contain. Thus,
	 * 	- For the attribute axis, the principal node type is attribute.
	 *  - For the namespace axis, the principal node type is namespace.
	 *  - For other axes, the principal node type is element.
	 * 
	 * A node test that is a QName is true if and only if the type of the node (see [5 Data Model]) is the principal 
	 * node type and has an expanded-name equal to the expanded-name specified by the QName. For example, child::para 
	 * selects the para element children of the context node; if the context node has no para children, it will select 
	 * an empty set of nodes. attribute::href selects the href attribute of the context node; if the context node has 
	 * no href attribute, it will select an empty set of nodes.
	 * 
	 * A QName in the node test is expanded into an expanded-name using the namespace declarations from the expression 
	 * context. This is the same way expansion is done for element type names in start and end-tags except that the 
	 * default namespace declared with xmlns is not used: if the QName does not have a prefix, then the namespace URI 
	 * is null (this is the same way attribute names are expanded). It is an error if the QName has a prefix for which
	 * there is no namespace declaration in the expression context.
	 * 
	 * A node test * is true for any node of the principal node type. For example, child::* will select all element 
	 * children of the context node, and attribute::* will select all attributes of the context node.
	 * 
	 * A node test can have the form NCName:*. In this case, the prefix is expanded in the same way as with a QName, 
	 * using the context namespace declarations. It is an error if there is no namespace declaration for the prefix in 
	 * the expression context. The node test will be true for any node of the principal type whose expanded-name has 
	 * the namespace URI to which the prefix expands, regardless of the local part of the name.
	 * 
	 * The node test text() is true for any text node. For example, child::text() will select the text node children of 
	 * the context node. Similarly, the node test comment() is true for any comment node, and the node test 
	 * processing-instruction() is true for any processing instruction. The processing-instruction() test may have an 
	 * argument that is Literal; in this case, it is true for any processing instruction that has a name equal to the 
	 * value of the Literal.
	 * 
	 * A node test node() is true for any node of any type whatsoever.
	 * 
	 * 		[7] NodeTest ::=   
	 * 					NameTest	
	 * 					| NodeType '(' ')'	
	 * 					| 'processing-instruction' '(' Literal ')'	
	 * 
	 * @see NameTest
	 * @see NodeTypeTest
	 * 
	 */
	public interface INodeTest
	{
		
		function test(context:XPathContext):Boolean;	
	}
}