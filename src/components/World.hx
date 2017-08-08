package components;

using components.Component;
using Lambda;
using Thx.Floats;
using Extensions;

import components.Camera;
import components.Component;
import components.FlappyFrost;
import components.Follow;
import components.JitterMotion;
import components.World;
import components.World.Section;
import motion.Actuate;
import motion.easing.Quart;
import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.geom.Mat23;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.Compound;
import nape.shape.Shape;
import nape.space.Space;
import nape.util.ShapeDebug;
import noisehx.Perlin;
import openfl.Assets;
import openfl.Lib;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import thx.Set;

/**
 * ...
 * @author Tom Wilson
 */
class World extends Component
{
	public var worldContainer:Sprite;
	public var bgContainer:Sprite;
	public var debugContainer:Sprite;
	public var sections:Array<Section> = [];
	
	public var cameraOuter(default, null):Sprite;
	public var cameraInner(default, null):Sprite;
	public var space:Space;
	private var touchingBodies:Map<Body, Array<Body>> = new Map<Body, Array<Body>>();
	public var score:Int = 0;
	
	var camera:Camera;
	var frost:FlappyFrost;
	var cloudPerlin:Perlin;
	var bg:Sprite;
	
	var sectionWidth:Float = 1024;
	var started:Bool;
	var time:Float = 0;
	var napeDebugDraw:ShapeDebug;
	
	override function onEnable() 
	{
		Main.self.world = this;
		
		space = new Space(Vec2.weak(0, 700));
		space.worldLinearDrag = 0.01;
		space.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.ANY, CbType.ANY_BODY, CbType.ANY_BODY, onBeginInteract));
		space.listeners.add(new InteractionListener(CbEvent.END, InteractionType.ANY, CbType.ANY_BODY, CbType.ANY_BODY, onEndInteract));
		
		super.onEnable();
		
		gameObjectSprite.addChild(worldContainer = new Sprite());
		gameObjectSprite.addChild(debugContainer = new Sprite());
		if (App.debug) {
			napeDebugDraw = new ShapeDebug(App.SCREEN_WIDTH, App.SCREEN_HEIGHT);
			gameObjectSprite.addChild(napeDebugDraw.display);
		}
		
		worldContainer.addChild(bgContainer = new Sprite());
		
		gameObjectSprite.mouseChildren = gameObjectSprite.mouseEnabled = false;
		
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
		camera = cameraInner.addComponent(Camera);
		camera.context = worldContainer;
		
		/*var jitter = new JitterMotion();
		var cameraJitter = new JitterMotionProperties();
		cameraJitter.positionAmount = 50;
		cameraJitter.positionFrequency = 0.2;
		cameraJitter.positionXComponent = 2;
		jitter.properties = cameraJitter;
		cameraInner.addComponent(jitter);*/
		
		var frostGo = new Sprite();
		frost = frostGo.addComponent(FlappyFrost);
		worldContainer.addChild(frostGo);
		frost.autoFly = true;
		frost.autoFlyHeight = frost.gameObject.y;
		
		var follow = cameraOuter.addComponent(Follow);
		follow.target = frostGo;
		follow.easing = 0.5;
		follow.bounds = new Rectangle(Math.NEGATIVE_INFINITY, frostGo.y, Math.POSITIVE_INFINITY, frostGo.y);
		
		var floor = Assets.getMovieClip("assets:floor");
		var bd:BitmapData = new BitmapData(Std.int(floor.width), Std.int(floor.height), false);
		bd.draw(floor);
		
		new Section(this);
		
		time += 1 / Lib.current.stage.frameRate;
	}
	
	function onBeginInteract(collision:InteractionCallback) 
	{
		if (!touchingBodies.exists(collision.int1.castBody)) touchingBodies.set(collision.int1.castBody, []);
		if (!touchingBodies.exists(collision.int2.castBody)) touchingBodies.set(collision.int2.castBody, []);
		touchingBodies.get(collision.int1.castBody).push(collision.int2.castBody);
		touchingBodies.get(collision.int2.castBody).push(collision.int1.castBody);
	}
	
	function onEndInteract(collision:InteractionCallback) 
	{
		touchingBodies.get(collision.int1.castBody).remove(collision.int2.castBody);
		touchingBodies.get(collision.int2.castBody).remove(collision.int1.castBody);
	}
	
	public function getTouchingBodies(b:Body):Array<Body>
	{
		return (touchingBodies.exists(b)) ? touchingBodies.get(b).copy() : [];
	}
	
	public function getTouchingGameObjects(go:DisplayObject):Array<DisplayObject>
	{
		var gos = new Array<DisplayObject>();
		for (b1 in getBodiesFromFromGameObjects(go)) {
			for (b2 in getTouchingBodies(b1)) {
				if (b2.userData.gameObject != null) gos.push(b2.userData.gameObject);
			}
		}
		return gos;
	}
	
	function getBodiesFromFromGameObjects(go:DisplayObject) 
	{
		var filteredBodies = new Array<Body>();
		for (b in space.bodies) {
			if (b.userData.gameObject == go) filteredBodies.push(b);
		}
		return filteredBodies;
	}
	
	public function start() 
	{
		started = true;
		Actuate.tween(camera, 3, {zoom:0.7}).ease(Quart.easeInOut);
		Actuate.timer(3.4).onComplete(function() {
			var go = Assets.getMovieClip("assets:go");
			gameObjectSprite.addChild(go);
			Actuate.tween(go, 1, {alpha:0}).delay(0.15).onComplete(function() {});
			frost.autoFly = false;
		});
	}
	
	override function onUpdate() 
	{
		super.onUpdate();
		
		space.step(1 / App.frameRate);
		cleanUpTouchingBodies();
		
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
	
	function cleanUpTouchingBodies() 
	{
		var removeBodies = new Array<Body>();
		for (touching in touchingBodies.keys()) {
			if (touching.space == null) removeBodies.push(touching);
		}
		
		for (b in removeBodies) {
			for (touching in touchingBodies.get(b)) {
				touchingBodies.get(touching).remove(b);
			}
			//touchingBodies.set(b, []);
			touchingBodies.remove(b);
			space.bodies.remove(b);
		}
	}
	
	override function onPostUpdate() 
	{
		super.onPostUpdate();
		
		if (App.debug) {
			var m = camera.contextMatrix;
			napeDebugDraw.transform.setAs(m.a, m.b, m.c, m.d, m.tx, m.ty);
			napeDebugDraw.clear();
			napeDebugDraw.draw(space);
			napeDebugDraw.flush();
		}
	}
	
	override function onDisable() 
	{
		super.onDisable();
	}
	
	public function getPosition(go:DisplayObject):Point
	{
		return go.localToLocal(worldContainer);
	}
	
	public function setPosition(go:DisplayObject, x:Float, y:Float):Void
	{
		go.x = 0;
		go.y = 0;
		var pt = worldContainer.localToLocal(go, new Point(x, y));
		go.x = pt.x;
		go.y = pt.y;
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
			
			var jitter = cloud.addComponent(JitterMotion);
			jitter.properties.set(30, 0.1, 1, 1, 60, 0.1, 1, 0.5, 0.1, 1, 1);
			jitter.properties.positionLock = jitter.properties.scaleLock = true;
			addChild(cloud);
			//cloud.visible = false;
		}
		
		var formation = Formations.diamond(5);
		//var formation = Formations.rect(25,15);
		for (pt in formation){
			var cluster = new Sprite();
			var coin = Component.createGameObject([Coin]);
			coin.x = pt.x * 20;
			coin.y = pt.y * 20;
			cluster.addChild(coin);
			cluster.x = rect.x + rect.width / 2;
			addChild(cluster);
			//cluster.visible = false;
		}
		
		//graphics.lineStyle(1, 0xff0000);
		//graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
		world.worldContainer.addChild(this);
		
		world.sections.push(this);
	}
	
	public function destroy()
	{
		this.destroyGameObject();
		world.sections.remove(this);
	}
}