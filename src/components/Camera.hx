package components;

using Utils;

import components.Component;
import haxe.Timer;
import lime.math.Rectangle;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.geom.Matrix;

/**
 * ...
 * @author Tom Wilson
 */
class Camera extends Component
{
	public var context:GameObject;
	public var zoom:Float = 1.0;

	public function new(context:GameObject) 
	{
		this.context = context;
		
		super();
	}
	
	override function register() 
	{
		super.register();
		
		updateMatrix();
		
		if (App.debug){
			gameObject.graphics.lineStyle(5, 0xff0000);
			gameObject.graphics.drawRect(-App.SCREEN_WIDTH/2, -App.SCREEN_HEIGHT/2, App.SCREEN_WIDTH, App.SCREEN_HEIGHT);
			gameObject.graphics.lineStyle(1, 0xff0000);
			gameObject.graphics.moveTo(-App.SCREEN_WIDTH/2, -App.SCREEN_HEIGHT/2);
			gameObject.graphics.lineTo(App.SCREEN_WIDTH/2, App.SCREEN_HEIGHT/2);
			gameObject.graphics.moveTo(-App.SCREEN_WIDTH/2, App.SCREEN_HEIGHT/2);
			gameObject.graphics.lineTo(App.SCREEN_WIDTH/2, -App.SCREEN_HEIGHT/2);
		}
	}
	
	override public function update() 
	{
		super.update();
	}
	
	override public function postUpdate() 
	{
		super.postUpdate();
		
		updateMatrix();
	}
	
	function updateMatrix() 
	{
		//var worldMatrix = context.transform.getGlobalMatrix();
		//context.transform.matrix = new Matrix();
		var matrix = context.transform.differenceMatrix(gameObject.transform);
		//var matrix = gameObject.transform.matrix;
		//matrix.concat(gameObject.parent.transform.matrix);
		//trace(gameObject.transform.matrix);
		matrix.invert();
		matrix.scale(zoom,zoom);
		matrix.tx += App.SCREEN_WIDTH / 2;
		matrix.ty += App.SCREEN_HEIGHT / 2;
		context.transform.matrix = matrix;
		
		//var diffMatrix = context.transform.differenceMatrix(gameObject.transform);
		//diffMatrix.tx += App.SCREEN_WIDTH / 2;
		//diffMatrix.ty += App.SCREEN_HEIGHT / 2;
		//diffMatrix.invert();
		//context.transform.matrix = diffMatrix;
	}
	
}