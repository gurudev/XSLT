package me.rkome.da.xslt
{
	public class MEXSLTError extends Error
	{
		public function MEXSLTError()
		{
			super("XMLからオブジェクトを生成できませんでした", 0);
		}
		
		private var _xml:XML;
		public function get xml():XML
		{
			return _xml;
		}
		public function set xml(value:XML):void
		{
			_xml = value;
		}
		
		private var _node:XML
		public function get node():XML
		{
			return _node;
		}
		public function set node(value:XML):void
		{
			_node = value;
		}
		
	}
}