package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import starling.core.Starling;
	import starling.textures.TextureAtlas;
	
	[SWF(width="1024", height="768")]
	public class Main extends Sprite 
	{
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		
			stage.frameRate = 60;
			var starling:Starling = new Starling(Game, stage);
			starling.start();
			
		}
		
	}
	
}