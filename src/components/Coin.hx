package components;

using components.Component;

import components.Component;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Circle;
import openfl.display.Sprite;
import spritesheet.AnimatedSprite;
import spritesheet.data.SpritesheetFrame;

/**
 * ...
 * @author Tom Wilson
 */
class Coin extends Component
{
	var body:Body;
	var world:World;
	public var gameObject(get, null):Sprite;
	function get_gameObject():Sprite { return cast(_gameObject, Sprite); }

	public function new() 
	{
		super();
		world = gameObject.getParentComponent(World);
	}
	
	public function hit() 
	{
		world.score += 100;
		destroyWithGameObject();
	}
	
	override function onEnable() 
	{
		super.onEnable();
		
		var spritesheetPlayer = new SpritesheetPlayer(Main.self.assetsSpritesheet);
		gameObject.addComponent(spritesheetPlayer);
		spritesheetPlayer.play("coin");
		
		body = new Body(BodyType.STATIC);
		var shape = new Circle(10);
		shape.sensorEnabled = true;
		body.shapes.add(shape);
		body.space = Main.self.world.space;
		body.userData = gameObject;
	}
	
	override function onDisable() 
	{
		super.onDisable();
		body.space = null;
	}
	
}