package;
import openfl.Lib;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;

/**
 * ...
 * @author Tom Wilson
 */
class Input 
{
	static var keys:Array<Bool> = [];
	static var keyTimes:Array<Int> = [];
	
	static public function init() 
	{
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		for (i in 0...222) {
			keys[i] = false;
			keyTimes[i] = 0;
		}
	}
	
	static private function onEnterFrame(e:Event):Void 
	{
		for (i in 0...keys.length) {
			if (keys[i])
				keyTimes[i]++;
			else
				keyTimes[i] = 0;
		}
	}
	
	static private function onKeyDown(e:KeyboardEvent):Void {
		keys[e.keyCode] = true;
	}

	static private function onKeyUp(e:KeyboardEvent):Void {
		keys[e.keyCode] = false;
	}
	
	static public function isKeyPressed(keyCode:Int):Bool {
		return keyTimes[keyCode] == 1;
	}
	
	static public function isKeyDown(keyCode:Int):Bool {
		return keys[keyCode];
	}
	
}