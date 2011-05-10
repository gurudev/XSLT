package memorphic.xpath
{
	import memorphic.utils.XMLUtil;
	import memorphic.xpath.model.XPathContext;
	
	public class XPathUtils
	{
		
		
		/**
		 * <p>Generates an XPath path that will find <code>toNode</code>, starting at <code>fromNode</code>.
		 * If <code>fromNode</code> is omitted then the XML root will be used as a starting point.</p>
		 * 
		 * <p>The path always uses abbreviated notation, and will be of one of the following forms:
		 * <ul><li><code>"/a[1]/b[1]c[3]"</code> for absolute paths (starting at the document root).</li>
		 * <li><code>"./a[1]/b[1]c[3]"</code> for relative paths (starting at an ancestor node of the target).</li>
		 * <li><code>"../a[1]/b[1]c[3]"</code> for relative paths (starting at a node that is not an ancestor of the target).</li>
		 * <li><code>"path1|path2|path3"</code> where the target is an XMLList of length > 1. Each pathN will be one of the forms above.</li>
		 * </ul>
		 * </p>
		 * 
		 * @param toNode Can be either XML or XMLList.
		 * @param fromNode The node to start from. Defaults to the XML root
		 * @param context Provide this if the XPathContext will affect the way the path should be built. Currently,
		 * 		that will only be if the context uses (non-standard) zero-indexed position, so you probably won't 
		 * 		need to use this argument.
		 */
		public static function findPath(toNode:*, fromNode:XML=null, context:XPathContext=null):String
		{
			var path:String = "";
			var pathPrefix:String = "";
			var currentNode:XML;
			if(toNode is XMLList){
				if(toNode.length() == 0){
					throw new ArgumentError("Argument 'toNode'cannot be an empty XMLList");
				}else{
					var firstNode:Boolean = true;
					for each(var n:XML in toNode){
						if(firstNode){
							firstNode = false;
						}else{
							path += "|";
						}
						path += findPath(n, fromNode, context);
					}
				}
			}else if(!(toNode is XML)){
				throw new ArgumentError("Argument 'toNode' must be an XML or XMLList object.");
			}
			if(fromNode == null){
				fromNode = XMLUtil.rootNode(toNode);
			}
			if(context == null){
				context = new XPathContext();
			}
			
			if(fromNode.parent() != null){
				var commonAncestor:XML = XMLUtil.commonAncestor(fromNode, toNode); 
				if(commonAncestor==null){
					throw new ArgumentError("The supplied arguments 'fromNode' and 'toNode' were not from the same XML document.");
				}
				if(commonAncestor !== fromNode.parent()){
					while(commonAncestor != fromNode.parent()) {
						pathPrefix = "../" + pathPrefix;
						fromNode = fromNode.parent();
					}
					//while(toNode.contains(fromNode));	
					if(toNode == fromNode){
						return pathPrefix + "self::node()";
					}	
				}else{
					pathPrefix = ".";
				}
			}
			if(toNode.nodeKind() == "attribute"){
				path = "/@" + toNode.name();
				currentNode = toNode.parent() as XML;
			}else if(toNode.nodeKind() == "text"){
				path = "/text()";
				currentNode = toNode.parent() as XML;
			}else if(toNode.nodeKind() == "comment"){
				path = "/comment()";
				currentNode = toNode.parent() as XML;
			}
			else{ 
				currentNode = toNode;
			}
			while(true){
				if(currentNode){
					path = "/" + currentNode.name()
						+ getPeerPositionPredicate(currentNode, context)
						+ path;
					if(currentNode == fromNode){
						break;
					}
				}else{
					throw new ArgumentError("The supplied 'fromNode' argument is not an ancestor of 'toNode'.");
				}
				currentNode = currentNode.parent();
			}
			return pathPrefix + path;
		}
		
		
		
		private static function getPeerPositionPredicate(node:XML, context:XPathContext):String
		{
			var parent:XML = node.parent();
			if(!parent){
				return "";
			}
			var peers:XMLList = node.parent()[node.name()];
			var n:int = peers.length();
			for(var i:int=0; i<n; i++){
				if(peers[i] == node){
					break;
				}
			}
			return "[" + (i + (context.zeroIndexPosition ? 0 : 1)) + "]";
		}
		
		
		
		/**
		 * 
		 * @param element to delete from it's parent
		 * 
		 * Returns true if the element was successfully deleted; otherwise false
		 */		
		public static function deleteXML(element:XML):Boolean
		{
			if(element.parent()){
				delete element.parent().children()[element.childIndex()];
				return true;
			}else{
				return false;
			}
		}
		
		/**
		 * 
		 * @param xmlList
		 * @return XMLList containing all elements that could NOT be deleted
		 * 
		 */		
		public static function deleteXMLList(xmlList:XMLList):XMLList
		{
			var notDeleted:XMLList = new XMLList();
			for each(var xml:XML in xmlList){
				if(!deleteXML(xml)){
					notDeleted +=  xml;
				}
			}
			return notDeleted;
		}
		
	}
}