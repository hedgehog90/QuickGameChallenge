package;
import openfl.display.Sprite;

/**
 * ...
 * @author Tom Wilson
 */
class World extends GameObject
{
	var debugContainer:Sprite;
	var camera:Camera;

	public function new() 
	{
		addChild(camera = new Camera(this));
		addChild(debugContainer = new Sprite());
	}
	
}