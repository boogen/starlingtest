package {
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import isometry.Frame;
	import isometry.TMX;
	import isometry.TMXLayer;
	import isometry.TMXTileset;
	import isometry.Utils;
	import starling.core.Starling;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.KeyboardEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	import starling.utils.HAlign;
	
	public class Game extends Sprite
	{
		// Embed the Atlas XML
		[Embed(source="../bin/hero.xml", mimeType="application/octet-stream")]
		public static const heroXml:Class;
		 
		
		[Embed(source = "../bin/iso-64x64-outside.png")]
		public static const terrainTexture:Class;
		
		[Embed(source="../bin/bigmap.tmx", mimeType="application/octet-stream")]
		public static const bigMap:Class;
		
		[Embed(source="../bin/smallmap.tmx", mimeType="application/octet-stream")]
		public static const smallMap:Class;
		
		[Embed(source = "../bin/left.png")]
		public static const leftClass:Class;
		
		[Embed(source = "../bin/right.png")]
		public static const rightClass:Class;
		
		[Embed(source = "../bin/smallmap.png")]
		public static const smallmapClass:Class;
		
		[Embed(source = "../bin/bigmap.png")]
		public static const bigmapClass:Class;		
		
		private var terrainBitmap:Bitmap;
		private var background:Sprite;
		
		private var heroLayer:Sprite;
		private var fpsCounter:int = 0;
		private var time:int = 0;
		private var heroCounter:int = 0;
		private var layers:Vector.<Sprite>;
		
		private var collisionMap:Vector.<Vector.<int>>;
		
		private var spawner:Timer;
		
		public function Game()
		{
			terrainBitmap = (new terrainTexture() as Bitmap);
			
			texture = Texture.fromBitmap(terrainBitmap);
			
			// create atlas
		
			var xml:XML = XML(new heroXml());
			heroAtlas = new TextureAtlas(texture, xml);
			heroLayer = new Sprite();
			
			layers = new Vector.<Sprite>();
		
			collisionMap = new Vector.<Vector.<int>>();
			
			spawner = new Timer(20, 0);
			spawner.addEventListener(TimerEvent.TIMER, spawnHero);
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		
		private function onAddedToStage(e:Object):void {
			Starling.current.showStats = true;
			
			var smallTexture:Texture = Texture.fromBitmap(new smallmapClass());
			small = new Image(smallTexture);
			small.x = stage.stageWidth / 2 - small.width - 10;
			small.y = (stage.stageHeight - small.height) / 2;
			small.addEventListener(TouchEvent.TOUCH, onSmallMap);
			addChild(small);
			
			var bigTexture:Texture = Texture.fromBitmap(new bigmapClass());
			big = new Image(bigTexture);
			big.x = stage.stageWidth / 2 + 10;
			big.y = (stage.stageHeight - big.height) / 2;
			big.addEventListener(TouchEvent.TOUCH, onBigMap);
			addChild(big);
			
			background = new Sprite();
		}
		
		private function onSmallMap(e:TouchEvent):void {
			var touch:Touch = e.getTouch(stage);
			if (touch && touch.phase == TouchPhase.BEGAN) {
				onMapSelected(XML(new smallMap()));
			}
		}
		
		private function onBigMap(e:TouchEvent):void 
		{
			var touch:Touch = e.getTouch(stage);
			if (touch && touch.phase == TouchPhase.BEGAN) {
				var leftTexture:Texture = Texture.fromBitmap(new leftClass());
				var left:Image = new Image(leftTexture);
				left.x = -1600;
				background.addChild(left);
				
				var rightTexture:Texture = Texture.fromBitmap(new rightClass());
				var right:Image = new Image(rightTexture);
				background.addChild(right);				
				
				onMapSelected(XML(new bigMap()));
			}
		}
		
		private function onMapSelected(mapXml:XML):void 
		{
			small.removeEventListener(TouchEvent.TOUCH, onSmallMap);
			small.parent.removeChild(small);
			big.removeEventListener(TouchEvent.TOUCH, onBigMap);
			big.parent.removeChild(big);			
			
			var xml:XML = XML(mapXml);
			var tmx:TMX = new TMX(xml);
			
			
			addChild(background);
			

			
			makeFrames(tmx);
			
			
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			
			this.stage.addEventListener(TouchEvent.TOUCH, onTouch);
			
			var gui:Sprite = new Sprite();
			addChild(gui);
			
			var rect:Quad = new Quad(100, 70, 0);
			rect.y = 35;
			gui.addChild(rect);
			
			var name:TextField = new TextField(100, 20, "Starling", "Verdana", 12, 0xffffff);
			name.hAlign = HAlign.LEFT;
			name.y = 40;
			gui.addChild(name);
			
			fps = new TextField(100, 20, "0 fps", "Verdana", 12, 0xffffff);
			fps.hAlign = HAlign.LEFT;
			fps.y = 60;
			gui.addChild(fps);
			
			heroText = new TextField(100, 20, "0 heroes", "Verdana", 12, 0xffffff);
			heroText.hAlign = HAlign.LEFT;
			heroText.y = 80;
			gui.addChild(heroText);
			
			time = getTimer();
			this.stage.addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrame);
		}
		
		private function onEnterFrame(e:EnterFrameEvent):void 
		{
			fpsCounter++;
			var t:int = getTimer();
			if (t - time > 1000) {
				var dt:int = t - time;
				fps.text = (Math.floor(10 * 1000 * fpsCounter / dt) / 10).toString() + " fps";
				time = t;
				fpsCounter = 0;
			}
			
			layers[1].mChildren.sort(compare);
		}
		
		private function compare(lhs:starling.display.DisplayObject, rhs:starling.display.DisplayObject):Number {
			return lhs.y - rhs.y;
		}
		
		private var moveEnabled:Boolean = false;
		private var touchStart:int;
		private var heroAtlas:TextureAtlas;
		private var startX:Number;
		private var startY:Number;
		private var fps:TextField;
		private var heroText:TextField;
		private var big:Image;
		private var small:Image;
		private var texture:Texture;
		
		private function onTouch(e:TouchEvent):void 
		{
			var touch:Touch = e.getTouch(this.stage);
			if (!touch) {
				return;
			}
			if (touch.phase == TouchPhase.BEGAN) {
				startX = touch.globalX;
				startY = touch.globalY;
				
				touchStart = getTimer();
				moveEnabled = true;
				
			
			
				spawner.reset();
				spawner.start();				
			}
			else if (touch.phase == TouchPhase.MOVED && moveEnabled) {
				var dx:Number = touch.globalX - touch.previousGlobalX;
				var dy:Number = touch.globalY - touch.previousGlobalY;
				
				background.x += dx;
				background.y += dy;
				
				if (Math.abs(touch.globalX - startX) > 50 || Math.abs(touch.globalY - startY) > 50) {
					spawner.reset();
				}				
			}
			else if (touch.phase == TouchPhase.ENDED) {
				moveEnabled = false;
				
				var hx:Number = touch.globalX - background.x;
				var hy:Number = touch.globalY - background.y;
				
				
				
				if (Math.abs(touch.globalX - startX) < 50 && Math.abs(touch.globalY - startY) < 50) {
					addHero(hx, hy);
				}
				
				spawner.reset();
			}
		}
		
		private function spawnHero(e:TimerEvent):void 
		{
			addHero(startX - background.x, startY - background.y);
		}		
		
		private function addHero(hx:Number, hy:Number):void 
		{
			var row:int = Utils.getRow(hx, hy);
			var col:int = Utils.getCol(hx, hy);					
			
			if (col >= 0 && row >= 0 && col < collisionMap.length && row < collisionMap[col].length && collisionMap[col][row] == 0) {
				var hero:Hero = new Hero(heroAtlas);

				var r:int = -row + col;
				var c:int = row + col;
				
				hero.x = r * 32 - hero.width / 2;
				hero.y = c * 16 + 5 - 16;
				
				layers[1].addChild(hero);
				hero.addEventListener("WALKED", onHeroWalked);
				walkHero(hero);
				
				heroCounter++;
				heroText.text = heroCounter.toString() + " heroes";
			}
		}
		
		private function onHeroWalked(e:Object):void 
		{
			var hero:Hero = e.target as Hero;
			walkHero(hero);
		}
		
		private function walkHero(hero:Hero):void {
			var row:int = Utils.getRow(hero.mapX, hero.mapY) + 1;
			var col:int = Utils.getCol(hero.mapX, hero.mapY) + 1;
			
			var moves:Vector.<Function> = new Vector.<Function>();
			
			if (col > 0 && collisionMap[col - 1][row] == 0) {
				moves.push(hero.walkUpLeft);
			}
			if (col + 1 < collisionMap.length && collisionMap[col + 1][row] == 0) {
				moves.push(hero.walkDownRight);
			}
			if (row > 0 && collisionMap[col][row - 1] == 0) {
				moves.push(hero.walkUpRight);
			}
			if (row + 1 < collisionMap[col].length && collisionMap[col][row + 1] == 0) {
				moves.push(hero.walkDownLeft);
			}
			
			if (moves.length) {
				var move:Function = moves[Math.floor(Math.random() * moves.length)];
				move();
			}
		}
		
		private function onKeyDown(e:KeyboardEvent):void {
			if (e.keyCode == Keyboard.UP) {
				background.y += 10;
			}
			else if (e.keyCode == Keyboard.DOWN) {
				background.y -= 10;
			}
			else if (e.keyCode == Keyboard.LEFT) {
				background.x += 10;
			}
			else if (e.keyCode == Keyboard.RIGHT) {
				background.x -= 10;
			}
			else if (e.keyCode == Keyboard.A) {
				background.scaleX -= 0.1;
				background.scaleY -= 0.1;
			}
			else if (e.keyCode == Keyboard.Z) {
				background.scaleX += 0.1;
				background.scaleY += 0.1;
			}

		}
		
		private function createCollisionMap(layer:TMXLayer):void {
			for (var i:int = 0; i < layer.width; ++i) {
				collisionMap.push(new Vector.<int>());
				for (var j:int = 0; j < layer.height; ++j) {
					var cell:int = layer.getCell(i, j);
					
					if (cell > 0) {
						collisionMap[i].push(1);
					}
					else {
						collisionMap[i].push(0);
					}
					
				}
				
				trace(collisionMap[i].join(" "));
			}

		}		
		
		private function makeFrames(tmx:TMX):void {
			var xml:XML = <TextureAtlas imagePath="iso-64x64-outside.png"></TextureAtlas>;
			
			
			var object:Object = { };
			
			for (var i:int = 0; i < tmx.uniqueTilesets.length; ++i) {
				var tileset:TMXTileset = tmx.uniqueTilesets[i];
				for (var j:int = 0; j < tileset.areas.length; ++j) {
					var frame:Frame = tileset.areas[j];
					var subtexture:XML = <SubTexture></SubTexture>;
					subtexture.@name = (j + tileset.firstgid).toString();
					subtexture.@x = frame.left;
					subtexture.@y = frame.top;
					subtexture.@width = frame.width;
					subtexture.@height = frame.height;

					xml.appendChild(subtexture);
				}
			}
			
			
			var atlas:TextureAtlas = new TextureAtlas(texture, xml);
			

			
			for (var k:int = 0; k < tmx.layersArray.length; ++k) {
				var tmxLayer:TMXLayer = tmx.layersArray[k]; 
				
				var layer:Sprite = new Sprite();
				layers.push(layer);
				
				var x:Number = 0;
				var y:Number = 0;
				
				if (k == 1) {
					createCollisionMap(tmxLayer);
				}				
				
				for (var i:int = 0; i < tmxLayer.width; ++i) {
					for (var j:int = 0; j <= i; ++j) {
						var row:int = i - j;
						var col:int = j;
						var cell:int = tmxLayer.getCell(col, row);
						
						if (cell > 0) {
							var texture:Texture = atlas.getTexture(cell.toString());
							var image:Image = new Image(texture);
							image.x = j * 64 - (i + 1) * 32;
							image.y = y;
							
							layer.addChild(image);

						}
						x += 64;
					}
					
					y += 16;
				}
				
				for (var i:int = tmxLayer.width - 2; i >= 0; --i) {
					for (var j:int = 0; j <= i; ++j) {
						var r:int = i - j;
						var c:int = j;
						var row:int = tmxLayer.width - 1 - c;
						var col:int = tmxLayer.width - 1 - r;
						var cell:int = tmxLayer.getCell(col, row);
						
						if (cell > 0) {
							var texture:Texture = atlas.getTexture(cell.toString());
							var image:Image = new Image(texture);
							image.x = j * 64 - (i + 1) * 32 ;
							image.y = y;
							
							layer.addChild(image);
						}
						x += 64;
					}
					y += 16;
				}
				
				background.addChild(layer);
			
			}
			
			background.x = stage.stageWidth / 2;
			background.y = (stage.stageHeight - tmx.height * 1.4 * 16) / 2;			

		}
	
	}

}