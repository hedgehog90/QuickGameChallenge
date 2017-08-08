package;
import haxe.Timer;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Stage;
import openfl.display.StageScaleMode;
import openfl.events.Event;
import openfl._internal.timeline.Frame;
import openfl.geom.Rectangle;

/**
 * ...
 * @author Tom Wilson
 */
class App 
{
	static public var debug:Bool = true;
    static public var inited:Bool = false;

	static public var SCREEN_WIDTH(default,null) = 1024;
	static public var SCREEN_HEIGHT(default,null) = 633;
	static public var stage(default,null):Stage;
	static public var stageScaleY(default,null):Float = 1.0;
	static public var stageScaleX(default,null):Float = 1.0;
	static public var deltaTime(default,null):Int;
	static public var frameRate(default,null):Float;
	static public var frameDeltaTime(default, null):Float;
	static public var showBorders(default, null):Bool = true;
	
	static private var lastTime:Int;
	
	static private var topEdge:Bitmap;
	static private var bottomEdge:Bitmap;
	static private var leftEdge:Bitmap;
	static private var rightEdge:Bitmap;

	static public function init()
	{
        if (inited) return;
        inited = true;
		stage = Lib.current.stage;
		Lib.current.stage.scaleMode = StageScaleMode.SHOW_ALL;
		if (showBorders) {
			var bd = new BitmapData(1, 1, false, 0x000000);
			Lib.current.stage.addChild(topEdge = new Bitmap(bd));
			Lib.current.stage.addChild(rightEdge = new Bitmap(bd));
			Lib.current.stage.addChild(bottomEdge = new Bitmap(bd));
			Lib.current.stage.addChild(leftEdge = new Bitmap(bd));
			//topEdge.alpha = rightEdge.alpha = bottomEdge.alpha = leftEdge.alpha = 0.5;
		}
		
		Lib.current.stage.addEventListener(Event.RESIZE, onResize);
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		Input.init();
		
		frameRate = Lib.current.stage.frameRate;
		frameDeltaTime = 1 / frameRate;
	}

	static private function onResize(e:Event):Void
	{
		#if (cpp || neko || html5)
		
		if (Lib.current.stage.scaleMode != StageScaleMode.NO_SCALE) {
			stageScaleX = Lib.current.stage.stageWidth / App.SCREEN_WIDTH;
			stageScaleY = Lib.current.stage.stageHeight / App.SCREEN_HEIGHT;
			if (Lib.current.stage.scaleMode == StageScaleMode.NO_BORDER) {
				stageScaleX = stageScaleY = Math.max(stageScaleX, stageScaleY);
			} else if (Lib.current.stage.scaleMode == StageScaleMode.SHOW_ALL) {
				stageScaleX = stageScaleY = Math.min(stageScaleX, stageScaleY);
			}
		}
		
		Lib.current.x = (Lib.current.stage.stageWidth - App.SCREEN_WIDTH * stageScaleX) / 2;
		Lib.current.y = (Lib.current.stage.stageHeight - App.SCREEN_HEIGHT * stageScaleY) / 2;
		Lib.current.scaleX = stageScaleX;
		Lib.current.scaleY = stageScaleY;
		
		if (showBorders) {
			setEdge(topEdge, 0, 0, Lib.current.stage.stageWidth, Lib.current.y);
			setEdge(leftEdge, 0, 0, Lib.current.x, Lib.current.stage.stageHeight);
			setEdge(bottomEdge, 0, Lib.current.stage.stageHeight - Lib.current.y, Lib.current.stage.stageWidth, Lib.current.y);
			setEdge(rightEdge, Lib.current.stage.stageWidth - Lib.current.x, 0, Lib.current.x, Lib.current.stage.stageHeight);
		}
		
		#end
	}
	
	static private inline function setEdge(edge:Bitmap, x:Float, y:Float, w:Float, h:Float) 
	{
		//var rect = new Rectangle(x, y, w, h);
		edge.x = x;
		edge.y = y;
		edge.width = w;
		edge.height = h;
	}
	
	static private function onEnterFrame(e:Event):Void 
	{
        var time = Lib.getTimer();
        deltaTime = time - lastTime;
        lastTime = time;
	}
	
}