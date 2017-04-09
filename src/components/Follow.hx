package components;
import openfl.display.DisplayObject;
import openfl.geom.Point;
import openfl.geom.Rectangle;

using Utils;
using Thx.Floats;

/**
 * ...
 * @author Tom Wilson
 */
class Follow extends Component
{
	public var bounds:Rectangle = new Rectangle(Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY);
	public var target:DisplayObject;

	public function new() 
	{
		super();
	}

	override function update() 
	{
		super.update();
		
		if (target != null) {
			/*var pt1 = gameObject.localToGlobal(new Point());
			var pt2 = target.localToGlobal(new Point());
			var dif = gameObject.parent.globalToLocal(pt2.subtract(pt1));
			gameObject.x += dif.x;
			gameObject.y += dif.y;*/
			
			/*var m = target.transform.getGlobalMatrix();
			m.a = m.d = 1;
			m.b = m.c = 0;
			gameObject.transform.setGlobalMatrix(m);*/
			
			var m1 = target.transform.getGlobalMatrix();
			var m2 = gameObject.parent.transform.getGlobalMatrix();
			var dif = MatrixUtils.difference(m2, m1);
			
			gameObject.x = dif.tx.clamp(bounds.left, bounds.right);
			gameObject.y = dif.ty.clamp(bounds.top, bounds.bottom);
		}
	}
	
}