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

package memorphic.xpath
{

	import memorphic.xpath.model.QueryRoot;
	import memorphic.xpath.model.XPathContext;
	import memorphic.xpath.parser.XPathParser;

	/**
	 *
	 */
	public class XPathQuery
	{

		private var __path:String;

		private var expression:QueryRoot;


		public static var defaultContext:XPathContext = new XPathContext();


		/**
		 *
		 */
		public var context:XPathContext;




		/**
		 * The XPath query to execute
		 */
		public function get path():String
		{
			return __path;
		}
		public function set path(src:String):void
		{
			if(src != __path){
				__path = src;
				expression = getParser().parseXPath(src);
			}
		}



		/**
		 *
		 * @param path The XPath statement that will be executed when you call <code>exec</code>
		 *
		 */
		public function XPathQuery(path:String, context:XPathContext=null)
		{
			this.path = path;
			if(context == null){
				this.context = defaultContext.copy(true);
			}else{
				this.context = context;
			}
		}


		/**
		 *
		 * Convenience method. Executes an XPath query on a context.
		 * If you plan to execute the same XPath query multiple times, it is more efficient to create an instance of
		 * <code>XPathQuery</code> and call <code>exec</code> each time, to prevent the path string being parsed
		 * each time.
		 * 
		 * The node may be the root node of an XML document or
		 * any other XML node. If the node is not the root then relative paths will be evaluated
		 * relative to that node; however, absolute paths will still be evaluated from the root of
		 * the document to which the node belongs.
		 *
		 * @param xml The root document or XML node on which to execute the XPath query
		 * @param path The XPath query string
		 *
		 * @return The result of executing the XPath statement. If the statement is a Path expression, this will be an XMLList
		 *
		 */
		public static function execQuery(xml:XML, path:String):*
		{
			var query:XPathQuery = new XPathQuery(path);
			return query.exec(xml);

		}


		/**
		 * Execute an XML query on an XML node. The node may be the root node of an XML document or
		 * any other XML node. If the node is not the root then relative paths will be evaluated
		 * relative to that node; however, absolute paths will still be evaluated from the root of
		 * the document to which the node belongs.
		 * 
		 * <strong>Important</strong>: When using the result of another expression as the document, you should ensure to
		 * also set <code>startingNode</code> to that element. Otherwise, if the other expressions selects the root element, relative 
		 * paths may not be evaluated correctly.
		 * 
		 * @param xml The root document or XML node on which to execute the XPath query
		 * @param startingNode An optional XML node, which should be part of the xml document. Relative paths will begin at this element.
		 *
		 * @return The result of executing the XPath statement. If the statement is a Path expression, this will be an XMLList
		 *
		 */
		public function exec(xml:XML, startingNode:XML=null):*
		{
			return expression.execRoot(xml, startingNode, context);
		}




		private static function getParser():XPathParser
		{
			// TODO: cache the parser (probably weakly), but some tricky testing is required to make sure it doesn't have side-effects
			var parser:XPathParser;
			//for each(parser in parserLimbo){
			//
			//	return parser;
			//}
			parser = new XPathParser();
			//parserLimbo[parser] = true;
			return parser;
		}




	}
}