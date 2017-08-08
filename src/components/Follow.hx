package components;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.geom.Point;
import openfl.geom.Rectangle;

using Extensions;
using Thx.Floats;

/**
 * ...
 * @author Tom Wilson
 */
class Follow extends Component
{
	public var bounds:Rectangle = new Rectangle(Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY);
	public var target:DisplayObject;
	public var easing:Float = 0.0;

	public function new() 
	{
		super();
	}

	override function onUpdate() 
	{
		super.onUpdate();
		
		if (target != null) {
			
			/*var pt1 = Sprite.localToGlobal(new Point());
			var pt2 = target.localToGlobal(new Point());
			var dif = Sprite.parent.globalToLocal(pt2.subtract(pt1));
			Sprite.x += dif.x;
			Sprite.y += dif.y;*/
			
			/*var m = target.transform.getGlobalMatrix();
			m.a = m.d = 1;
			m.b = m.c = 0;
			Sprite.transform.setGlobalMatrix(m);*/
			
			var m1 = target.transform.getGlobalMatrix();
			var m2 = gameObject.parent.transform.getGlobalMatrix();
			var dif = m2.difference(m1);
			
			var x = dif.tx.clamp(bounds.left, bounds.right);
			//var y = dif.ty.clamp(bounds.top, bounds.bottom);
			
			if (easing == 0) {
				gameObject.x = x;
				//gameObject.y = y;
			} else {
				gameObject.x += (x - gameObject.x) * (1 - easing);
				//gameObject.y += (y - gameObject.y) * (1 - easing);
			}
		}
	}
	
}