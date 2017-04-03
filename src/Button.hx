package;
import motion.Actuate;
import motion.easing.Bounce;
import motion.easing.Quad;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;

/**
 * ...
 * @author Tom Wilson
 */
class Button 
{
	public var onClick : Void->Void;
	public var onRollOver : Void->Void;
	public var onRollOut : Void->Void;
	var display:Sprite;
	var isOver:Bool;
	var isDown:Bool;

	public function new(display:Sprite) 
	{
		this.display = display;
		display.mouseEnabled = true;
		display.mouseChildren = false;
		display.buttonMode = true;
		display.addEventListener(MouseEvent.CLICK, _onClick);
		display.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
		display.addEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
		display.addEventListener(MouseEvent.ROLL_OVER, _onRollOver);
		display.addEventListener(MouseEvent.ROLL_OUT, _onRollOut);
	}
	
	public function destroy() 
	{
		display.removeEventListener(MouseEvent.CLICK, _onClick);
		display.removeEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
		display.removeEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
		display.removeEventListener(MouseEvent.ROLL_OVER, _onRollOver);
		display.removeEventListener(MouseEvent.ROLL_OUT, _onRollOut);
		display = null;
	}
	
	private function _onClick(e:MouseEvent):Void 
	{
		if (onClick != null) onClick();
	}
	
	private function _onMouseDown(e:MouseEvent):Void 
	{
		isDown = true;
		_onMouseDownDisplay();
		SoundManager.playSound("assets/sounds/buttonclick.wav");
	}
	
	private function _onMouseUp(e:MouseEvent):Void 
	{
		isDown = false;
		_onMouseUpDisplay();
		SoundManager.playSound("assets/sounds/buttonclickrelease.wav");
	}
	
	private function _onRollOver(e:MouseEvent=null):Void 
	{
		isOver = true;
		_onRollOverDisplay();
		if (onRollOver != null) onRollOver();
		SoundManager.playSound("assets/sounds/buttonrollover.wav");
	}
	
	private function _onRollOut(e:MouseEvent=null):Void 
	{
		isOver = false;
		_onRollOutDisplay();
		if (onRollOut != null) onRollOut();
	}
	
	function _onMouseDownDisplay() 
	{
		Actuate.stop(display);
		display.scaleX = display.scaleY = 0.9;
	}
	
	function _onMouseUpDisplay() 
	{
		Actuate.stop(display);
		if (isOver) _onRollOverDisplay();
		else Actuate.tween(display, 0.1, { scaleX: 1, scaleY: 1 }).ease(Quad.easeInOut);
	}
	
	function _onRollOverDisplay() 
	{
		Actuate.stop(display);
		Actuate.tween(display, 0.1, { scaleX: 1.1, scaleY: 1.1 }).ease(Quad.easeInOut);
	}
	
	function _onRollOutDisplay() 
	{
		Actuate.stop(display);
		Actuate.tween(display, 0.1, { scaleX: 1, scaleY: 1 }).ease(Quad.easeInOut);
	}
	
}