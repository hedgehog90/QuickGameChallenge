package;

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
import states.Game;
import states.MainMenu;

/**
 * ...
 * @author Tom Wilson
 */
class Main extends Sprite 
{
	static public var self:Main;
	
	public var mainMenu:MainMenu;
	public var fadeContainer:GameObject;
	public var menuContainer:GameObject;
	public var debugContainer:GameObject;
	public var game:states.GameObject;
	
	public var gameObjects:Array<GameObject> = [];

	public function new() 
	{
		self = this;
		
		super();
		
		Actuate.defaultEase = Linear.easeNone;
		
		add(menuContainer = new GameObject());
		add(fadeContainer = new GameObject());
		add(debugContainer = new GameObject());
		
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
		trace("start");
		mainMenu = new states.MainMenu();
	}
	
	private function onEnterFrame(e:Event):Void 
	{
		for (go in gameObjects) {
			go.update();
		}
		
		fadeContainer.scaleX = App.stageScaleX;
		fadeContainer.scaleY = App.stageScaleY;
		
		if (mainMenu != null) {
			mainMenu.update();
		}
	}
	
	public function fadeTo(funct1:Void->Void, funct2:Void->Void = null) 
	{
		var fade = new GameObject();
		fade.graphics.beginFill(0xffffff, 1);
		fade.graphics.drawRect(0, 0, App.SCREEN_WIDTH, App.SCREEN_HEIGHT);
		fadeContainer.add(fade);
		fade.alpha = 0;
		
		Actuate.tween(fade, 0.5, {alpha:1}).ease(Quad.easeInOut).onComplete(function(){
			funct1();
			Actuate.tween(fade, 0.5, {alpha:0}).ease(Quad.easeInOut).onComplete(function(){
				fade.parent.removeChild(fade);
				if (funct2 != null) funct2();
			});
		});
	}

}