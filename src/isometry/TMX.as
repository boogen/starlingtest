package isometry 
{
	import flash.utils.Dictionary;

	public class TMX 
	{
		public var orientation:String;
		public var width:int;
		public var height:int;
		public var tileWidth:int;
		public var tileHeight:int;
	
		public var layersArray:Vector.<TMXLayer>;
		public var layersHash:Dictionary;

		public var tilesets:Vector.<TMXTileset>; 
		public var uniqueTilesets:Vector.<TMXTileset>;
		public var data:XML;
	
		private var imgsURL:String;
		private var maxGid:int = 0; 
		
		public function TMX(data:XML) 
		{
			this.data = data;

			orientation = String(data.@orientation);
			if (orientation == "") {
				orientation = "isometric";
			}
			
			width = int( data.@width );
			height = int (data.@height);
			tileWidth = int (data.@tilewidth);
			tileHeight = int (data.@tileheight);
			
			parseLayers();
			parseTilesets();
		}
		
		public function getImgSrc(gid:int):String {
			return imgsURL + tilesets[gid].source.source;
		}
		
		public function getImgFrame(gid:int):int {
			return gid - tilesets[gid].firstgid
		}
		public function hasFullyLoaded():Boolean {
			for each(var tile:TMXTileset in uniqueTilesets) {
				if (tile.loaded == false) return false;
			}
			return true;
		}
		private function parseTilesets():void {
			var tileSetBlocks:XMLList = data.tileset;
			uniqueTilesets = new Vector.<TMXTileset>(tileSetBlocks.length(), true);
			tilesets = new Vector.<TMXTileset>(maxGid+1, true);
			var tileIndex:int=0;
			for each(var tileBlock:XML in tileSetBlocks) {
				var tileset:TMXTileset = uniqueTilesets[tileIndex++] = new TMXTileset(tileBlock);
			}
			var tilesetIndex:int = 0;
			for (var i:int = 1; i <= maxGid; i++) {
				var nextGid:int = (tilesetIndex < (uniqueTilesets.length - 1))?uniqueTilesets[tilesetIndex + 1].firstgid:-1;
				var tilesetReference:TMXTileset = uniqueTilesets[tilesetIndex];
				if (i == nextGid) tilesetReference = uniqueTilesets[++tilesetIndex];
				tilesets[i] = tilesetReference;
			}
			trace("done parsing tilsets");
		}

		private function parseLayers():void {
			var layerBlocks:XMLList = data.layer;
			layersArray = new Vector.<TMXLayer>(layerBlocks.length(), true);
			layersHash = new Dictionary();
			var y:int = 0;
			for each(var layerBlock:XML in layerBlocks) {
				var w:int = int(layerBlock.@width);
				var h:int = int(layerBlock.@height);
				var name:String = layerBlock.@name;
				var encoding:String = layerBlock.data.@encoding;
				var layer:TMXLayer;
				if (encoding == "base64") {
					var compression:String = layerBlock.data.@compression; 
					if (compression != "zlib" && compression.length > 0)
						throw new Error("Invalid tmx compression type: " + compression);
					layer = Base64.base64ToTMXLayer(layerBlock.data[0], w, h, compression == "zlib");
				}
				else throw new Error("Invalid tmx encoding: " + encoding);
				
				maxGid = Math.max(layer.maxGid, maxGid);
				layersArray[y++] = layer;
				layersHash[name] = layer;
				layer.name = name;
			}
		}

	}
}
