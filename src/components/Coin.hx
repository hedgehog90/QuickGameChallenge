package components;

using components.Component;

import components.Component;
import nape.geom.Mat23;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Circle;
import openfl.display.Sprite;
import openfl.geom.Point;
import spritesheet.AnimatedSprite;
import spritesheet.data.SpritesheetFrame;

/**
 * ...
 * @author Tom Wilson
 */
class Coin extends Component
{
	var rigidBody:RigidBody;
	var world:World;
	
	public function new() 
	{
		super();
	}
	
	override function onEnable() 
	{
		super.onEnable();
		
		world = gameObjectSprite.getParentComponent(World);
		
		var spritesheetPlayer = gameObject.addComponent(SpritesheetPlayer);
		spritesheetPlayer.play("coin");
		
		var collider:Collider = gameObject.addComponent(Collider);
		collider.addCircle(Vec2.weak(), 12);
		collider.setAllSensors(true);
		rigidBody = gameObject.addComponent(RigidBody);
		rigidBody.body.type = BodyType.KINEMATIC;
		updatePosition();
	}
	
	override function onDisable() 
	{
		super.onDisable();
		world = null;
		rigidBody = null;
	}
	
	override function onPreUpdate() 
	{
		super.onPreUpdate();
		
		//updatePosition();
	}
	
	public function updatePosition() 
	{
		rigidBody.body.position = Vec2.fromPoint(world.getPosition(gameObject), true);
	}
	
	public function hit() 
	{
		world.score += 10;
		SoundManager.playSound("assets/sounds/ding.wav", 1, 0, true);
		destroyWithGameObject();
	}
	
}