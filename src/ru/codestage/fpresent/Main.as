package ru.codestage.fpresent
{
	import com.greensock.easing.Circ;
	import com.greensock.plugins.AutoAlphaPlugin;
	import com.greensock.plugins.ColorTransformPlugin;
	import com.greensock.plugins.TintPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.TweenLite;
	import com.junkbyte.console.addons.displaymap.DisplayMapAddon;
	import com.junkbyte.console.Cc;
	import flash.Boot;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import nape.phys.Interactor;
	import nape.util.Debug;
	import ru.codestage.fpresent.effects.EffectsManager;
	import ru.codestage.fpresent.effects.EffectsSettings;
	import ru.codestage.fpresent.page.Page;
	import ru.codestage.fpresent.page.PageInfo;
	import ru.codestage.ui.preloaders.CirclePreloader;
	import ru.codestage.utils.display.GraphUtil;
	
	/**
	 * ...
	 * @author Dmitriy [focus] Yukhanov
	 */
	[Frame(factoryClass="ru.codestage.fpresent.Preloader")]
	
	public class Main extends Sprite
	{
		public static var instance:Main;
		
		/*private var _regular:DejaVuSansMonoRegular;
		private var _bold:DejaVuSansMonoBold;
		private var _italic:DejaVuSansMonoItalic;
		private var _boldItalic:DejaVuSansMonoBoldItalic;*/
		
		private var _currentPage:Page;
		
		private var _pagesInfo:Vector.<PageInfo>;
		private var _currentPageIndex:uint;
		private var _currentPageEdit:TextField;
		private var _guiCont:Sprite;
		private var _pageLoader:Loader;
		private var _circlePreloader:CirclePreloader;
		
		//private var mStarling:Starling;
		
		private function _enableCC(parent:DisplayObjectContainer, debug:Boolean = true):void
		{
			if (parent)
			{
				Cc.config.commandLineAllowed = debug;
				Cc.config.commandLineAutoScope = true;
				Cc.config.defaultStackDepth = 10;
				Cc.config.displayRollerEnabled = debug;
				Cc.config.maxRepeats = -1;
				if (debug)
					Cc.config.objectHardReferenceTimer = 120;
				Cc.config.sharedObjectName = 'com.junkbyte/Console/UserData/focus';
				Cc.config.tracing = false;
				Cc.config.useObjectLinking = debug;
				
				Cc.config.style.big();
				Cc.config.style.backgroundColor = 0x101010;
				Cc.config.style.panelSnapping = 10;
				Cc.config.style.roundBorder = 0;
				Cc.config.alwaysOnTop = false;
				
				if (debug)
				{
					Cc.start(parent, "-");
				}
				else
				{
					Cc.start(parent, "debugconsole");
				}
				
				//Cc.fpsMonitor = debug;
				//Cc.memoryMonitor = debug;
				Cc.remoting = false;
				Cc.commandLine = debug;
				Cc.width = 600;
				Cc.height = 200;
				Cc.y = 20;
				Cc.listenUncaughtErrors(this.loaderInfo);
				if (debug)
				{
					Cc.setRollerCaptureKey('s', true, false, true);
					Cc.addMenu("Remove", _removeConsole, null, "Completely remove Flash Console");
				}
				DisplayMapAddon.addToMenu();
			}
		}
		
		private function _removeConsole():void
		{
			Cc.visible = false;
			TweenLite.delayedCall(1, Cc.remove);
		}
		
		public function Main():void
		{
			instance = this;
			this.mouseEnabled = false;
			this.addEventListener(Event.ADDED_TO_STAGE, _init);
		}
		
		private function _init(e:Event):void
		{
			_enableCC(this);
			
			removeEventListener(Event.ADDED_TO_STAGE, _init);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, _onStageKeyDown);
			stage.addEventListener(Event.RESIZE, _onStageResize);
			
			TweenPlugin.activate([AutoAlphaPlugin, TintPlugin, ColorTransformPlugin]);
			EffectsManager.instance.init(stage);
			
			
			this.mouseEnabled = false;
			
			_loadPagesList();
		}
		
		private function _loadPagesList():void
		{
			var xmlLoader:URLLoader = new URLLoader();
			xmlLoader.addEventListener(Event.COMPLETE, _pagesListLoaded);
			xmlLoader.load(new URLRequest("fpresent.xml"));
			
			_circlePreloader = new CirclePreloader(stage, stage.stageWidth / 2, stage.stageHeight / 2, 18, 16, 8, 3, 0xFFFFFF, 1, null, 500);
		}
		
		private function _pagesListLoaded(e:Event):void
		{
			var xmlLoader:URLLoader = (e.target as URLLoader);
			xmlLoader.removeEventListener(Event.COMPLETE, _pagesListLoaded);
			
			var loadedXML:XML = new XML(xmlLoader.data);
			xmlLoader = null;
			
			var pages:XMLList = loadedXML.pages.page;
			
			var leni:uint = pages.length();
			var i:uint;
			
			_pagesInfo = new Vector.<PageInfo>(leni);
			
			for (i = 0; i < leni; i++ )
			{
				_pagesInfo[i] = new PageInfo(pages[i].@url);
			}
			
			EffectsSettings.parseSettings(loadedXML);
			
			System.disposeXML(loadedXML);
			xmlLoader = null;
			
			_currentPageIndex = 0;
			_buildGUI();
			
			EffectsManager.instance.showShade(_loadCurrentPage);
		}
		
		private function _loadCurrentPage():void
		{
			if (_currentPage)
			{
				_currentPage.clear();
				//_currentPage = null;
			}
			
			if (_pageLoader)
			{
				_pageLoader.unload();
				_pageLoader.unloadAndStop();
				_pageLoader = null;
			}
			
			_pageLoader = new Loader();
			_pageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, _currentPageLoaded);
			_pageLoader.load(new URLRequest("pages/" + _pagesInfo[_currentPageIndex].url), new LoaderContext(false, ApplicationDomain.currentDomain));
			
			if (!_circlePreloader) _circlePreloader = new CirclePreloader(stage, stage.stageWidth / 2, stage.stageHeight / 2, 18, 16, 8, 3, 0xFFFFFF, 1, null, 500);
		}
		
		private function _currentPageLoaded(e:Event):void
		{
			_pageLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, _currentPageLoaded);

			if (_currentPage)
			{
				_currentPage.setPageData(_pageLoader.contentLoaderInfo.content);
			}
			else
			{
				_currentPage = new Page(_pageLoader.contentLoaderInfo.content);
			}
			
			_circlePreloader.destroy();
			_circlePreloader = null;
			
			_showCurrentPage();
			_onStageResize(null);
		}
		
		private function _showCurrentPage():void
		{	
			_currentPageEdit.text = String(_currentPageIndex + 1);
			this.addChildAt(_currentPage.displayObject,0);
			
			EffectsManager.instance.hideShade(_pageShowed);
		}
		
		private function _pageShowed():void
		{
			System.pauseForGCIfCollectionImminent(0);
		}
		
		private function _onStageKeyDown(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.RIGHT || e.keyCode == Keyboard.SPACE)
			{
				if (_currentPageIndex < _pagesInfo.length - 1)
				{
					if (EffectsManager.instance.isRunning)
					{
						EffectsManager.instance.terminate();
					}
					else
					{
						EffectsManager.instance.generateEffect(_currentPage, _nextPage, EffectsManager.EFFECT_HIDE);
					}
				}
			}
			else if (e.keyCode == Keyboard.LEFT)
			{
				if (_currentPageIndex > 0)
				{
				
					if (EffectsManager.instance.isRunning)
					{
						EffectsManager.instance.terminate();
					}
					else
					{
					   EffectsManager.instance.generateEffect(_currentPage, _prevPage, EffectsManager.EFFECT_HIDE);
					}
				}
			}
		}
		
		private function _prevPage():void
		{
			//_pagesLoaders[_currentPageIndex].unload();
			_currentPageIndex--;
			_loadCurrentPage();
			
		}
		
		private function _nextPage():void
		{
			//_pagesLoaders[_currentPageIndex].unload();
			_currentPageIndex++;
			_loadCurrentPage();
		}
		
		private function _onStageResize(e:Event):void
		{
			if (_guiCont)
			{
				_guiCont.y = stage.stageHeight - _guiCont.height - 3;
			}
			
			if (stage.stageWidth < 1024 || stage.stageHeight < 768)
			{
				GraphUtil.fitIntoRect(_currentPage.displayObject, new Rectangle(0, 0, stage.stageWidth, stage.stageHeight), false);
			}
			
			_currentPage.displayObject.x = stage.stageWidth / 2 - _currentPage.displayObject.width / 2;
			_currentPage.displayObject.y = stage.stageHeight / 2 - _currentPage.displayObject.height / 2;
			
			
		}
		
		private function _buildGUI():void
		{
			_guiCont = new Sprite();
			
			var tf:TextFormat = new TextFormat("DejaVu Sans Mono", 20, 0x44AA44, true, null, null, null, null, "right");
			
			_currentPageEdit = new TextField();
			_currentPageEdit.defaultTextFormat = tf;
			_currentPageEdit.type = TextFieldType.INPUT;
			_currentPageEdit.multiline = false;
			_currentPageEdit.embedFonts = true;
			_currentPageEdit.restrict = "0-9";
			_currentPageEdit.maxChars = 3;
			_currentPageEdit.text = "1";
			_currentPageEdit.width = 40;
			_currentPageEdit.height = 27;
			_currentPageEdit.addEventListener(Event.CHANGE, _onPageTextChange);
			_currentPageEdit.mouseWheelEnabled = false;
			
			var _totalPagesText:TextField = new TextField();
			tf.align = "left";
			_totalPagesText.defaultTextFormat = tf;
			_totalPagesText.type = TextFieldType.DYNAMIC;
			_totalPagesText.selectable = false;
			_totalPagesText.multiline = false;
			_totalPagesText.embedFonts = true;
			_totalPagesText.restrict = "0-9";
			_totalPagesText.maxChars = 3;
			_totalPagesText.text = "/" + _pagesInfo.length;
			_totalPagesText.width = 40;
			_totalPagesText.height = 27;
			_totalPagesText.x = _currentPageEdit.x + _currentPageEdit.width - 3;
			_totalPagesText.mouseEnabled = false;
			_totalPagesText.mouseWheelEnabled = false;
			_totalPagesText.cacheAsBitmap = true;
			
			_guiCont.addChild(_currentPageEdit);
			_guiCont.addChild(_totalPagesText);
			
			_guiCont.x = 0;
			_guiCont.y = stage.stageHeight - _guiCont.height - 3;
			
			_guiCont.mouseEnabled = false;
			
			this.addChild(_guiCont);
		}
		
		private function _onPageTextChange(e:Event):void
		{
			var newText:String = e.target.text;
			if (newText != "" && uint(newText) > 0 && uint(newText) - 1 != _currentPageIndex)
			{
				if (uint(newText) - 1 < _pagesInfo.length)
				{
					_currentPageIndex = uint(newText) - 1;
					_loadCurrentPage();
				}
			}
		}
	
	}
}