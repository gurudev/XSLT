package me.rkome.da.xslt.elements
{
	import me.rkome.da.xslt.MEXSLTElement;
	import me.rkome.da.xslt.MEXSLTNode;
	
	import memorphic.xpath.XPathQuery;

	public class Template extends MEXSLTNode
	{
		public function Template()
		{
			super("template");
		}

		public var name:String;
		
		private var _match:String;
		public function get match():String
		{
			return _match;
		}
		public function set match(value:String):void
		{
			_match = value;
		}
		
		public override function parse(xml:XML, target:Object):void
		{
			var xpath:XPathQuery = new XPathQuery(_match);
			var list:XMLList = xpath.exec(xml);
			for each (var node:XML in list)
			{
				for each (var child:MEXSLTElement in children)
				{
					child.parse(node, target);
				}
			}
		}
	}
}