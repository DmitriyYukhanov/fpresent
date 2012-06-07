package ru.codestage.fpresent.effects 
{
	import com.genome2d.textures.GTexture;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Dmitriy [focus] Yukhanov
	 */
	public final class ImagePiece 
	{
		public var texture:GTexture;
		public var x:Number;
		public var y:Number;
		public var speedX:Number = 0;
		public var speedY:Number = 0;
		public var accX:Number;
		public var accY:Number;
		public var rotation:Number = 0;
		
		public function ImagePiece(texture:GTexture, posX:Number, posY:Number, accX:Number = 0, accY:Number = 0) 
		{
			this.x = posX;
			this.y = posY;
			
			this.accX = accX;
			this.accY = accY;
			
			this.texture = texture;
		}
	}

}