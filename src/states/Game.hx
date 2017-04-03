package states;
import motion.Actuate;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;

/**
 * ...
 * @author Tom Wilson
 */
class Game extends GameObject
{
	var backgroundContainer:Sprite;
	var floorContainer:Sprite;
	var frostContainer:Sprite;
	
	var camera:Camera;
	var frost:FlappyFrost;

	public function new() 
	{
		Main.self.game = this;
		
		super();
		
		Lib.current.stage.addChild(this);
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
		
		addChild(backgroundContainer = new Sprite());
		addChild(floorContainer = new Sprite());
		addChild(frostContainer = new Sprite());
		
		frost = new FlappyFrost();
		
		//camera = new Camera();
	}
	
	private function onEnterFrame(e:Event):Void 
	{
		frost.update();
		//camera.update();
	}
	
}