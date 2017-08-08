package components;
import components.Component;
import motion.Actuate;
import motion.easing.Bounce;
import motion.easing.Quad;
import openfl.display.DisplayObject;
import openfl.display.InteractiveObject;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;

/**
 * ...
 * @author Tom Wilson
 */
class Button extends Component
{
	public var onClick : Void->Void;
	public var onRollOver : Void->Void;
	public var onRollOut : Void->Void;
	public var enabled(default,set):Bool;
	var isOver:Bool;
	var isDown:Bool;

	override public function onEnable() 
	{
		super.onEnable();
		
		enabled = true;
		gameObject.addEventListener(MouseEvent.CLICK, _onClick);
		gameObject.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
		gameObject.addEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
		gameObject.addEventListener(MouseEvent.ROLL_OVER, _onRollOver);
		gameObject.addEventListener(MouseEvent.ROLL_OUT, _onRollOut);
	}
	
	override public function onDisable() 
	{
		super.onDisable();
		
		enabled = false;
		gameObject.removeEventListener(MouseEvent.CLICK, _onClick);
		gameObject.removeEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
		gameObject.removeEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
		gameObject.removeEventListener(MouseEvent.MOUSE_OVER, _onRollOver);
		gameObject.removeEventListener(MouseEvent.MOUSE_OUT, _onRollOut);
	}
	
	private function _onClick(e:MouseEvent):Void 
	{
		if (!enabled) return;
		if (onClick != null) onClick();
	}
	
	private function _onMouseDown(e:MouseEvent):Void 
	{
		if (!enabled) return;
		isDown = true;
		_onMouseDownDisplay();
		SoundManager.playSound("assets/sounds/buttonclick.wav");
	}
	
	private function _onMouseUp(e:MouseEvent):Void 
	{
		if (!enabled) return;
		isDown = false;
		_onMouseUpDisplay();
		SoundManager.playSound("assets/sounds/buttonclickrelease.wav");
	}
	
	private function _onRollOver(e:MouseEvent=null):Void 
	{
		if (!enabled) return;
		isOver = true;
		_onRollOverDisplay();
		if (onRollOver != null) onRollOver();
		SoundManager.playSound("assets/sounds/buttonrollover.wav");
	}
	
	private function _onRollOut(e:MouseEvent=null):Void 
	{
		if (!enabled) return;
		isOver = false;
		_onRollOutDisplay();
		if (onRollOut != null) onRollOut();
	}
	
	function _onMouseDownDisplay() 
	{
		Actuate.stop(gameObject);
		gameObject.scaleX = gameObject.scaleY = 0.9;
	}
	
	function _onMouseUpDisplay() 
	{
		Actuate.stop(gameObject);
		if (isOver) _onRollOverDisplay();
		else Actuate.tween(gameObject, 0.1, { scaleX: 1, scaleY: 1 }).ease(Quad.easeInOut);
	}
	
	function _onRollOverDisplay() 
	{
		Actuate.stop(gameObject);
		Actuate.tween(gameObject, 0.1, { scaleX: 1.1, scaleY: 1.1 }).ease(Quad.easeInOut);
	}
	
	function _onRollOutDisplay() 
	{
		Actuate.stop(gameObject);
		Actuate.tween(gameObject, 0.1, { scaleX: 1, scaleY: 1 }).ease(Quad.easeInOut);
	}
	
	function set_enabled(value:Bool):Bool 
	{
		gameObjectSprite.mouseEnabled = value;
		gameObjectSprite.mouseChildren = !value;
		gameObjectSprite.buttonMode = value;
		return enabled = value;
	}
	
}