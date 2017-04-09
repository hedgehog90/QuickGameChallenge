package;

using Utils;
import motion.Actuate;
import motion.easing.Elastic;
import motion.easing.Expo;
import motion.easing.Linear;
import motion.easing.Quad;
import openfl.Assets;
import openfl.Lib;
import openfl.display.MovieClip;
import openfl.display.Preloader;
import openfl.display.Sprite;
import openfl.display.StageScaleMode;
import openfl.errors.Error;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import openfl.utils.AssetLibrary;
import promhx.Deferred;
import promhx.Promise;
import components.MainMenu;
import components.World;

/**
 * ...
 * @author Tom Wilson
 */
class Main extends GameObject 
{
	static public var self:Main;
	
	public var fadeContainer:GameObject;
	public var gameContainer:GameObject;
	public var menuContainer:GameObject;
	public var debugContainer:GameObject;
		
	public var gameObjects:Array<GameObject> = [];
	
	public var world:components.World;

	public function new() 
	{
		self = this;
		
		super();
		
		Actuate.defaultEase = Linear.easeNone;
		
		addChild(gameContainer = new GameObject());
		addChild(menuContainer = new GameObject());
		addChild(fadeContainer = new GameObject());
		addChild(debugContainer = new GameObject());
		
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
		
		Promise.whenAll([loadLibrary()]).then(function(_){
			start();
		});
		
		trace(Assets.list());
		trace(Assets.getSound("assets/sounds/buttonclick.wav"));
	}
	
	private function loadLibrary():Promise<Bool>
	{
		var dp = new Deferred<Bool>();
		var loader = Assets.loadLibrary("assets");
		loader.onComplete(function(_) {
			dp.resolve(true);
		});
		loader.onError(function(e){
			dp.throwError(e);
		});
		return dp.promise();
	}
	
	function start() 
	{
		gameContainer.addChild(GameObject.create([new components.World()]));
		menuContainer.addChild(GameObject.create([new MainMenu()]));
	}
	
	private function onEnterFrame(e:Event):Void 
	{
		for (go in gameObjects.copy()) {
			go.update();
		}
		
		fadeContainer.scaleX = App.stageScaleX;
		fadeContainer.scaleY = App.stageScaleY;
	}
	
	public function fadeTo(funct1:Void->Void, funct2:Void->Void = null) 
	{
		var fade = new GameObject();
		fade.graphics.beginFill(0xffffff, 1);
		fade.graphics.drawRect(0, 0, App.SCREEN_WIDTH, App.SCREEN_HEIGHT);
		fadeContainer.addChild(fade);
		fade.alpha = 0;
		
		Actuate.tween(fade, 0.5, {alpha:1}).ease(Quad.easeInOut).onComplete(function(){
			funct1();
			Actuate.tween(fade, 0.5, {alpha:0}).ease(Quad.easeInOut).onComplete(function(){
				fade.removeFromParent();
				if (funct2 != null) funct2();
			});
		});
	}

}