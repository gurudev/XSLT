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
	
	final public class PathExpr implements IExpression
	{
		
		
		private var filterExpr:IExpression;
		private var locationPath:LocationPath;
		
		public function PathExpr(filterExpr:IExpression, path:LocationPath)
		{
			this.filterExpr = filterExpr;
			this.locationPath = path;
		}
		
		public function exec(context:XPathContext):Object
		{
			return selectXMLList(context);
		}
		
		public function selectXMLList(context:XPathContext):XMLList
		{
			var result:XMLList = new XMLList();
			var filterExprResult:XMLList = XMLList(filterExpr.exec(context));
			var len:int = filterExprResult.length();
			context.contextSize = len;
			for(var i:int=0; i<len; i++){
				context.contextNode = filterExprResult[i];
				context.contextPosition = i;
				result = XMLUtil.concatXMLLists(result, locationPath.selectXMLList(context));
			}
			
			return result;
		}
		
	}
}