package ru.codestage.fpresent.effects 
{
	import com.genome2d.context.GBlendMode;
	import com.genome2d.textures.factories.GTextureAtlasFactory;
	import com.genome2d.textures.factories.GTextureFactory;
	import com.genome2d.textures.GTextureAtlas;
	import com.greensock.easing.Circ;
	import com.greensock.easing.Quart;
	import com.greensock.plugins.ColorMatrixFilterPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.TimelineLite;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.junkbyte.console.Cc;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.System;
	import flash.utils.getTimer;
	import nape.geom.AABB;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyList;
	import nape.phys.BodyType;
	import nape.phys.InertiaMode;
	import nape.phys.MassMode;
	import nape.phys.Material;
	import nape.shape.Circle;
	import nape.shape.Polygon;
	import nape.space.Broadphase;
	import nape.space.Space;
	import nape.util.BitmapDebug;
	import nape.util.Debug;
	import ru.codestage.utils.NumUtil;

	/**
	 * ...
	 * @author Dmitriy [focus] Yukhanov
	 */
	public final class CrashEffect extends BaseEffect 
	{
		private static var _napeSpace:Space;
		private static var _ground:Body;
		
		private const _pooling:Boolean = true;
		private const _debug:Boolean = false;
		private const _bulletDirections:Vector.<String> = new <String>["left", "right", "top", "bottom"];
		
		private var _bulletRadius:Number;
		
		private var _stepLength:Number = 1 / 60;
		
		private var _bullet:Body;
		private var _origBulletPos:Number;
		private var _napeBodies:BodyList;
		private var _napeDebug:BitmapDebug;
		
		private var _piecesSheet:GTextureAtlas;
		private var _pieces:Vector.<ImagePiece>;
		private var _piecesCount:uint;
		
		[Embed(source = "../../../../assets/cannonball.png")]
		private static var BulletBmp:Class;
		
		
		public function CrashEffect(displayObject:DisplayObject, bd:BitmapData) 
		{
			super(displayObject, bd);
		}
		
		protected override function hide():void
		{
			
			//_bulletRadius = NumUtil.randomRange(textureWidth/10,textureWidth/20);
			_bulletRadius = 40;
			
			_startNape();
			
			super.hide();
		}
		
		private function _startNape():void 
		{
			_makeNapeSpace();
			
			var particlesX:uint = NumUtil.randomRange(EffectsSettings.crashEffectParticlesXMax, EffectsSettings.crashEffectParticlesXMin);
			var particlesY:uint = NumUtil.randomRange(EffectsSettings.crashEffectParticlesYMax, EffectsSettings.crashEffectParticlesYMin);
			
			_splitBitmap(particlesX, particlesY);
			
			_startSym();
			/*var t:Number = getTimer();
			Cc.log("_splitBitmap time: " + String(getTimer() - t));*/
		}
		
		private function _makeNapeSpace():void
		{
			if (_pooling && _napeSpace)
			{
				_napeSpace.gravity = Vec2.weak(0, 0);
			}
			else
			{
				_napeSpace = new Space(Vec2.weak(0, 0), Broadphase.SWEEP_AND_PRUNE);
				_napeSpace.sortContacts = false;
				
				//_ground = new Body(BodyType.STATIC);
			}
			_napeSpace.sortContacts = false;
			
			/*_ground.shapes.clear();
			_ground.shapes.add(new Polygon(Polygon.rect(_displayObject.x, _displayObject.y + _textureHeight, _textureWidth, 50)));
			_ground.space = _napeSpace;*/
				
			if (_debug)
			{
				_napeDebug = new BitmapDebug(_stageWidth,_stageHeight,0x333333);
				_napeDebug.drawShapeDetail = true;
				_napeDebug.drawBodyDetail = true;
				_napeDebug.drawBodies = true;
				_displayObject.parent.addChildAt(_napeDebug.display,0);
			}
			
		}
		
		private function _splitBitmap(particlesCountX:uint, particlesCountY:uint):void
		{
			var blockXSize:Number = _textureWidth / particlesCountX;
			var blockYSize:Number = _textureHeight / particlesCountY;
			
			var realBlockWidth:Number;
			var realBlockHeight:Number;
			
			var regions:Vector.<Rectangle> = new Vector.<Rectangle>();
			var piecesIDs:Vector.<String> = new Vector.<String>();
			
			var mat:Material = Material.glass();
			
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
					i++;
				}
				
			}
			
			_piecesSheet = GTextureAtlasFactory.createFromBitmapDataAndRegions("pieces", _bd, regions, piecesIDs);
			
			var leni:uint = i;
			i = 0;
			
			_pieces = new Vector.<ImagePiece>();
			
			var doX:Number = _displayObject.x;
			var doY:Number = _displayObject.y;
			
			var realX:Number;
			var realY:Number;
			
			for (i = 0; i < leni; i++ )
			{
				var region:Rectangle = regions[i];
				
				realX = doX + region.x;
				realY = doY + region.y;
				
				var imagePiece:ImagePiece = new ImagePiece(_piecesSheet.getTexture(piecesIDs[i]), realX, realY);
				_pieces[i] = imagePiece;
				
				var slice:Body = new Body(BodyType.DYNAMIC, Vec2.weak(realX, realY));
				slice.shapes.add(new Polygon(Polygon.rect(0, 0, region.width, region.height), mat));
				//slice.userData = slice.localCOM.mul(-1);
				//slice.align();
				slice.graphic = imagePiece;
				slice.graphicUpdate = _onSliceUpdate;
				slice.space = _napeSpace;
				//slice.gravMass = 10;
			}
			
			_piecesCount = leni;
			
			regions.length = 0;
			piecesIDs.length = 0;
			
			Cc.info("Phys-enabled GSprites: " + String(leni));
		}
		
		private function _startSym():void 
		{
			
			/*_imageVisibleBeforeEffect.removeFromParent(true);
			_imageVisibleBeforeEffect = null;*/
			_napeBodies = _napeSpace.bodies;
			
			_genome.stage.addEventListener(Event.ENTER_FRAME, _mainLoop);
			TweenLite.delayedCall(1, _onEffectComplete);
			
			var bulletPosition:Vec2 = Vec2.weak();
			var bulletVelocity:Vec2;
			var angularVel:Number;
			
			var direction:String = _bulletDirections[int(Math.random() * _bulletDirections.length)];
			
			if (direction == "right") // from left
			{
				bulletPosition.x = -_bulletRadius * 2 - 100;
				bulletPosition.y = NumUtil.randomRange(_textureHeight + _displayObject.y - _bulletRadius * 4, _displayObject.y + _bulletRadius * 4);
				
				bulletVelocity = Vec2.weak(NumUtil.randomRange(3700, 3000), NumUtil.randomRange(_textureHeight/2, -_textureHeight/2));
				
				//angularVel = NumUtil.randomRange(40, 10);
			}
			else if (direction == "left") // from right
			{
				bulletPosition.x = _bulletRadius * 2 + _stageWidth + 100;
				bulletPosition.y = NumUtil.randomRange(_textureHeight + _displayObject.y - _bulletRadius * 4, _displayObject.y + _bulletRadius * 4);
				
				bulletVelocity = Vec2.weak(-NumUtil.randomRange(3700, 3000), NumUtil.randomRange(_textureHeight/2, -_textureHeight/2));
				
				//angularVel = -NumUtil.randomRange(40, 10);
			}
			else if (direction == "bottom") // from top
			{
				bulletPosition.x = NumUtil.randomRange(_textureWidth + _displayObject.x - _bulletRadius*4, _displayObject.x + _bulletRadius*4);
				bulletPosition.y = -_bulletRadius * 2 - 100;
				bulletVelocity = Vec2.weak(NumUtil.randomRange(_textureWidth/2, -_textureWidth/2), NumUtil.randomRange(3700, 3000));
				
				//angularVel = NumUtil.randomRange(40, 10);
			}
			else if (direction == "top") // from bottom
			{
				bulletPosition.x = NumUtil.randomRange(_textureWidth + _displayObject.x - _bulletRadius*4, _displayObject.x + _bulletRadius*4);
				bulletPosition.y = _bulletRadius * 2 + _stageHeight + 100;
				bulletVelocity = Vec2.weak(NumUtil.randomRange(_textureWidth/2, -_textureWidth/2), -NumUtil.randomRange(3700, 3000));
				
				//angularVel = -NumUtil.randomRange(40, 10);
			}
			
			//Cc.log("direction = " + direction);
			
			_bullet = new Body(BodyType.DYNAMIC, bulletPosition);
			
			_bullet.type = BodyType.KINEMATIC;
			_bullet.shapes.add(new Circle(_bulletRadius, Vec2.weak(_bulletRadius,_bulletRadius), Material.ice()));
			//_bullet.userData = _bullet.localCOM.mul(-1);
			//_bullet.align();
			_bullet.graphic = _makeBullet();
			_pieces[_pieces.length] = _bullet.graphic;
			_piecesCount++;
			_bullet.graphicUpdate = _onSliceUpdate;
			_bullet.space = _napeSpace;
			
			//_bullet.angularVel = angularVel;
			_bullet.mass = _bulletRadius;
			//_bullet.gravMass = _bulletRadius*2;
			
			_bullet.velocity = bulletVelocity;
			
			//TweenLite.delayedCall(1, _explode);
			//TweenLite.delayedCall(5, _uninit);
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
			_genome.stage.removeEventListener(Event.ENTER_FRAME, _mainLoop);
			TweenMax.killAll();
			
			if (_debug)
			{
				_napeDebug.display.parent.removeChild(_napeDebug.display);
				_napeDebug.clear();
				_napeDebug = null;
			}
			
			_napeBodies = null;
			
			(_bullet.graphic as ImagePiece).texture.dispose();
			_bullet.clear();
			_bullet = null;
			
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
			
			if (_pooling)
			{
				_napeSpace.clear();
			}
			else
			{
				//_napeSpace.destroy(true);
				_napeSpace = null;
				_ground = null
				Debug.clearObjectPools();
			}
			
			_genome.beginRender();
			_genome.render();
			_genome.endRender();
			
			super._uninit();
		}
		
		private function _makeBullet():ImagePiece
		{
			return new ImagePiece(GTextureFactory.createFromBitmapData("bullet", new BulletBmp().bitmapData, true),0,0);
		}
		
		private function _onSliceUpdate(b:Body):void 
		{
			var disp:ImagePiece = b.graphic;
			disp.x = b.position.x;
			disp.y = b.position.y;
			disp.rotation = b.rotation;
		}
		
		private function _mainLoop(event:Event):void
		{
			_napeSpace.step(_stepLength, EffectsSettings.crashEffectPhysVelIterations, EffectsSettings.crashEffectPhysPosIterations);
			
			if (_debug)
			{
				_napeDebug.clear();
				_napeDebug.draw(_napeSpace);
				_napeDebug.flush();
			}
			
			_genome.beginRender();
			
			var i:uint;
			var len:uint = _piecesCount;
			
			for (i = 0; i < len; i++ )
			{
				var piece:ImagePiece = _pieces[i];
				_genome.draw(piece.x + piece.texture.width/2, piece.y + piece.texture.height/2, piece.texture, piece.rotation, 1, 1, 1, 1, 1, 1, GBlendMode.NORMAL);
			}
			
			_genome.render();
			_genome.endRender();
		}
		
	}

}