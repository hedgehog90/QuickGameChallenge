package;

using Utils.TransformUtils;
using Utils.MatrixUtils;

import haxe.Timer;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;

/**
 * ...
 * @author Tom Wilson
 */
class Camera extends GameObject
{
	var jitter:JitterMotion;
	var lastUpdate:Float=0;
	var world:DisplayObjectContainer;

	public function new(world:DisplayObjectContainer) 
	{
		super();
		this.world = world;
		
		jitter = new JitterMotion(this);
		if (App.debug){
			graphics.lineStyle(5, 0xff0000);
			graphics.drawRect(-App.SCREEN_WIDTH/2, -App.SCREEN_HEIGHT/2, App.SCREEN_WIDTH, App.SCREEN_HEIGHT);
		}
	}
	
	public function update() 
	{
		var worldMatrix = world.transform.getGlobalMatrix();
		var selfMatrix = transform.getGlobalMatrix();
		var diffMatrix = selfMatrix.difference(worldMatrix);
		diffMatrix.tx += App.SCREEN_WIDTH / 2;
		diffMatrix.ty += App.SCREEN_HEIGHT / 2;
		world.transform.matrix = diffMatrix;
	}
	
}