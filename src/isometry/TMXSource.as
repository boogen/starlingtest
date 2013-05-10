package isometry 
{

	public class TMXSource 
	{
		public var source:String;
		public var width:int;
		public var height:int;
		
		public function TMXSource(element:XML) 
		{
			source = element.@source;
			width = int(element.@width);
			height = int(element.@height);
		}
	}

}
