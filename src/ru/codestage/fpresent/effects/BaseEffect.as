package ru.codestage.fpresent.effects 
{
	import com.genome2d.core.Genome2D;
	import com.genome2d.core.GNode;
	import com.genome2d.textures.GTexture;
	import com.greensock.TweenLite;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	/**
	 * ...
	 * @author Dmitriy [focus] Yukhanov
	 */
	public class BaseEffect extends Object 
	{
		protected var _genome:Genome2D;
		protected var _displayObject:DisplayObject;
		protected var _bd:BitmapData;
		
		protected var _textureWidth:Number;
		protected var _textureHeight:Number;
		
		protected var _stageWidth:Number;
		protected var _stageHeight:Number;
		
		public function BaseEffect(displayObject:DisplayObject, bd:BitmapData) 
		{
			super();
			
			this._displayObject = displayObject;
			this._bd = bd;
			
			_genome = Genome2D.getInstance();
			
			_textureWidth = displayObject.width;
			_textureHeight = displayObject.height;
			
			_stageWidth = _displayObject.stage.stageWidth;
			_stageHeight = _displayObject.stage.stageHeight;
		}
		
		public function run():void
		{
			if (EffectsManager.instance.effectType == EffectsManager.EFFECT_HIDE)
			{
				hide();
			}
		}
		protected function hide():void
		{
			TweenLite.killTweensOf(_displayObject, true);
			_displayObject.parent.removeChild(_displayObject);
		}
		
		public function terminate():void
		{
			_uninit();
		}
		
		protected function _uninit():void
		{
			_bd.dispose();
			_bd = null;
			_displayObject = null;
			
			EffectsManager.instance.currentEffectEnded();
		}
		
	}

}