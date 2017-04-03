package;
import motion.Actuate;
import motion.easing.Cubic;
import motion.easing.Elastic;
import motion.easing.Expo;
import openfl.Assets;
import openfl.Lib;
import openfl.display.DisplayObject;
import openfl.display.Loader;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.display.StageScaleMode;
import openfl.events.Event;
import promhx.Deferred;

/**
 * ...
 * @author Tom Wilson
 */
class Preloader extends openfl.display.Preloader
{
	var loader:Sprite;
	var frostHead:Sprite;
	var text:Sprite;
	var screen:MovieClip;
	var loadingScreen:LoadingScreen;

	public function new() 
	{
		super(loadingScreen = new LoadingScreen());
		
		App.init();
		
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}
	
	private function onEnterFrame(e:Event):Void 
	{
		loadingScreen.update();
	}
	
}