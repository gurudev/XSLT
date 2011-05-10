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
	 * 
	 * A filter expression is any expression that may return a node-set, but is not a LocationPath.
	 * If there are no predicates then there is no point treating this differently from another
	 * expression. In fact, the presence of predicates is the only way we can tell that we need to
	 * use a FilterExpr at all. So, while this class is named FilterExpr for consistency with the
	 * spec, it is really a PredicatedExpression - or something like that anyway...
	 */ 
	final public class FilterExpr implements IExpression
	{
		
		private var primaryExpr:IExpression;
		private var predicateList:PredicateList;
		
		
		
		public function FilterExpr(primaryExpr:IExpression, predicateList:PredicateList)
		{
			this.primaryExpr = primaryExpr;
			this.predicateList = predicateList;
		}
		
		public function selectXMLList(context:XPathContext):XMLList
		{
			
			var result:XMLList = primaryExpr.exec(context) as XMLList;
			
			if(predicateList != null && result.length() > 0){
				result = predicateList.filter(result, context);
			}
			return result;
			
		}
		
		public function exec(context:XPathContext):Object
		{	
			return selectXMLList(context);
		}
		
	

		
	}
}