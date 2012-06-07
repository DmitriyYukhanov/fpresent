package ru.codestage.fpresent.effects 
{
	/**
	 * ...
	 * @author Dmitriy [focus] Yukhanov
	 */
	public final class EffectsSettings extends Object 
	{
		public static var crashEffectParticlesXMax:uint;
		public static var crashEffectParticlesXMin:uint;
		public static var crashEffectParticlesYMax:uint;
		public static var crashEffectParticlesYMin:uint;
		public static var crashEffectPhysVelIterations:uint;
		public static var crashEffectPhysPosIterations:uint;
		public static var fallEffectParticlesXCount:uint;
		public static var fallEffectParticlesYCount:uint;
		
		public static function parseSettings(xml:XML):void 
		{
			var crashEffect:XMLList = xml.ef_settings.CrashEffect;
			
			crashEffectParticlesXMin = crashEffect.@particlesXMin;
			crashEffectParticlesXMax = crashEffect.@particlesXMax;
			crashEffectParticlesYMin = crashEffect.@particlesYMin;
			crashEffectParticlesYMax = crashEffect.@particlesYMax;
			
			crashEffectPhysVelIterations = crashEffect.@physVelIterations;
			crashEffectPhysPosIterations = crashEffect.@physPosIterations;
			
			var fallEffect:XMLList = xml.ef_settings.FallEffect;
			fallEffectParticlesXCount = fallEffect.@particlesX;
			fallEffectParticlesYCount = fallEffect.@particlesY;
		}
	}

}