package isometry 
{
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	public class TMXTileset 
	{

		public var firstgid:int;
		public var name:String;
		public var tileWidth:int;
		public var tileHeight:int;
		
		public var source:TMXSource;
		public var loaded:Boolean;
		
		private var tileProperties:Object = { };
		
		public var areas:Vector.<Frame>;
		
		public function TMXTileset(data:XML) 
		{
			firstgid = int(data.@firstgid);
			name = data.@name;
			tileWidth = int(data.@tilewidth);
			tileHeight = int(data.@tileheight);
			source = new TMXSource( XML( data.image[0] ) );

			areas = new Vector.<Frame>();
			for (var y:int = 0; y < source.height; y += tileHeight) {
				for (var x:int = 0; x < source.width; x += tileWidth) {
					var frame:Frame = new Frame(x, x + tileWidth, y, y + tileHeight, tileWidth, tileHeight);
					areas.push(frame);
				}
			}
			
			var tilePropBlocks:XMLList = data.elements('tile');
			for each(var tilePropBlock:XML in tilePropBlocks) {
				var id:String = tilePropBlock.@id;
				var propBlocks:XMLList = tilePropBlock.properties[0].elements('property');
				for each(var prop:XML in propBlocks) {
					var name:String = prop.@name.toString();
					var val:String = prop.@name.toString();
					if (tileProperties[ id ] == null) tileProperties[ id ] = {};
					tileProperties[ id ][ name ] = val;
				}
			}
		}
		public function getProps(gid:int):Object {
			return getPropsByID(int(gid - firstgid).toString());
		}
		public function getPropsByID(id:String):Object {
			var val:Dictionary = tileProperties[ id ];
			return val?val:{};
		}
	}

}
