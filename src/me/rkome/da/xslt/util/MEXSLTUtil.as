package me.rkome.da.xslt.util
{
	import memorphic.xpath.XPathQuery;
	
	public class MEXSLTUtil
	{
		public static function methodApply(method:String, target:Object, property:String, value:Object, xml:XML):void
		{
			var reg:RegExp = /^(#|:)(.+)$/;
			if (reg.test(property))
			{
				reg.lastIndex = 0;
				var resultArray:Array = reg.exec(property);
				switch (String(resultArray[1]))
				{
					case "#":
						var xpath:XPathQuery = new XPathQuery(String(resultArray[2]));
						var list:XMLList = xpath.exec(xml) as XMLList;
						property = XML(list[0]).toString();
						break;
					case ":":
						var key:String = String(resultArray[2]);
						property = String(value[key]);
						break;
				}
			}
			switch (method)
			{
				case "assign":
					if (property != null && 0 < property.length)
						target[property] = value;
					else
						target = value;
					break;
				case "push":
					if (property != null && 0 < property.length)
					{
						if (!(property in target))
							target[property] = new Array();
						target[property].push(value);
					}
					else
					{
						target.push(value);
					}
					break;
				case "invoke":
					var func:Function = target[property] as Function;
					func(value);
					break;
			}
		}
		
		public static function outputApply(output:String, target:*=null):*
		{
			var instance:*;
			if (target != null)
				instance = target;
			else
				switch (output)
				{
					case "object":
						instance = new Object();
						break;
					case "array":
						instance = new Array();
						break;
					default:
						throw new Error("parse error at MEXSLTUtil.outputApply");
						break;
				}
			return instance;
		}
	}
}