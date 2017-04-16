package components;

using components.Component;
using Lambda;
using Thx.Floats;

import components.Camera;
import components.Component;
import components.FlappyFrost;
import components.Follow;
import components.JitterMotion;
import components.World;
import components.World.Section;
import motion.Actuate;
import motion.easing.Quart;
import nape.geom.Vec2;
import nape.space.Space;
import noisehx.Perlin;
import openfl.Assets;
import openfl.Lib;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;

/**
 * ...
 * @author Tom Wilson
 */
class World extends Component
{
	public var gameObject(get, null):Sprite;
	function get_gameObject():Sprite { return cast(_gameObject, Sprite); }
	
	public var worldContainer:Sprite;
	public var bgContainer:Sprite;
	public var cloudContainer:Sprite;
	public var debugContainer:Sprite;
	public var sections:Array<Section> = [];
	
	public var cameraOuter(default, null):Sprite;
	public var cameraInner(default, null):Sprite;
	public var space:Space;
	public var score:Int = 0;
	
	var camera:Camera;
	var frost:FlappyFrost;
	var cloudPerlin:Perlin;
	var bg:Sprite;
	
	var sectionWidth:Float = 1024;
	var started:Bool;
	var time:Float = 0;

	override function onEnable() 
	{
		Main.self.world = this;
		
		space = new Space(new Vec2(0, 700));
		space.worldLinearDrag = 0.01;
		
		super.onEnable();
		
		gameObject.addChild(worldContainer = new Sprite());
		gameObject.addChild(debugContainer = new Sprite());
		
		worldContainer.addChild(cloudContainer = new Sprite());
		worldContainer.addChild(bgContainer = new Sprite());
		
		gameObject.mouseChildren = gameObject.mouseEnabled = false;
		
		cloudPerlin = new Perlin();
		
		/*bgGridX = 10;
		bgGridY = 6;
		bg = new Sprite();
		for (y in 0...bgGridY+1){
			for (x in 0...bgGridX+1){
				var i = (y % 2 + x % 2) % 2;
				bg.graphics.beginFill(i == 1 ? 0xff0000 : 0xffffff, 1);
				bg.graphics.drawRect(x/bgGridX*App.SCREEN_WIDTH, y/bgGridY*App.SCREEN_WIDTH, App.SCREEN_WIDTH/bgGridX, App.SCREEN_HEIGHT/bgGridY);
			}
		}
		bgContainer.addChild(bg);*/
		
		worldContainer.addChild(cameraOuter = new Sprite());
		cameraOuter.addChild(cameraInner = new Sprite());
		camera = new Camera(worldContainer);
		cameraInner.addComponent(camera);
		
		/*var jitter = new JitterMotion();
		var cameraJitter = new JitterMotionProperties();
		cameraJitter.positionAmount = 50;
		cameraJitter.positionFrequency = 0.2;
		cameraJitter.positionXComponent = 2;
		jitter.properties = cameraJitter;
		cameraInner.addComponent(jitter);*/
		
		frost = new FlappyFrost();
		var frostGo = new Sprite();
		worldContainer.addChild(frostGo);
		frostGo.addComponent(frost);
		frost.autoFly = true;
		frost.autoFlyHeight = frost.gameObject.y;
		
		var follow = new Follow();
		follow.target = frostGo;
		follow.easing = 0.5;
		follow.bounds = new Rectangle(Math.NEGATIVE_INFINITY, frostGo.y, Math.POSITIVE_INFINITY, frostGo.y);
		cameraOuter.addComponent(follow);
		
		var coin = Component.createGameObject([Coin]);
		gameObject.addChild(coin);
		
		var floor = Assets.getMovieClip("assets:floor");
		var bd:BitmapData = new BitmapData(Std.int(floor.width), Std.int(floor.height), false);
		bd.draw(floor);
		
		new Section(this);
		
		time += 1 / Lib.current.stage.frameRate;
	}
	
	public function start() 
	{
		started = true;
		Actuate.tween(camera, 3, {zoom:0.7}).ease(Quart.easeInOut);
		Actuate.timer(3.4).onComplete(function() {
			var go = Assets.getMovieClip("assets:go");
			gameObject.addChild(go);
			Actuate.tween(go, 1, {alpha:0}).delay(0.15).onComplete(function() {});
			frost.autoFly = false;
		});
	}
	
	override function onUpdate() 
	{
		super.onUpdate();
		
		space.step(1 / Lib.current.stage.frameRate);
		
		//var left = Math.floor(camera.rect.x / Section.SECTION_WIDTH);
		//var right = Math.ceil(camera.rect.right / Section.SECTION_WIDTH);
		
		var camRectExpanded = camera.rect.clone();
		camRectExpanded.inflate(150, 150);
		
		while (true) {
			var firstSection = sections[0];
			var lastSection = sections[sections.length - 1];
			if (camRectExpanded.right > lastSection.rect.right)
				new Section(this);
			else if (camRectExpanded.left > firstSection.rect.right)
				firstSection.destroy();
			else
				break;
		}
		
		//gameObject.getComponents();
		
		//var section = 
		
		//bg.x = gameObject.x % (App.SCREEN_WIDTH / bgGridX);
		//bg.y = gameObject.y % (App.SCREEN_HEIGHT / bgGridY);
		
		//jitter.properties.positionXComponent = 1 / cameraOuter.scaleX;
		//jitter.properties.positionYComponent = 1 / cameraOuter.scaleY;
		//jitter.properties.scaleXComponent = 1 / cameraOuter.scaleX;
		//jitter.properties.scaleYComponent = 1 / cameraOuter.scaleY;
	}
	
}

class Section extends Sprite
{
	public var objects:Array<DisplayObject> = [];
	public var world:World;
	public var rect:Rectangle;
	
	public function new(world:World)
	{
		super();
		this.world = world;
		
		var lastSection = world.sections[world.sections.length - 1];
		
		var width = 1024;
		var height = 633;
		
		rect = new Rectangle(
			lastSection != null ? lastSection.rect.right : -width / 2,
			lastSection != null ? lastSection.rect.top + (lastSection.rect.height - height) / 2 : -height / 2,
			width, height
		);
		
		var numClouds = Random.int(4, 6);
		for (i in 0...numClouds) {
			var cloud_n = Random.int(1, 4);
			var cloud = Assets.getMovieClip('assets:cloud${cloud_n}');
			cloud.x = (i/numClouds).interpolate(rect.left, rect.right) + Random.float(-100, 100);
			cloud.y = Random.float(0, 200) - height / 2;
			cloud.alpha = Random.float(0.6, 1);
			cloud.scaleX = cloud.scaleY = Random.float(0.8, 1);
			
			var jitter = new JitterMotion();
			jitter.properties.set(30, 0.1, 1, 1, 60, 0.1, 1, 0.5, 0.1, 1, 1);
			jitter.properties.positionLock = jitter.properties.scaleLock = true;
			cloud.addComponent(jitter);
			
			addChild(cloud);
		}
		
		for (pt in Formation.diamond(5)){
			var cluster = new Sprite();
			var coin = Component.createGameObject([Coin]);
			cluster.addChild(coin);
			addChild(cluster);
			coin.x = pt.x * 20;
			coin.y = pt.y * 20;
			cluster.x = rect.x + rect.width / 2;
		}
		
		graphics.lineStyle(1, 0xff0000);
		graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
		world.worldContainer.addChild(this);
		
		world.sections.push(this);
	}
	
	public function destroy() 
	{
		this.destroyWithComponents();
		world.sections.remove(this);
	}
}