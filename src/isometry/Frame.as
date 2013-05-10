package isometry {
	
	public class Frame {
		public var left:Number;
		public var right:Number;
		public var bottom:Number;
		public var top:Number;
		public var width:Number;
		public var height:Number;
		public var pivotX:Number = 0;
		public var pivotY:Number = 0;
		
		public var texture:String;
		
		public function Frame(left:Number, right:Number, top:Number, bottom:Number, width:Number, height:Number) {
			this.left = left;
			this.right = right;
			this.top = top;
			this.bottom = bottom;
			this.width = width;
			this.height = height;
		}
	}

}