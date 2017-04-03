package;
import openfl.display.DisplayObject;
import openfl.display.Sprite;

/**
 * ...
 * @author Tom Wilson
 */
class GameObject extends Sprite
{
	var children:Array<GameObject> = [];

	public function new() 
	{
		super();
		Main.self.gameObjects.push(this);
	}

	public function destroy() 
	{
		Main.self.gameObjects.remove(this);
	}

	public function update() 
	{
		
	}
	
	public function add(go:GameObject)
	{
		super.addChild(go);
		go.parent = this;
	}
	
	override public function addChildAt(child:DisplayObject, index:Int):DisplayObject 
	{
		throw new Error("Can only add GameObjects");
	}
	
	override public function removeChild(child:DisplayObject):DisplayObject 
	{
		throw new Error("Can only add GameObjects");
	}
	
}