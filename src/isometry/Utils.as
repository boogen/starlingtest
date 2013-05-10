package isometry 
{

	public class Utils 
	{
		
		public static function getRow(x:Number, y:Number):int
		{
			return Math.round( -0.016 * x + 0.031 * y) - 1;
		}
		
		public static function getCol(x:Number, y:Number):int 
		{
			return Math.round(  0.016 * x + 0.031 * y) - 1;
		}
		
	}

}