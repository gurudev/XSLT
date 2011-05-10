package me.rkome.da.xslt.elements
{
	import me.rkome.da.xslt.MEXSLTElement;
	import me.rkome.da.xslt.MEXSLTNode;
	import me.rkome.da.xslt.util.MEXSLTUtil;
	
	import mx.core.ClassFactory;

	public class New extends MEXSLTNode
	{
		public function New()
		{
			super("new");
		}
		
		[Inspectable(enumeration="assign,push,invoke", defaultValue="assign")]
		public var method:String = "assign";
		public var target:String;
		private var _instance:Class;
		private var _factory:ClassFactory;
		
		public override function parse(xml:XML, target:Object):void
		{
			if (product == null)
				throw new Error("生成するクラスが指定されていません at me.rkome.da.xslt.element.New");
			var createdInstance:* = _factory.newInstance();
			for each (var child:MEXSLTElement in this.children)
			{
				child.parse(xml, createdInstance);
			}
			MEXSLTUtil.methodApply(method, target, this.target, createdInstance, xml);
		}
		
		public function get product():Class
		{
			return _instance;
		}
		public function set product(value:Class):void
		{
			_instance = value;
			_factory = new ClassFactory(_instance);
		}
	}
}