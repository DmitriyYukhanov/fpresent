package com.junkbyte.console.addons.displaymap
{
    import com.junkbyte.console.Cc;
    import com.junkbyte.console.Console;
    import com.junkbyte.console.view.ConsolePanel;

    import flash.display.DisplayObject;

    public class DisplayMapAddon
    {

        public static function start(targetDisplay:DisplayObject, console:Console = null):void
        {
            if (console == null)
            {
                console = Cc.instance;
            }
            if (console == null)
            {
                return;
            }
            var mapPanel:DisplayMapPanel = new DisplayMapPanel(console);
            mapPanel.start(targetDisplay);
            console.panels.addPanel(mapPanel);
        }

        public static function registerCommand(commandName:String = "mapdisplay", console:Console = null):void
        {
            if (console == null)
            {
                console = Cc.instance;
            }
            if (console == null || commandName == null)
            {
                return;
            }

            var callbackFunction:Function = function(... arguments:Array):void
            {
                var scope:* = console.cl.run("this");
                if (scope is DisplayObject)
                {
                    start(scope as DisplayObject, console);
                }
                else
                {
                    console.error("Current scope", scope, "is not a DisplayObject.");
                }
            }
            console.addSlashCommand(commandName, callbackFunction);
        }

        public static function addToMenu(menuName:String = "DM", console:Console = null):void
        {
            if (console == null)
            {
                console = Cc.instance;
            }
            if (console == null || menuName == null)
            {
                return;
            }

            var callbackFunction:Function = function():void
            {
                start(console.parent);
            }
            console.addMenu(menuName, callbackFunction);
        }
    }
}
