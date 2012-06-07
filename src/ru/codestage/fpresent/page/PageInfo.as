package ru.codestage.fpresent.page 
{
	/**
	 * ...
	 * @author Dmitriy [focus] Yukhanov
	 */
	public final class PageInfo extends Object 
	{
		//public static const PAGE_TYPE_IMAGE:String = "image";
		//public static const PAGE_TYPE_SWF:String = "swf";
		
		public var url:String;
		//public var type:String;
		
		public function PageInfo(url:String = null) 
		{
			super();
			this.url = url;
			//this.type = type;
		}
		
	}

}