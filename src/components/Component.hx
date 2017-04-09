package components;

/**
 * ...
 * @author Tom Wilson
 */
class Component 
{
	@:allow(GameObject)
	private var gameObject:GameObject;

	public function new() 
	{
	}
	
	@:allow(GameObject)
	private function register() 
	{
	}
	
	@:allow(GameObject)
	private function unregister() 
	{
	}
	
	@:allow(GameObject)
	private function preUpdate() 
	{
	}
	
	@:allow(GameObject)
	private function update() 
	{
	}
	
	@:allow(GameObject)
	private function postUpdate() 
	{
	}
	
	public function destroy() 
	{
		if (gameObject != null)
			gameObject.removeComponent(this);
		gameObject = null;
	}
	
}