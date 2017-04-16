package components;

using components.Component;
using Thx.Floats;

import haxe.Timer;
import motion.Actuate;
import motion.easing.Expo;
import motion.easing.Quad;
import motion.easing.Quart;
import nape.callbacks.InteractionType;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Circle;
import nape.shape.Polygon;
import openfl.Assets;
import openfl.Lib;
import openfl.display.DisplayObject;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.text.TextField;
import components.World;
import openfl.ui.Keyboard;

/**
 * ...
 * @author Tom Wilson
 */
class FlappyFrost extends Component
{
	public var gameObject(get, null):Sprite;
	function get_gameObject():Sprite { return cast(_gameObject, Sprite); }
	
	public var autoFly:Bool = false;
	public var autoFlyHeight:Float = App.SCREEN_HEIGHT/2;
	public var body:Body;
	
	var frost:MovieClip;
	var head:Sprite;
	var arm1:Sprite;
	var arm2:Sprite;
	var leg1:Sprite;
	var leg2:Sprite;
	var bottom:Sprite;
	var torso:Sprite;
	var top:Sprite;
	var abdomen:Sprite;
	var mouth:Sprite;
	var hair:Sprite;
	var eye1:Sprite;
	var eye2:Sprite;
	var headInner:Sprite;
	var leg1Inner:Sprite;
	var leg2Inner:Sprite;
	var arm1Inner:Sprite;
	var arm2Inner:Sprite;
	
	var legsInner:Array<Sprite> = [];
	var armsInner:Array<Sprite> = [];
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
		
		frost = Assets.getMovieClip("assets:frost");
		gameObject.addChild(frost);
		
		bottom = cast(frost.getChildByName("bottom"), Sprite);
		top = cast(frost.getChildByName("top"), Sprite);
		head = cast(top.getChildByName("head"), Sprite);
		arm1 = cast(top.getChildByName("arm1"), Sprite);
		arm2 = cast(top.getChildByName("arm2"), Sprite);
		torso = cast(top.getChildByName("torso"), Sprite);
		abdomen = cast(bottom.getChildByName("abdomen"), Sprite);
		leg1 = cast(bottom.getChildByName("leg1"), Sprite);
		leg2 = cast(bottom.getChildByName("leg2"), Sprite);
		
		headInner = cast(head.getChildByName("head"), Sprite);
		leg1Inner = cast(leg1.getChildByName("leg"), Sprite);
		leg2Inner = cast(leg2.getChildByName("leg"), Sprite);
		arm1Inner = cast(arm1.getChildByName("arm"), Sprite);
		arm2Inner = cast(arm2.getChildByName("arm"), Sprite);
		
		mouth = cast(headInner.getChildByName("mouth"), Sprite);
		hair = cast(headInner.getChildByName("hair"), Sprite);
		eye1 = cast(headInner.getChildByName("eye1"), Sprite);
		eye2 = cast(headInner.getChildByName("eye2"), Sprite);
		
		legs = [leg1, leg2];
		arms = [arm1, arm2];
		legsInner = [leg1Inner, leg2Inner];
		armsInner = [arm1Inner, arm2Inner];
		eyes = [eye1, eye2];
		
		for (leg in legsInner) {
			var jitter = new JitterMotion();
			leg.addComponent(jitter);
			legJitters.push(jitter);
		}
		
		for (arm in armsInner) {
			var jitter = new JitterMotion();
			arm.addComponent(jitter);
			armJitters.push(jitter);
		}
		
		headJitter = new JitterMotion();
		headInner.addComponent(headJitter);
		
		hairJitter = new JitterMotion();
		hair.addComponent(hairJitter);
		
		bodyJitter = new JitterMotion();
		frost.addComponent(bodyJitter);
		
		body = new Body(BodyType.DYNAMIC);
		body.shapes.add(new Circle(40));
		body.space = Main.self.world.space;
	}
	
	override function onDisable() 
	{
		super.onDisable();
		world = null;
		body.space = null;
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
	
	override public function onUpdate() 
	{
		super.onUpdate();
		
		//trace(body.position, autoFlyHeight);
		if (autoFly) {
			if (body.position.y > autoFlyHeight && flapTimer > 0.2) {
				flap();
			}
		} else {
			if (Input.isKeyPressed(Keyboard.SPACE) || Input.isKeyPressed(Keyboard.UP)){
				flap();
			}
			if (Input.isKeyDown(Keyboard.LEFT)){
				//speedX = 2
				body.applyImpulse(new Vec2(-200,0));
			}
			if (Input.isKeyDown(Keyboard.RIGHT)){
				//speedX = 2;
				body.applyImpulse(new Vec2(200,0));
			}
		}
		
		body.velocity = new Vec2(body.velocity.x.clampSym(200), body.velocity.y);
		var scaredness = Utils.MathUtils.calculatePercent(0.2, 2, flapTimer).clamp(0, 1);
		for (jitter in legJitters) jitter.properties.set(5, 0.5, 1, 1, scaredness.interpolate(15,50), scaredness.interpolate(0.8,2.5), 1);
		for (jitter in armJitters) jitter.properties.set(5, 0.5, 1, 1, scaredness.interpolate(5,50), scaredness.interpolate(0.5,2), 1);
		headJitter.properties.set(2, 0.5, 1, 1, 5, 1, 1);
		hairJitter.properties.set(0,0,0,0,0,0,0,0.1,0.1);
		//bodyJitter.restrained = false;
		
		//body.velocity = new Vec2(body.velocity.x.clamp(0,50), body.velocity.y.clamp(0,));
		//if (body.velocity.x > 50)
		
		//speedY = (speedY - gravity).clamp(-16, 30);
		//speedX = (speedX * 0.95).clamp(3, 50);
		
		rotationTarget = body.velocity.y * 0.05;
		flapTimer += App.frameDeltaTime;
		
		
	}
	
	override function onPostUpdate() 
	{
		super.onPostUpdate();
		gameObject.x = body.position.x;
		gameObject.y = body.position.y;
		//gameObject.x += speedX;
		//gameObject.y -= speedY;
		gameObject.rotation += (rotationTarget - gameObject.rotation) * 0.5;
		
		var bodies = body.interactingBodies(InteractionType.ANY);
		bodies.foreach(function(b:Body){
			var go:DisplayObject = cast(b.userData, DisplayObject);
			var components = go.getComponents();
			for (c in components) {
				if (Std.is(c, Coin)) {
					cast(c, Coin).hit();
				}
			}
		});
	}
	
	public function flap() 
	{
		body.applyImpulse(new Vec2(200, 0));
		//body.velocity = new Vec2(body.velocity.x, -400);
		if (autoFly) {
			body.velocity.y = -250;
		} else {
			body.velocity.y = -400;
		}
		//speedX += 5;
		//speedY = 8;
		
		flapTimer = 0;
		flapState = FlapState.DOWN;
		var time = Lib.getTimer() / 1000.0;
		var flapTime = (time-lastFlapTime).clamp(0.2, 0.8);
		var downTime = 0.6 * flapTime;
		var upTime = flapTime-downTime;
		
		SoundManager.playSound("assets/sounds/wing.wav");
		
		for (arm in arms) {
			var mirror = (arm == arms[0]) ? 1 : -1;
			arm.rotation = Random.float(90, 110) * mirror;
			Actuate.stop(arm);
			Actuate.tween(arm, downTime, { rotation: Random.float(-20,-40) * mirror }).ease(Expo.easeOut).onComplete(function(){
				Actuate.tween(arm, upTime, { rotation: Random.float(90,110) * mirror }).ease(Quad.easeInOut).onComplete(function(){
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