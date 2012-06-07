/*
* 
* Copyright (c) 2008-2011 Lu Aye Oo
* 
* @author 		Lu Aye Oo
* 
* http://code.google.com/p/flash-console/
* 
*
* This software is provided 'as-is', without any express or implied
* warranty.  In no event will the authors be held liable for any damages
* arising from the use of this software.
* Permission is granted to anyone to use this software for any purpose,
* including commercial applications, and to alter it and redistribute it
* freely, subject to the following restrictions:
* 1. The origin of this software must not be misrepresented; you must not
* claim that you wrote the original software. If you use this software
* in a product, an acknowledgment in the product documentation would be
* appreciated but is not required.
* 2. Altered source versions must be plainly marked as such, and must not be
* misrepresented as being the original software.
* 3. This notice may not be removed or altered from any source distribution.
* 
* REQUIRES JSON: com.adobe.serialization.json.JSON
*/
package com.junkbyte.console.addons.htmlexport {
	import com.adobe.serialization.json.JSON;
	import com.junkbyte.console.Cc;
	import com.junkbyte.console.Console;
	import com.junkbyte.console.ConsoleConfig;
	import com.junkbyte.console.ConsoleStyle;
	import com.junkbyte.console.vos.Log;
	
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import flash.utils.describeType;
	
	/*
	 * REQUIRES JSON: com.adobe.serialization.json.JSON
	 */
	public class ConsoleHtmlExport
	{
		[Embed(source="template.html", mimeType="application/octet-stream")]
		private static var EmbeddedTemplate:Class;
		
		public static const HTML_REPLACEMENT:String = "{text:'HTML_REPLACEMENT'}";
		
		public var referencesDepth:uint = 1;
		
		protected var console:Console;
		
		public static function register(console:Console = null):ConsoleHtmlExport
		{
			if(console == null)
			{
				console = Cc.instance;
			}
			var exporter:ConsoleHtmlExport;
			if (console) 
			{
				exporter = new ConsoleHtmlExport(console);
				console.addMenu("export", exporter.exportToFile, new Array(), "Export logs to HTML");
			}
			return exporter;
		}
		
		public function ConsoleHtmlExport(console:Console):void
		{
			if(console == null)
			{
				console = Cc.instance;
			}
			this.console = console;
		}
		
		public function exportToFile(fileName:String = null):void
		{
			if(fileName == null)
			{
				fileName = generateFileName();
			}
			
			var file:FileReference = new FileReference();
			try
			{
				var html:String = exportHTMLString();
				file.save(html, fileName);
			}
			catch(err:Error) 
			{
				console.report("Failed to save to file.", 8);
			}
		}
		
		protected function generateFileName():String
		{
			var date:Date = new Date();
			var fileName:String = "log@"+date.getFullYear()+"."+(date.getMonth()+1)+"."+(date.getDate()+1);
			fileName += "_"+date.hours+"."+date.minutes;
			fileName += ".html";
			return fileName;
		}
		
		public function exportHTMLString():String
		{
			var html:String = String(new EmbeddedTemplate() as ByteArray);
			html = html.replace(HTML_REPLACEMENT, exportJSON());
			return html;
		}
		
		public function exportJSON():String
		{
			return JSON.encode(exportObject());
		}
		
		public function exportObject():Object
		{
			var data:Object = new Object();
			
			data.config = getConfigToEncode();
			
			data.ui = getUIDataToEncode();
			
			data.logs = getLogsToEncode();
			
			var refs:ConsoleHTMLRefsGen = new ConsoleHTMLRefsGen(console, referencesDepth);
			refs.fillData(data);
			
			return data;
		}
		
		protected function getConfigToEncode():Object
		{
			var config:ConsoleConfig = console.config;
			var object:Object = convertTypeToObject(config);
			object.style = getStyleToEncode();
			return object;
		}
		
		protected function getStyleToEncode():Object
		{
			var style:ConsoleStyle = console.config.style;
			/*if(!preserveStyle)
			{
				style = new ConsoleStyle();
				style.updateStyleSheet();
			}*/
			
			var object:Object = convertTypeToObject(style);
			object.styleSheet = getStyleSheetToEncode(style);
			
			return object;
		}
		
		protected function getStyleSheetToEncode(style:ConsoleStyle):Object
		{
			var object:Object = new Object();
			for each(var styleName:String in style.styleSheet.styleNames)
			{
				object[styleName] = style.styleSheet.getStyle(styleName);
			}
			return object;
		}
		
		protected function getUIDataToEncode():Object
		{
			var object:Object = new Object();
			
			object.viewingPriority = console.panels.mainPanel.priority;
			object.viewingChannels = null; // TODO. console need to expose it
			object.ignoredChannels = null; // TODO. console need to expose it
			
			return object;
		}
		
		protected function getLogsToEncode():Object
		{
			var lines:Array = new Array();
			var line:Log = console.logs.last;
			while(line)
			{
				var obj:Object = convertTypeToObject(line);
				delete obj.next;
				delete obj.prev;
				lines.push(obj);
				line = line.prev;
			}
			lines = lines.reverse();
			return lines;
		}
		
		protected function convertTypeToObject(typedObject:Object):Object
		{
			var object:Object = new Object();
			var desc:XML = describeType(typedObject);
			for each(var varXML:XML in desc.variable)
			{
				var key:String = varXML.@name;
				object[key] = typedObject[key];
			}
			return object;
		}
	}
}
