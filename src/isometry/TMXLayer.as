package isometry
{
	
	public class TMXLayer
	{
		
		public var width:int;
		public var height:int;
		public var maxGid:int;
		public var name:String;
		public var data:Vector.<int>;
		
		public function TMXLayer(width:int, height:int)
		{
			this.width = width;
			this.height = height;
			
			data = new Vector.<int>(width * height, true);
		}
		
		public function setCell(x:int, y:int, value:int):void {
			data[y * width + x] = value;
		}
		
		public function getCell(x:int, y:int):int {
			return data[y * width + x];
		}
	
	}

}