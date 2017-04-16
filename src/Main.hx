package;

using Utils;
import components.Component;
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
import spritesheet.Spritesheet;
import spritesheet.importers.BitmapImporter;
import spritesheet.importers.TexturePackerImporter;

/**
 * ...
 * @author Tom Wilson
 */
class Main extends Sprite 
{
	static public var self:Main;
	
	public var fadeContainer:Sprite;
	public var gameContainer:Sprite;
	public var menuContainer:Sprite;
	public var debugContainer:Sprite;
	
	public var world:World;
	public var input:Input;
	public var assetsSpritesheet:Spritesheet;

	public function new() 
	{
		self = this;
		
		super();
		
		Actuate.defaultEase = Linear.easeNone;
		
		addChild(gameContainer = new Sprite());
		addChild(menuContainer = new Sprite());
		addChild(fadeContainer = new Sprite());
		addChild(debugContainer = new Sprite());
		
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
		
		Promise.whenAll([loadLibrary()]).then(function(_){
			start();
		});
		
		var importer = new TexturePackerImporter();
		assetsSpritesheet = importer.parse(Assets.getText("assets/assets.json"), Assets.getBitmapData("assets/assets.png"), ~/^.+?(?=\s*(?:instance)?\s*(?:\d+))/);
		assetsSpritesheet.behaviors.get("coin").loop = true;
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
		gameContainer.addChild(Component.createGameObject([World]));

		menuContainer.addChild(Component.createGameObject([MainMenu]));
	}
	
	private function onEnterFrame(e:Event):Void 
	{
		Component.update();
		
		fadeContainer.scaleX = App.stageScaleX;
		fadeContainer.scaleY = App.stageScaleY;
	}
	
	public function fadeTo(funct1:Void->Void, funct2:Void->Void = null) 
	{
		var fade = new Sprite();
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