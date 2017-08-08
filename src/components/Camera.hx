package components;

using Extensions;

import components.Component;
import haxe.Timer;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;

/**
 * ...
 * @author Tom Wilson
 */
class Camera extends Component
{
	public var context(default,set):DisplayObject;
	public var contextMatrix(default,null):Matrix = new Matrix();
	public var zoom:Float = 1.0;
	public var rect:Rectangle = new Rectangle();
	
	override function onEnable() 
	{
		super.onEnable();
		
		updateMatrix();
		
		if (App.debug){
			var graphics = cast(gameObject, Sprite).graphics;
			graphics.lineStyle(5, 0xff0000);
			graphics.drawRect(-App.SCREEN_WIDTH/2, -App.SCREEN_HEIGHT/2, App.SCREEN_WIDTH, App.SCREEN_HEIGHT);
			graphics.lineStyle(1, 0xff0000);
			graphics.moveTo(-App.SCREEN_WIDTH/2, -App.SCREEN_HEIGHT/2);
			graphics.lineTo(App.SCREEN_WIDTH/2, App.SCREEN_HEIGHT/2);
			graphics.moveTo(-App.SCREEN_WIDTH/2, App.SCREEN_HEIGHT/2);
			graphics.lineTo(App.SCREEN_WIDTH/2, -App.SCREEN_HEIGHT/2);
		}
	}
	
	override public function onUpdate() 
	{
		super.onUpdate();
	}
	
	override public function onPostUpdate() 
	{
		super.onPostUpdate();
		
		updateMatrix();
	}
	
	function updateMatrix() 
	{
		if (context == null) return;
		var matrix = context.transform.differenceMatrix(gameObject.transform);
		
		var rectMatrix = matrix.clone();
		var pos = rectMatrix.transformPoint(new Point());
		rectMatrix.scale(1/zoom,1/zoom);
		var dim = rectMatrix.deltaTransformPoint(new Point(App.SCREEN_WIDTH, App.SCREEN_HEIGHT));
		rect.x = pos.x-dim.x/2;
		rect.y = pos.y-dim.y/2;
		rect.width = dim.x;
		rect.height = dim.y;
		
		matrix.invert();
		matrix.scale(zoom,zoom);
		matrix.translate(App.SCREEN_WIDTH / 2, App.SCREEN_HEIGHT / 2);
		
		contextMatrix.copyFrom(matrix);
		
		context.transform.matrix = matrix;
	}
	
	function set_context(value:DisplayObject):DisplayObject 
	{
		context = value;
		updateMatrix();
		return context;
	}
	
}