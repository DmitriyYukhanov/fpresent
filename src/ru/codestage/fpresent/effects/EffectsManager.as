package ru.codestage.fpresent.effects 
{
	import com.genome2d.components.GCamera;
	import com.genome2d.context.GContextConfig;
	import com.genome2d.core.Genome2D;
	import com.genome2d.core.GNode;
	import com.genome2d.textures.factories.GTextureFactory;
	import com.genome2d.textures.GTexture;
	import com.genome2d.textures.GTextureAtlas;
	import com.genome2d.textures.GTextureBase;
	import com.genome2d.textures.GTextureFilteringType;
	import com.genome2d.textures.GTextureUtils;
	import com.greensock.TweenLite;
	import com.junkbyte.console.Cc;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.display3D.Context3DRenderMode;
	import flash.events.Event;
	import flash.geom.Matrix;
	import ru.codestage.fpresent.page.Page;
	/**
	 * ...
	 * @author Dmitriy [focus] Yukhanov
	 */
	public final class EffectsManager extends Object 
	{
		public static const EFFECT_HIDE:uint = 0;
		public static const EFFECTS:Vector.<Class> = new <Class>[CrashEffect, FallEffect];
		
		public var isRunning:Boolean = false;
		
		private var _stage:Stage;
		private var _onComplete:Function;
		private var _currentEffect:BaseEffect;
		private var _shade:Shape;
		
		private var _displayObject:DisplayObject;
		
		internal var effectType:uint;
		
		private static var _instance:EffectsManager;
		
		public static function get instance():EffectsManager 
		{
			return _instance || new EffectsManager();
		}
		
		
		public function EffectsManager() 
		{
			super();
			_instance = this;
		}
		
		public function init(stage:Stage):void
		{
			this._stage = stage;
			GTextureBase.defaultFilteringType = GTextureFilteringType.NEAREST;
			Genome2D.getInstance().autoResize = true;
			Genome2D.getInstance().autoUpdate = false;
			Genome2D.getInstance().onInitialized.addOnce(_onGenomeInitialized);
			Genome2D.getInstance().onFailed.addOnce(_onGenomeFailed);
			
			var config:GContextConfig = new GContextConfig();
			config.separateNoAlphaShaders = true;
			config.antiAliasing = 0;
			Genome2D.getInstance().init(_stage, config);
			
			_shade = new Shape();
			_shade.graphics.beginFill(0, 1);
			_shade.graphics.drawRect(0, 0, 1, 1);
			_shade.graphics.endFill();
			
			//_stage.addEventListener(Event.RESIZE, onStageResize);
		}
		
		private function _onGenomeInitialized():void 
		{
			Cc.info("Running in " + _stage.stage3Ds[0].context3D.driverInfo + " mode");
		}
		
		private function _onGenomeFailed():void
		{
			Cc.error("Genome2D initialization failed device doesn't support Stage3D renderer.");
		}
		
		/*private function onStageResize(e:Event):void 
		{
			cameraNode.transform.x = _stage.stageWidth / 2;
			cameraNode.transform.y = _stage.stageHeight / 2;
		}*/
		
		public function generateEffect(page:Page, onCompleteCallback:Function, effectType:uint):void 
		{
			this.effectType = effectType;
			
			_onComplete = onCompleteCallback;
			_displayObject = page.displayObject;
			
			var mat:Matrix = _displayObject.transform.matrix;
			mat.translate( -_displayObject.x, -_displayObject.y); 
			
			var width:Number = _displayObject.width;
			var height:Number = _displayObject.height;
			
			if (!GTextureUtils.isValidTextureSize(width))
			{
				width = GTextureUtils.getNextValidTextureSize(width);
			}
			
			if (!GTextureUtils.isValidTextureSize(height))
			{
				height = GTextureUtils.getNextValidTextureSize(height);
			}
			
			var bitmapData:BitmapData = new BitmapData(width, height, false, 0x000000);
			bitmapData.draw(_displayObject, mat);
			
			var currentEffect:Class = EFFECTS[int(Math.random() * EFFECTS.length)];
			//var currentEffect:Class = CrashEffect;
			isRunning = true;
			
			_currentEffect = new currentEffect(_displayObject, bitmapData);
			_currentEffect.run();
		}
		
		public function showShade(onShowedCallback:Function):void 
		{
			if (!_shade.parent)
			{
				_shade.width = _stage.stageWidth;
				_shade.height = _stage.stageHeight;
				_shade.alpha = 0;
				_stage.addChild(_shade);
				TweenLite.to(_shade, 0.3, { alpha:1, onComplete:onShowedCallback } );
			}
			else
			{
				onShowedCallback();
			}
		}
		
		public function hideShade(onHidedCallback:Function = null):void 
		{
			if (_shade.parent)
			{
				TweenLite.to(_shade, 0.15, { alpha:0, onComplete:_onShadeHided, onCompleteParams:[onHidedCallback]} );
			}
		}
		
		private function _onShadeHided(onHidedCallback:Function = null):void 
		{
			_shade.parent.removeChild(_shade);
			if (onHidedCallback != null)
			{
				onHidedCallback();
			}
		}
		
		public function terminate():void
		{
			if (isRunning)
			{
				_currentEffect.terminate();
			}
		}
		
		internal function currentEffectEnded():void 
		{
			//_hideShade();
			
			_displayObject = null;
			_currentEffect = null;
			
			isRunning = false;
			
			if (this._onComplete != null)
			{
				this._onComplete();
				this._onComplete = null;
			}
		}
	}

}