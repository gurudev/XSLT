
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
	
	final public class LocationPath implements IExpression
	{
		
		public var steps:Array; // of Step
		public var absolute:Boolean;
		
		public function LocationPath(absolute:Boolean)
		{
			steps = new Array();
			this.absolute = absolute;
		}
		
		
		private function chooseContext(node:XML):XML
		{
			return absolute ? XMLUtil.rootNode(node) : node;
		}
		
		
		
		public function selectXMLList(context:XPathContext):XMLList
		{
			var numSteps:int = steps.length;
			var step:Step;
			var result:XMLList = <></> + chooseContext(context.contextNode);
			
			// need to clone the context in case this LocationPath is part of a sub-expresssion
			// In most other places the same object can be re-used because it is modified in 
			// sequence. LocationPaths have the possibility of evaluating a whole other path
			// in between steps
			context = context.copy(false);
			
			for(var i:int=0; i<numSteps; i++){
				step = steps[i] as Step;
				result = applyStep(result, step, context);
			}
			return result;
		}
		
		public function exec(context:XPathContext):Object
		{
			return selectXMLList(context);
		}
		
		private function applyStep(nodes:XMLList, step:Step, context:XPathContext):XMLList
		{
			var result:XMLList = new XMLList();
			var n:int = nodes.length();
			context.contextSize = n;
			for(var i:int=0; i<n; i++){
				context.contextNode = nodes[i];
				context.contextPosition = i;
				result = XMLUtil.concatXMLLists(result, step.selectXMLList(context));
			}
			return result;
		}
		
	
		

	}
}