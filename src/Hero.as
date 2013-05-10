package  
{

	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.TextureAtlas;

	public class Hero extends Sprite
	{
		private var animation:MovieClip;
		private var upLeft:MovieClip;
		private var upRight:MovieClip;
		private var downLeft:MovieClip;
		private var downRight:MovieClip;
		
		public function Hero(atlas:TextureAtlas) {
			
			upLeft = new MovieClip(atlas.getTextures("hero_up_left_"));
			upLeft.y = 32;
			upRight = new MovieClip(atlas.getTextures("hero_up_right_"));
			upRight.y = 32;
			
			downRight = new MovieClip(atlas.getTextures("hero_down_right_"));
			downRight.y = 32;
			downLeft = new MovieClip(atlas.getTextures("hero_down_left_"));
			downLeft.y = 32;
			
			addChild(upLeft);
		}
		
		public function play():void 
		{
			animation.play();
		}
		
		public function walkUpLeft():void {
			setAnimation(upLeft);	
			
			var t:Tween = new Tween(this, 0.5, Transitions.LINEAR);
			t.animate("x", x - 32);
			t.animate("y", y - 16);
			t.onComplete = onWalked;
			
			Starling.juggler.add(t);
		}
		
		public function walkUpRight():void {
			setAnimation(upRight);
			
			var t:Tween = new Tween(this, 0.5, Transitions.LINEAR);
			t.animate("x", x + 32);
			t.animate("y", y - 16);
			t.onComplete = onWalked;
			
			Starling.juggler.add(t);						
		}
		
		public function walkDownRight():void {
			setAnimation(downRight);
			
			var t:Tween = new Tween(this, 0.5, Transitions.LINEAR);
			t.animate("x", x + 32);
			t.animate("y", y + 16);
			t.onComplete = onWalked;
			
			Starling.juggler.add(t);						
		}
		
		public function walkDownLeft():void {
			setAnimation(downLeft);
			
			var t:Tween = new Tween(this, 0.5, Transitions.LINEAR);
			t.animate("x", x - 32);
			t.animate("y", y + 16);
			t.onComplete = onWalked;
			
			Starling.juggler.add(t);							
		}
		
		public function onWalked():void 
		{
			dispatchEvent(new Event("WALKED"));
		}
		
		public function get mapX():Number
		{
			return x + width / 2;
		}
		
		public function get mapY():Number
		{
			return y - 5 + 16;
		}		
		
		private function setAnimation(value:MovieClip):void {
			if (animation != value) {
				if (animation) {
					if (animation.parent) {
						animation.parent.removeChild(animation);
					}
					Starling.juggler.remove(animation);
				}
				
				animation = value;
				addChild(animation);
				animation.play();
				Starling.juggler.add(animation);
			}
		}

		
	
		
	}

}