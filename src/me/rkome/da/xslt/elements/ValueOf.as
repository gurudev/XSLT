package me.rkome.da.xslt.elements
{
	import me.rkome.da.xslt.MEXSLTElement;
	import me.rkome.da.xslt.MEXSLTError;
	import me.rkome.da.xslt.util.MEXSLTUtil;
	
	import memorphic.xpath.XPathQuery;

	public class ValueOf extends MEXSLTElement
	{
		public function ValueOf()
		{
			super("valueOf");
		}
		
		[Inspectable(enumeration="assign,push,invoke", defaultValue="assign")]
		public var method:String = "assign";
		public var select:String = ".";
		public var target:String;
		public var value:* = null;
		public var defaultValue:* = null;
		public var required:Boolean = false;
		
		public override function parse(xml:XML, target:Object):void
		{
			var query:XPathQuery;
			var value:*;
			if (this.value == null)
			{
				query = new XPathQuery(this.select);
				value = query.exec(xml);
			}
			else
			{
				value = this.value;
			}

			if (value is XMLList)
			{
				if (XMLList(value).length() == 0)
				{
					if (required)
					{
						var error:MEXSLTError = new MEXSLTError();
						error.node = xml;
						throw error;
					}
					else
					{
						value = defaultValue;
					}
				}
				else
				{
					value = XML(value[0]).toString();
				}
			}

			MEXSLTUtil.methodApply(this.method, target, this.target, value, xml);
		}
	}
}