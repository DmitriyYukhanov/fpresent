package ru.codestage.fpresent
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.utils.getDefinitionByName;
	import ru.codestage.ui.preloaders.CirclePreloader;
	
	/**
	 * ...
	 * @author Dmitriy [focus] Yukhanov
	 */
	public class Preloader extends MovieClip 
	{
		private var _circlePreloader:CirclePreloader;
		
		public function Preloader() 
		{
			this.mouseEnabled = false;
			
			if (stage) 
			{
				_init();
				
			}
			else 
			{
				this.addEventListener(Event.ADDED_TO_STAGE, _onThisAddedToStage);
			}
		}
		
		private function _onThisAddedToStage(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, _onThisAddedToStage);
			_init();
		}
		
		private function _init():void 
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			//stage.quality = StageQuality.HIGH;
			
			addEventListener(Event.ENTER_FRAME, _checkFrame);
			//loaderInfo.addEventListener(ProgressEvent.PROGRESS, _progress);
			loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, _ioError);
			
			_circlePreloader = new CirclePreloader(this, stage.stageWidth / 2, stage.stageHeight / 2,18,16,8,3,0,1,null,500);
		}
		
		private function _ioError(e:IOErrorEvent):void 
		{
			trace(e.text);
		}
		
		/*private function _progress(e:ProgressEvent):void 
		{
			// TODO update loader
		}*/
		
		private function _checkFrame(e:Event):void 
		{
			if (currentFrame == totalFrames) 
			{
				stop();
				_loadingFinished();
			}
		}
		
		private function _loadingFinished():void 
		{
			removeEventListener(Event.ENTER_FRAME, _checkFrame);
			//loaderInfo.removeEventListener(ProgressEvent.PROGRESS, progress);
			loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, _ioError);
			
			_circlePreloader.destroy();
			_circlePreloader = null;
			
			_startup();
		}
		
		private function _startup():void 
		{
			var mainClass:Class = getDefinitionByName("ru.codestage.fpresent.Main") as Class;
			addChild(new mainClass() as DisplayObject);
		}
		
	}
	
}