package;
import openfl.Lib;
import openfl.display.Stage;
import openfl.display.StageScaleMode;
import openfl.events.Event;

/**
 * ...
 * @author Tom Wilson
 */
class App 
{

	static public var SCREEN_WIDTH = 1024;
	static public var SCREEN_HEIGHT = 633;
	static public var stage:Stage;
	static public var stageScaleY:Float = 1;
	static public var stageScaleX:Float = 1;
	static public var stageScale:Float;
	static public var debug:Bool = true;
	
	static public function init() 
	{
		stage = Lib.current.stage;
		Lib.current.stage.scaleMode = StageScaleMode.SHOW_ALL;
		Lib.current.stage.addEventListener(Event.RESIZE, onResize);
	}
	
	static private function onResize(e:Event):Void 
	{
		#if (cpp || neko)
		stageScaleX = Lib.current.stage.stageWidth / App.SCREEN_WIDTH;
		stageScaleY = Lib.current.stage.stageHeight / App.SCREEN_HEIGHT;
		stageScale = Math.min(stageScaleX, stageScaleY);
		
		Lib.current.x = 0;
		Lib.current.y = 0;
		Lib.current.scaleX = stageScale;
		Lib.current.scaleY = stageScale;
		
		if (stageScaleX > stageScaleY) {
			Lib.current.x = (Lib.current.stage.stageWidth - NOMINAL_WIDTH * stageScale) / 2;
		} else {
			Lib.current.y = (Lib.current.stage.stageHeight - NOMINAL_HEIGHT * stageScale) / 2;
		}
		#end
	}
	
}