package;
import haxe.Timer;
import openfl.Lib;
import openfl.display.Stage;
import openfl.display.StageScaleMode;
import openfl.events.Event;
import openfl._internal.timeline.Frame;

/**
 * ...
 * @author Tom Wilson
 */
class App 
{
	static public var debug:Bool = false;

	static public var SCREEN_WIDTH(default,null) = 1024;
	static public var SCREEN_HEIGHT(default,null) = 633;
	static public var stage(default,null):Stage;
	static public var stageScaleY(default,null):Float = 1;
	static public var stageScaleX(default,null):Float = 1;
	static public var stageScale:Float;
	static public var deltaTime(default,null):Int;
	static public var frameRate(default,null):Float;
	static public var frameDeltaTime(default,null):Float;
	static private var lastTime:Int;
	
	static public function init() 
	{
		stage = Lib.current.stage;
		Lib.current.stage.scaleMode = StageScaleMode.SHOW_ALL;
		Lib.current.stage.addEventListener(Event.RESIZE, onResize);
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		Input.init();
		
		frameRate = Lib.current.stage.frameRate;
		frameDeltaTime = 1 / frameRate;
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
			Lib.current.x = (Lib.current.stage.stageWidth - App.SCREEN_WIDTH * stageScale) / 2;
		} else {
			Lib.current.y = (Lib.current.stage.stageHeight - App.SCREEN_HEIGHT * stageScale) / 2;
		}
		#end
	}
	
	static private function onEnterFrame(e:Event):Void 
	{
        var time = Lib.getTimer();
        deltaTime = time - lastTime;
        lastTime = time;
	}
	
}