package components;

using Extensions;

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
	public var display(default,null):AnimatedSprite;

	public function new() 
	{
		super();
		display = new AnimatedSprite(Main.self.assetsSpritesheet, true);
	}
	
	override function onEnable() 
	{
		super.onEnable();
		gameObjectSprite.addChild(display);
	}
	
	override function onDisable() 
	{
		super.onDisable();
		display.removeFromParent();
	}
	
	public function play(behaviour:String) 
	{
		display.showBehavior(behaviour);
	}
	
	override function onUpdate() 
	{
		super.onUpdate();
		
		display.update(App.deltaTime);
	}
	
}