package;
import motion.Actuate;
import motion.easing.Elastic;
import motion.easing.Expo;
import openfl.Assets;
import openfl.Lib;
import openfl.display.MovieClip;
import openfl.display.Sprite;

/**
 * ...
 * @author Tom Wilson
 */
class LoadingScreen extends Sprite
{
	var screen:MovieClip;
	var loader:Sprite;
	var frostHead:Sprite;
	var text:Sprite;

	public function new() 
	{
		super();
		Assets.loadLibrary("loader").onComplete(function(_) {
			screen = Assets.getMovieClip("loader:loading_screen");
			loader = cast(screen.getChildByName("loader"), Sprite);
			frostHead = cast(loader.getChildByName("head"), Sprite);
			text = cast(loader.getChildByName("text"), Sprite);
			
			addChild(screen);
			
			Actuate.tween(frostHead, 1, { rotation: 360 }).ease(Expo.easeOut).repeat();
			Actuate.tween(frostHead, 1, { scaleX: 1.5, scaleY: 1.5 } ).ease(Elastic.easeOut).repeat().reflect();
			Actuate.tween(text, 1, { scaleX: 1.2, scaleY: 1.2 } ).ease(Elastic.easeInOut).repeat().reflect();
		});
	}
	
	public function update() 
	{
		if (loader != null) {
			loader.x = Lib.current.stage.stageWidth / 2;
			loader.y = Lib.current.stage.stageHeight / 2;
		}
	}
	
}