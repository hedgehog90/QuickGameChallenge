package;

import openfl.media.SoundTransform;
using Extensions;
using StringTools;
using Thx.Strings;
using components.Component;

import components.Collider;
import components.Component;
import haxe.Json;
import haxe.unit.TestCase;
import motion.Actuate;
import motion.easing.Elastic;
import motion.easing.Expo;
import motion.easing.Linear;
import motion.easing.Quad;
import nape.geom.Mat23;
import nape.geom.Vec2;
import openfl.Assets;
import openfl.Lib;
import openfl.display.DisplayObject;
import openfl.display.FPS;
import openfl.display.GraphicsPath;
import openfl.display.GraphicsPathCommand;
import openfl.display.GraphicsPathWinding;
import openfl.display.IGraphicsData;
import openfl.display.IGraphicsPath;
import openfl.display.MovieClip;
import openfl.display.Preloader;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.display.StageScaleMode;
import openfl.errors.Error;
import openfl.events.Event;
import openfl.media.SoundMixer;
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
import spritesheet.data.BehaviorData;
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

        App.init();
		
		Actuate.defaultEase = Linear.easeNone;
		
		addChild(gameContainer = new Sprite());
		addChild(menuContainer = new Sprite());
		addChild(fadeContainer = new Sprite());
		addChild(debugContainer = new Sprite());
		addChild(new FPS());
		
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
		
		var importer = new TexturePackerImporter();
		var jsonText = Assets.getText("assets/assets.json");
		#if cpp
		jsonText = jsonText.substr(3);
		#end
		assetsSpritesheet = importer.parse(jsonText, Assets.getBitmapData("assets/assets.png"), ~/^.+?(?=\s*(?:instance)?\s*(?:\d+))/);
		var coinBehavior:BehaviorData = assetsSpritesheet.behaviors.get("coin");
		coinBehavior.loop = true;
		coinBehavior.frames.pop();
		coinBehavior.originX = 18;
		coinBehavior.originY = 20;
		
		Promise.whenAll([loadLibrary()]).then(function(_){
			start();
		});
		
		var st = SoundMixer.soundTransform;
		st.volume = 0.25;
		st.volume = 0;
		SoundMixer.soundTransform = st;
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
	
	@:access(openfl.display.MovieClip)
	public function getMovieClip(path):MovieClip
	{
		
		var mc = Assets.getMovieClip("assets:" + path);
		
		mc.recurse(function(o:DisplayObject) {
			var className = o.getSymbolName();
			if (className != null) {
				var collider:Collider = null;
				if (className == "HitCircle") {
					collider = o.addComponent(Collider);
					collider.addCircle(Vec2.weak(), 50);
					//var scale = Mat23.fromMatrix(o.transform.matrix).equiorthogonalise().transform(Vec2.weak(1, 1), true, true);
				} else if (className == "HitBox") {
					collider = o.addComponent(Collider);
					collider.addBox(Vec2.weak(), Vec2.weak(50, 50));
				} else if (className.startsWith("HitPolygon")) {
					var shapes = o.getChildren();
					collider = o.addComponent(Collider);
					var pts:Array<Vec2> = [];
					for (s in shapes) {
						if (!Std.is(s, Shape)) continue;
						var shape:Shape = cast s;
						var data = shape.graphics.readGraphicsData();
						for (d in data) {
							if (Std.is(d, GraphicsPath)){
								var path:GraphicsPath = cast d;
								for (i in 0 ... path.commands.length) {
									if (path.commands[i] == GraphicsPathCommand.MOVE_TO || path.commands[i] == GraphicsPathCommand.LINE_TO) {
										pts.push(Vec2.weak(path.data[i*2], path.data[i*2+1]));
									}
								}
								//if (path.winding == GraphicsPathWinding.NON_ZERO) pts.reverse();
							}
						}
					}
					#if html5
					js.Lib.debug();
					#end
					if (pts[pts.length - 1].equals(pts[0])) pts.pop();
					trace(pts);
					collider.addPolygon(pts);
				}
				
				if (collider != null) {
					o.visible = false;
					o.removeChildren();
					return Utils.RecurseResult.SkipChildren;
				}
			}
			
			return Utils.RecurseResult.Recurse;
		});
		return mc;
		//mc.currentFrameLabel
	}

}