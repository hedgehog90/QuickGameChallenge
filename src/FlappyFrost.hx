package;
using Thx.Floats;

import haxe.Timer;
import motion.Actuate;
import motion.easing.Quad;
import motion.easing.Quart;
import openfl.Assets;
import openfl.Lib;
import openfl.display.DisplayObject;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.text.TextField;

/**
 * ...
 * @author Tom Wilson
 */
class FlappyFrost extends GameObject
{
	var display:MovieClip;
	var head:Sprite;
	var arm1:Sprite;
	var arm2:Sprite;
	var leg1:Sprite;
	var leg2:Sprite;
	var bottom:Sprite;
	var torso:Sprite;
	var top:Sprite;
	var abdomen:Sprite;
	var animateAmount:Float = 1.0;
	var animateSpeed:Float = 1.0;
	var mouth:Sprite;
	var hair:Sprite;
	var eye1:Sprite;
	var eye2:Sprite;
	var headInner:Sprite;
	var leg1Inner:Sprite;
	var leg2Inner:Sprite;
	var arm1Inner:Sprite;
	var arm2Inner:Sprite;
	var legsInner:Array<Sprite>;
	var armsInner:Array<Sprite>;
	var legs:Array<Sprite>;
	var arms:Array<Sprite>;
	var eyes:Array<Sprite>;
	var speedX:Float = 1.5;
	var speedY:Float = 0;
	var flapSpeedX:Float = 0;
	var flapSpeedY:Float = 0;
	var flapSpeedInfluence:Float  = 1;
	var gravity:Float = 0.5;
	var drag:Float = 0.1;
	var autoFly:Bool = false;
	var autoFlyHeight:Float = App.SCREEN_HEIGHT/2;
	var lastFlapTime:Float = 0;
	var flapState:FlapState = FlapState.NEUTRAL;
	var debugText:openfl.text.TextField;
	var flapTimer:Float = 0;
	var rotationTarget:Float;
	var headJitter:JitterMotion;
	var lastTime:Float = 0;
	var world:World;

	public function new(world:World) 
	{
		super();
		this.world = world;
		
		display = Assets.getMovieClip("assets:frost");
		addChild(display);
		
		bottom = cast(display.getChildByName("bottom"), Sprite);
		top = cast(display.getChildByName("top"), Sprite);
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
		
		for(leg in legsInner) {
			animate(leg, "rotation", 0.3, 0.8, -18, 18);
			animate(leg, "x", 0.5, 1, -1, 1);
			animate(leg, "y", 0.5, 1, -1, 1);
		}
		
		for(arm in armsInner) {
			animate(arm, "rotation", 0.5, 1, -3, 6);
			animate(arm, "x", 0.5, 1, -1, 1);
			animate(arm, "y", 0.5, 1, -1, 1);
		}
		
		/*animate(headInner, "rotation", 0.5, 1, -3, 6);
		animate(headInner, "x", 0.5, 1, -1, 1);
		animate(headInner, "y", 0.5, 1, -1, 1);*/
		
		headJitter = new JitterMotion(headInner);
		
		animate(hair, "scaleX", 0.2, 0.4, 0.95, 1.05);
		animate(hair, "scaleY", 0.2, 0.4, 0.95, 1.05);
		
		animate(display, "rotation", 0.5, 1, -3, 6);
		animate(display, "x", 0.5, 1, -5, 5);
		animate(display, "y", 0.5, 1, -5, 5);
		
		world.addChild(this);
	}
	
	function animate(part:DisplayObject, property:String, timeMin:Float, timeMax:Float, valueMin:Float, valueMax:Float, ease = null){
		function repeat() {
			if (ease == null) ease = Quad.easeInOut;
			var props:Dynamic = {};
			untyped {props[property] = Random.float(valueMin, valueMax) * animateAmount; }
			Actuate.stop(part);
			Actuate.tween(part, Random.float(timeMin, timeMax) * animateSpeed, props).ease(ease).onComplete(repeat);
		}
		repeat();
	}
	
	public function toggleAutoFly(height:Float){
		autoFly = true;
		autoFlyHeight = height;
		if (App.debug) {
			Main.self.debugContainer.graphics.lineStyle(1, 0x00ff00);
			Main.self.debugContainer.graphics.moveTo(0, height);
			Main.self.debugContainer.graphics.lineTo(App.SCREEN_WIDTH, height);
		}
	}
	
	public function update() 
	{
		var currTime = Timer.stamp();
		
		headJitter.update(lastTime - currTime);
		
		x += speedX;
		y -= speedY;
		rotation += (rotationTarget - rotation) / 8;
		
		rotationTarget = speedY.clamp( -20, 20) / 20 * -20;
		speedY = (speedY - gravity).clamp(-8, 50);
		speedX = (speedX - drag).clamp(3, 50);
		
		if (autoFly) {
			if (y > autoFlyHeight && flapTimer <= 0 && speedY < 0) {
				flap();
			}
		}
		if (App.debug) {
			Main.self.debugContainer.graphics.lineStyle(1, 0xff0000);
			Main.self.debugContainer.graphics.lineTo(x, y);
		}
		flapTimer -= 0.2;
		
		lastTime = currTime;
	}
	
	public function destroy() 
	{
		parent.removeChild(this);
	}
	
	public function flap() 
	{
		speedX += 2;
		speedY = 8;
		if (App.debug) {
			Main.self.debugContainer.graphics.drawCircle(x, y, 5);
		}
		flapTimer = 1;
		flapState = FlapState.DOWN;
		var time = Lib.getTimer()/1000.0;
		var downTime = Math.min(0.2, time-lastFlapTime);
		var upTime = Math.min(0.2, time-lastFlapTime);
		
		//SoundManager.playSound("assets/sounds/wing.wav");
		for (arm in arms) {
			var mirror = (arm == arms[0]) ? 1 : -1;
			Actuate.stop(arm);
			Actuate.tween(arm, downTime, { rotation: Random.float(-20,-40) * mirror }).ease(Quart.easeOut).onComplete(function(){
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