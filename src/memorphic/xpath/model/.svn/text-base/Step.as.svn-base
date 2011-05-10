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
	 * [From spec]
	 * 
	 * 2.1 Location Steps
	 * 
	 * A location step has three parts:
	 * 
	 * 	- an axis, which specifies the tree relationship between the nodes selected by the location step and 
	 * 		the context node,
	 *  - a node test, which specifies the node type and expanded-name of the nodes selected by the location 
	 * 		step, and
	 * 	- zero or more predicates, which use arbitrary expressions to further refine the set of nodes selected 
	 * 		by the location step.
	 * 
	 * The syntax for a location step is the axis name and node test separated by a double colon, followed by 
	 * zero or more expressions each in square brackets. For example, in child::para[position()=1], child is 
	 * the name of the axis, para is the node test and [position()=1] is a predicate.
	 * 
	 * The node-set selected by the location step is the node-set that results from generating an initial 
	 * node-set from the axis and node-test, and then filtering that node-set by each of the predicates in turn.
	 * 
	 * The initial node-set consists of the nodes having the relationship to the context node specified by the 
	 * axis, and having the node type and expanded-name specified by the node test. For example, a location step 
	 * descendant::para selects the para element descendants of the context node: descendant specifies that each 
	 * node in the initial node-set must be a descendant of the context; para specifies that each node in the 
	 * initial node-set must be an element named para. The available axes are described in [2.2 Axes]. The 
	 * available node tests are described in [2.3 Node Tests]. The meaning of some node tests is dependent on 
	 * the axis.
	 * 
	 * The initial node-set is filtered by the first predicate to generate a new node-set; this new node-set is 
	 * then filtered using the second predicate, and so on. The final node-set is the node-set selected by the 
	 * location step. The axis affects how the expression in each predicate is evaluated and so the semantics of 
	 * a predicate is defined with respect to an axis. See [2.4 Predicates].
	 * 
	 * Location Steps
	 * 
	 * 		[4] Step ::= 
	 * 				AxisSpecifier NodeTest Predicate*	
	 * 				| AbbreviatedStep	
	 * 
	 * 		[5] AxisSpecifier ::=
	 * 				AxisName '::'	
	 * 				| AbbreviatedAxisSpecifier
	 * 
	 *  	
	 * 
	 * Since we have added constants for common use-case abbreviated syntax, all properties are private to
	 * enforce immutibility.
	 */ 
	final public class Step
	{
		
		
		public static const ABBREVIATED_DESC_OR_SELF:Step = 
			new Step(new Axis(AxisNames.DESCENDANT_OR_SELF), new NodeTypeTest(NodeTypes.NODE), null);
		
		public static const ABBREVIATED_SELF:Step = 
			new Step(new Axis(AxisNames.SELF), new NodeTypeTest(NodeTypes.NODE), null);
		
		public static const ABBREVIATED_PARENT:Step = 
			new Step(new Axis(AxisNames.PARENT), new NodeTypeTest(NodeTypes.NODE), null);
			
		public static const ABBREVIATED_CHILD:Step = 
			new Step(new Axis(AxisNames.CHILD), new NodeTypeTest(NodeTypes.NODE), null);
		
		
		private var axis:Axis;
		private var nodeTest:INodeTest;
		
		private var predicateList:PredicateList;
		
		
		public function Step(axis:Axis, nodeTest:INodeTest, predicateList:PredicateList)
		{
			this.axis = axis;
			this.nodeTest = nodeTest;
			this.predicateList = predicateList;
		}
		
		
		
		
		public function selectXMLList(context:XPathContext):XMLList
		{
			var result:XMLList;
			
			// :: Axis ::
			var nodeList:XMLList = axis.selectAxis(context);
			
			// :: NodeTest :: 
			nodeList = filterByNodeTest(nodeList, context);
			
			// :: Predicates ::
			if(predicateList == null || nodeList.length() == 0){
				result = nodeList;
			}else{
				result = predicateList.filter(nodeList, context);
			}
			
			return result;

		}
		
		
		
		private function filterByNodeTest(nodeSet:XMLList, context:XPathContext):XMLList
		{
			var result:XMLList = new XMLList();
			var axisNode:XML;
			var axisLength:int = nodeSet.length();
			
			for (var i:int=0; i<axisLength; i++){
				axisNode = nodeSet[i];
				
				// re-use the same context object
				context.contextNode = axisNode;
				context.contextPosition = i;
				context.contextSize = axisLength;
				
				if(nodeTest.test(context)){
					result += axisNode;
				}
			}	
			return result;	
		}
		
		

	}
}
	




