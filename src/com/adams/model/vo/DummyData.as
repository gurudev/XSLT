package com.adams.model.vo
{
	public class DummyData
	{ 
		public var name:String;
		public var ruby:String;
		public var mail:String;
		public var sex:String;
		public var age:Number;
		public var birthday:Date;
		public var married:Boolean;
		public var bloodType:String;
		public var prefecture:String;
		public var curry:String;
		
		public function setBirthday(dateString:String):void
		{
			var array:Array = dateString.split("/");
			birthday = new Date(parseInt(array[0]), parseInt(array[1]), parseInt(array[2]));
		}
		
		public function setMarried(marriedString:String):void
		{
			married = (marriedString.toLowerCase() == "yes");
		}
	}
}