package ru.codestage.fpresent.effects
{
	import com.genome2d.components.GTransform;
	import com.genome2d.components.renderables.GSprite;
	import com.genome2d.context.GBlendMode;
	import com.genome2d.core.Genome2D;
	import com.genome2d.core.GNodeFactory;
	import com.genome2d.textures.factories.GTextureAtlasFactory;
	import com.genome2d.textures.GTextureAtlas;
	import com.greensock.TimelineLite;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.junkbyte.console.Cc;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	import ru.codestage.utils.NumUtil;
	
	/**
	 * ...
	 * @author Dmitriy [focus] Yukhanov
	 */
	public final class FallEffect extends BaseEffect
	{
		private var _piecesSheet:GTextureAtlas;
		private var _pieces:Vector.<ImagePiece>;
		private var _piecesCount:uint;
		
		public function FallEffect(displayObject:DisplayObject, bd:BitmapData)
		{
			super(displayObject, bd);
		}
		
		protected override function hide():void
		{
			super.hide();
			//var time:uint = getTimer();
			_splitBitmap(EffectsSettings.fallEffectParticlesXCount, EffectsSettings.fallEffectParticlesYCount);
			//Cc.log("Split time: " + String(getTimer() - time));
			_startSym();
		}
		
		private function _splitBitmap(particlesCountX:uint, particlesCountY:uint):void
		{
			var blockXSize:Number = _textureWidth / particlesCountX;
			var blockYSize:Number = _textureHeight / particlesCountY;
			
			var realBlockWidth:Number;
			var realBlockHeight:Number;
			
			var regions:Vector.<Rectangle> = new Vector.<Rectangle>();
			var piecesIDs:Vector.<String> = new Vector.<String>();
			
			var i:uint;
			
			for (var sy:Number = 0; sy < _textureHeight; sy += blockYSize)
			{
				if (sy + blockYSize <= _textureHeight)
				{
					realBlockHeight = blockYSize;
				}
				else
				{
					realBlockHeight = _textureHeight - sy;
				}
				
				for (var sx:Number = 0; sx < _textureWidth; sx += blockXSize)
				{
				
					if (sx + blockXSize <= _textureWidth)
					{
						realBlockWidth = blockXSize;
					}
					else
					{
						realBlockWidth = _textureWidth - sx;
					}
					
					regions[i] = new Rectangle(sx, sy, realBlockWidth, realBlockHeight);
					piecesIDs[i] = String(i);
					i++
				}
				
			}
			
			_piecesSheet = GTextureAtlasFactory.createFromBitmapDataAndRegions("pieces", _bd, regions, piecesIDs);
			
			var leni:uint = i;
			i = 0;
			
			_pieces = new Vector.<ImagePiece>();
			
			var doX:Number = _displayObject.x;
			var doY:Number = _displayObject.y;
			
			var accMinX:Number;
			var accMaxX:Number;

			var accMinY:Number;
			var accMaxY:Number;
			
			var movementDirections:Vector.<String> = new <String>["left","right","top","bottom","random"];
			var direction:String = movementDirections[int(Math.random() * 5)];
			
			if (direction == "right") 
			{
				accMinX = -000000000.1;
				accMaxX = 000000000.8;
				
				accMinY = -000000000.1;
				accMaxY = 000000000.1;
			}
			else if (direction == "left") 
			{
				accMinX = 000000000.1;
				accMaxX = -000000000.8;
				
				accMinY = -000000000.1;
				accMaxY = 000000000.1;
			}
			else if (direction == "bottom") 
			{
				accMinX = -000000000.2;
				accMaxX = 000000000.2;
				
				accMinY = 000000000.1;
				accMaxY = -000000000.8;
			}
			else if (direction == "top") 
			{
				accMinX = -000000000.2;
				accMaxX = 000000000.2;
				
				accMinY = -000000000.1;
				accMaxY = 000000000.8;
			}
			else // random
			{
				accMinX = -000000000.2;
				accMaxX = 000000000.2;
				
				accMinY = -000000000.2;
				accMaxY = 000000000.2;
			}
			
			for (i = 0; i < leni; i++ )
			{
				var region:Rectangle = regions[i];
				
				var imagePiece:ImagePiece = new ImagePiece(_piecesSheet.getTexture(piecesIDs[i]), doX + region.x + region.width / 2, doY + region.y + region.height / 2, Math.random() * (accMaxX - accMinX) + accMinX,Math.random() * (accMaxY - accMinY) + accMinY);
				_pieces[i] = imagePiece;
			}
			
			_piecesCount = leni;
			
			regions.length = 0;
			piecesIDs.length = 0;
			
			Cc.info("GSprites: " + String(leni));
		}
		
		private function _startSym():void
		{
			_genome.stage.addEventListener(Event.ENTER_FRAME, _onUpdate);
			TweenLite.delayedCall(1, _onEffectComplete);
		}
		
		private function _onUpdate(e:Event):void 
		{
			//var time:uint = getTimer();
			_genome.beginRender();
			
			var i:uint;
			var len:uint = _piecesCount;
			
			for (i = 0; i < len; i++ )
			{
				var piece:ImagePiece = _pieces[i];
				piece.accX *= 1.01;
				piece.accY *= 1.01;
				piece.speedX += piece.accX;
				piece.speedY += piece.accY;
				piece.x += piece.speedX;
				piece.y += piece.speedY;
				
				_genome.blit(piece.x, piece.y, piece.texture);
			}
			
			_genome.render();
			_genome.endRender();
			//Cc.add("Render time: " + String(getTimer() - time),2,true);
		}
		
		private function _onEffectComplete():void
		{
			EffectsManager.instance.showShade(_uninit);
		}
		
		public override function terminate():void
		{
			if (_genome.stage.hasEventListener(Event.ENTER_FRAME))
			{
				_onEffectComplete();
			}
			else
			{
				super.terminate();
			}
		}
		
		protected override function _uninit():void
		{
			_genome.stage.removeEventListener(Event.ENTER_FRAME, _onUpdate);
			TweenMax.killAll();
			
			var leni:uint = _pieces.length;
			var i:uint;
			
			for (i = 0; i < leni; i++ )
			{
				_pieces[i].texture.dispose();
			}
			
			_pieces.length = 0;
			_pieces = null;
			
			_piecesSheet.dispose();
			_piecesSheet = null;
			
			_genome.beginRender();
			_genome.render();
			_genome.endRender();
			
			super._uninit();
		}
	}

}