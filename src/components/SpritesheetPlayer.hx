package components;

using Utils;

import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import spritesheet.AnimatedSprite;
import spritesheet.Spritesheet;
import spritesheet.data.SpritesheetFrame;

/**
 * ...
 * @author Tom Wilson
 */
class SpritesheetPlayer extends Component
{
	public var gameObject(get, null):Sprite;
	function get_gameObject():Sprite { return cast(_gameObject, Sprite); }
	
	var animatedSprite:AnimatedSprite;

	public function new(spritesheet:Spritesheet) 
	{
		super();
		
		animatedSprite = new AnimatedSprite(spritesheet, true);
	}
	
	override function onEnable() 
	{
		super.onEnable();
		gameObject.addChild(animatedSprite);
	}
	
	override function onDisable() 
	{
		super.onDisable();
		animatedSprite.removeFromParent();
	}
	
	public function play(behaviour:String) 
	{
		animatedSprite.showBehavior(behaviour);
	}
	
	override function onUpdate() 
	{
		super.onUpdate();
		
		animatedSprite.update(App.deltaTime);
	}
	
}