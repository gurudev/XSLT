package me.rkome.da.xslt
{
	import flash.events.EventDispatcher;
	
	import me.rkome.da.xslt.elements.Template;
	import me.rkome.da.xslt.util.MEXSLTUtil;
	
	import mx.core.IMXMLObject;

	[DefaultProperty("children")]
	public class MEXSLT extends EventDispatcher implements IMXMLObject
	{
		public function MEXSLT()
		{
			super(null);
		}
		
		public function initialized(document:Object, id:String):void
		{
		}
		
		public function parse(xml:XML):*
		{
			var ret:*;
			ret = MEXSLTUtil.outputApply(this.output, target);
			for each (var mexslt:Template in this.xslt)
			{
				try
				{
					mexslt.parse(xml, ret);
				}
				catch (e:MEXSLTError)
				{
					e.xml = xml;
					throw e;
				}
			}
			return ret;
		}
		
		public function callTemplate(name:String, xml:XML):*
		{
			var ret:*;
			ret = MEXSLTUtil.outputApply(this.output, target);
			for each (var mexslt:Template in this.xslt)
			{
				if (mexslt.name == name)
				{
					mexslt.parse(xml, ret);
					break;
				}
			}
			return ret;
		}
		
		[Inspectable(enumeration="object,array", defaultValue="object")]
		public var output:String = "object";
		
		[ArrayElementType("me.rkome.da.xslt.elements.Template")]
		public var xslt:Array;
		
		public var target:* = null;
	}
}