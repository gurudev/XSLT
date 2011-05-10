package me.rkome.da.xslt
{
	[DefaultProperty("children")]
	public class MEXSLTNode extends MEXSLTElement
	{
		public function MEXSLTNode(type:String)
		{
			super(type);
		}

		private var _children:Array = null;
		[ArrayElementType("me.rkome.da.xslt.MEXSLTElement")]
		public function get children():Array
		{
			return _children;
		}
		public function set children(value:Array):void
		{
			_children = value;
		}
	}
}