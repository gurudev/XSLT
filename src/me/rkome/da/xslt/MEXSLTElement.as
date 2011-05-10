package me.rkome.da.xslt
{
	public class MEXSLTElement
	{
		private var _type:String;

		public function MEXSLTElement(type:String)
		{
			_type = type;
		}

		public function get type():String
		{
			return _type;
		}

		public function parse(xml:XML, target:Object):void
		{
		}
		
	}
}