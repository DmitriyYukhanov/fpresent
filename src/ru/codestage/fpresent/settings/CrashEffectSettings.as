package ru.codestage.fpresent.settings 
{
	/**
	 * ...
	 * @author Dmitriy [focus] Yukhanov
	 */
	public final class CrashEffectSettings extends Object 
	{
		public var hmax:uint = 15;
		public var hmin:uint = 10;
		public var wmax:uint = 15;
		public var wmin:uint = 10;
		
		
		private static var _instance:CrashEffectSettings;
		
		public static function get instance():CrashEffectSettings 
		{
			return _instance || CrashEffectSettings();
		}
		
		
		public function CrashEffectSettings() 
		{
			super();
			_instance = this;
		}
		
		public function initFromXML():void
		{
			
		}
		
	}

}