package ru.codestage.fpresent.page 
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	/**
	 * ...
	 * @author focus
	 */
	public class Page extends Object 
	{
		public var displayObject:DisplayObject;
		
		public function Page(displayObject:DisplayObject = null) 
		{
			super();
			this.displayObject = displayObject;
			if (displayObject is Bitmap)
			{
				(displayObject as Bitmap).smoothing = true;
			}
		}
		
		public function setPageData(displayObject:DisplayObject):void
		{
			this.displayObject = displayObject;
			if (displayObject is Bitmap)
			{
				(displayObject as Bitmap).smoothing = true;
			}
		}
		
		public function clear():void
		{
			if (displayObject is Bitmap)
			{
				(displayObject as Bitmap).bitmapData.dispose();
				(displayObject as Bitmap).bitmapData = null;
			}
			
			if (displayObject.parent)
			{
				displayObject.parent.removeChild(displayObject);
			}
			displayObject = null;
		}
		
		public function isValid():Boolean
		{
			return (displayObject != null);
		}
		
	}

}