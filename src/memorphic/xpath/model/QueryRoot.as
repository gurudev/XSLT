package memorphic.xpath.model
{
	import memorphic.utils.XMLUtil;
	
	final public class QueryRoot
	{
		
		private namespace tmpRootNS = "http://www.memorphic.com/ns/2007/xpath-as3#tmpRoot";
		private const tmpRootLocalName:String = "document-root";
		
		private var expr:IExpression;


		public function QueryRoot(rootExpr:IExpression)
		{
			expr = rootExpr;
		}
		
		public function execRoot(xml:XML, startingNode:XML, context:XPathContext):Object
		{
			var xmlRoot:XML
			var contextNode:XML;
			// xpath requires root "/" to be the document root, which is not represented in e4x, so we
			// have to wrap it in a temporary root node. 
			var docRoot:XML;
			var rootWrapped:Boolean = false;
			if(xml != null){
				xmlRoot = XMLUtil.rootNode(xml);
				
				// Make sure it isn't already wrapped. This could happen if a custom xpath function executes
				// another Xpath query on the same XML object 
				if(xmlRoot.localName() == tmpRootLocalName && xmlRoot.namespace() == tmpRootNS){
					docRoot = xmlRoot;
				}else{
					docRoot = <{tmpRootLocalName}/>;
					// namespace must be added after, otherwise it contaminates toXMLString() for child nodes (AS3 bug?)
					docRoot.setNamespace(tmpRootNS);
					docRoot.appendChild(xmlRoot);
					rootWrapped = true;
				}
				if(startingNode!=null){
					contextNode = startingNode;
				}else if(xml == xmlRoot){
					contextNode = docRoot;
				}else{
					contextNode = xml;
				}		
			}else{
				// use an empty XML object instead of null, to reduce RTE's
				contextNode = new XML();
			} 
			
			context.contextNode = contextNode;
			context.contextPosition = 0;
			context.contextSize = 1;
		
			try{
				var result:Object = expr.exec(context);
			}finally{
				if(rootWrapped){
					// remove the wrapper if we added it
					delete docRoot.children()[0];
				}				
			}		
			return result;
		}
	}
}