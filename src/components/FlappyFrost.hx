package components;

using components.Component;
using Thx.Floats;
using Lambda;
using Extensions;

import haxe.Timer;
import motion.Actuate;
import motion.easing.Expo;
import motion.easing.Quad;
import motion.easing.Quart;
import nape.callbacks.InteractionType;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.MassMode;
import nape.shape.Circle;
import nape.shape.Polygon;
import openfl.Assets;
import openfl.Lib;
import openfl.display.DisplayObject;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.geom.Matrix;
import openfl.text.TextField;
import components.World;
import components.Component;
import openfl.ui.Keyboard;

/**
 * ...
 * @author Tom Wilson
 */
class FlappyFrost extends Component
{
	public var autoFly:Bool = false;
	public var autoFlyHeight:Float = App.SCREEN_HEIGHT/2;
	public var rigidBody:RigidBody;
	public var colliders:Array<Collider>;
	
	var frost:MovieClip;
	var head:Sprite;
	var arm1:Sprite;
	var arm2:Sprite;
	var leg1:Sprite;
	var leg2:Sprite;
	var torso:Sprite;
	var abdomen:Sprite;
	var mouth:Sprite;
	var hair:Sprite;
	var eye1:Sprite;
	var eye2:Sprite;
	
	var legs:Array<Sprite> = [];
	var arms:Array<Sprite> = [];
	var eyes:Array<Sprite> = [];
	
	var legJitters:Array<JitterMotion> = [];
	var armJitters:Array<JitterMotion> = [];
	var headJitter:JitterMotion;
	var bodyJitter:JitterMotion;
	var hairJitter:JitterMotion;
	
	var lastFlapTime:Float = 0;
	var flapState:FlapState = FlapState.NEUTRAL;
	var flapTimer:Float = 0;
	var rotationTarget:Float = 0;
	var world:World;

	override function onEnable() 
	{
		super.onEnable();
		
		world = gameObject.getParentComponent(World);
		
		frost = Main.self.getMovieClip("frost_1");
		colliders = gameObject.getComponentsInChildren(Collider);
		gameObjectSprite.addChild(frost);
		
		head = cast(frost.getChildByName("head"), Sprite);
		arm1 = cast(frost.getChildByName("arm1"), Sprite);
		arm2 = cast(frost.getChildByName("arm2"), Sprite);
		torso = cast(frost.getChildByName("torso"), Sprite);
		abdomen = cast(frost.getChildByName("abdomen"), Sprite);
		leg1 = cast(frost.getChildByName("leg1"), Sprite);
		leg2 = cast(frost.getChildByName("leg2"), Sprite);
		
		mouth = cast(head.getChildByName("mouth"), Sprite);
		hair = cast(head.getChildByName("hair"), Sprite);
		eye1 = cast(head.getChildByName("eye1"), Sprite);
		eye2 = cast(head.getChildByName("eye2"), Sprite);
		
		legs = [leg1, leg2];
		arms = [arm1, arm2];
		eyes = [eye1, eye2];
		
		for (leg in legs) {
			var legInner = leg.getChildAt(0);
			var jitter:JitterMotion = legInner.addComponent(JitterMotion);
			jitter.restrained = false;
			legJitters.push(jitter);
		}
		
		for (arm in arms) {
			var armInner = arm.getChildAt(0);
			var jitter:JitterMotion = armInner.addComponent(JitterMotion);
			jitter.restrained = false;
			armJitters.push(jitter);
		}
		
		headJitter = head.addComponent(JitterMotion);
		
		hairJitter = hair.addComponent(JitterMotion);
		
		bodyJitter = frost.addComponent(JitterMotion);
		bodyJitter.properties.rotationAmount = 10;
		
		rigidBody = gameObject.addComponent(RigidBody);
		//rigidBody.offset.x = 10;
		rigidBody.body.allowRotation = false;
		rigidBody.body.massMode = MassMode.FIXED;
		rigidBody.body.mass = 5;
	}
	
	override function onDisable() 
	{
		super.onDisable();
		world = null;
	}
	
	/*function animate(part:DisplayObject, property:String, timeMin:Float, timeMax:Float, valueMin:Float, valueMax:Float, ease = null){
		function repeat() {
			if (ease == null) ease = Quad.easeInOut;
			var props:Dynamic = {};
			Reflect.setField(props, property, Random.float(valueMin, valueMax) * animateAmount);
			Actuate.stop(part);
			Actuate.tween(part, Random.float(timeMin, timeMax) * animateSpeed, props).ease(ease).onComplete(repeat);
		}
		repeat();
	}*/
	
	override function onPreUpdate() 
	{
		super.onPreUpdate();
		
		if (autoFly) {
			if (rigidBody.body.position.y > autoFlyHeight && flapTimer > 0.2) {
				flap();
			}
		} else {
			if (Input.isKeyPressed(Keyboard.SPACE) || Input.isKeyPressed(Keyboard.UP)){
				flap();
			}
			if (Input.isKeyDown(Keyboard.LEFT)){
				//speedX = 2
				rigidBody.body.applyImpulse(Vec2.weak(-200,0));
			}
			if (Input.isKeyDown(Keyboard.RIGHT)){
				//speedX = 2;
				rigidBody.body.applyImpulse(Vec2.weak(200,0));
			}
		}
		
		rigidBody.body.velocity.setxy(rigidBody.body.velocity.x.clampSym(200), rigidBody.body.velocity.y);
		var scaredness = Utils.calculatePercent(0.2, 2, flapTimer).clamp(0, 1);
		for (jitter in legJitters) jitter.properties.set(0, 0.5, 1, 1, scaredness.interpolate(15, 50), scaredness.interpolate(0.8, 2.5), 1);
		for (jitter in armJitters) jitter.properties.set(5, 0.5, 1, 1, scaredness.interpolate(5, 50), scaredness.interpolate(0.5, 2), 1);
		headJitter.properties.set(2, 0.5, 1, 1, 5, 1, 1);
		hairJitter.properties.set(0, 0, 0, 0, 0, 0, 0, 0.1, 0.1);
		
		var rotationTarget = Utils.deg2rad(rigidBody.body.velocity.y * 0.05);
		//rigidBody.body.rotation += (rotationTarget - rigidBody.body.rotation) * 0.5;
		rigidBody.updateColliders();
	}
	
	override public function onUpdate() 
	{
		super.onUpdate();
		flapTimer += App.frameDeltaTime;
	}
	
	override function onPostUpdate() 
	{
		super.onPostUpdate();
		
		var touchingGameObjects = world.getTouchingGameObjects(gameObject);
		var touchingCoins = Component.getComponentsFromMultiple(touchingGameObjects, Coin);
		for (c in touchingCoins) {
			c.hit();
		}
	}
	
	public function flap() 
	{
		rigidBody.body.applyImpulse(Vec2.weak(200, 0));
		//body.applyImpulse(Vec2.weak(800, 0));
		//body.velocity.y = -400;
		if (autoFly) {
			rigidBody.body.velocity.y = -250;
		} else {
			rigidBody.body.velocity.y = -400;
		}
		//speedX += 5;
		//speedY = 8;
		
		flapTimer = 0;
		flapState = FlapState.DOWN;
		var time = Lib.getTimer() / 1000.0;
		var flapTime = (time-lastFlapTime).clamp(0.2, 0.8);
		var downTime = 0.6 * flapTime;
		var upTime = flapTime-downTime;
		
		SoundManager.playSound("assets/sounds/wing.wav", 1, 0);
		
		var rotation1 = 120 + Random.float( -10, 10);
		var rotation2 = 10 + Random.float( -10, 10);
		var rotation3 = 130 + Random.float( -10, 10);
		
		for (arm in arms) {
			var mirror = (arm == arms[0]) ? 1 : -1;
			arm.rotation = rotation1 * mirror;
			Actuate.stop(arm);
			Actuate.tween(arm, downTime, { rotation: rotation2 * mirror }).ease(Expo.easeOut).onComplete(function(){
				Actuate.tween(arm, upTime, { rotation: rotation3 * mirror }).ease(Quad.easeInOut).onComplete(function(){
				});
			});
		}
		
		lastFlapTime = time;
	}
	
}

enum FlapState {
	DOWN;
	NEUTRAL;
}