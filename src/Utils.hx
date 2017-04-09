package;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Transform;

/**
 * ...
 * @author Tom Wilson
 */

class Utils { }
	
class DisplayObjectContainerUtils {
	
	static public function getChildren(displayObjectContainer:DisplayObjectContainer):Array<DisplayObject> {
		var arr:Array<DisplayObject> = [];
		for (i in 0...displayObjectContainer.numChildren) {
			arr.push(displayObjectContainer.getChildAt(i));
		}
		return arr;
	}
	
}
	
class DisplayObjectUtils {
	
	static public function removeFromParent(displayObject:DisplayObject):Void {
		if (displayObject.parent != null) {
			displayObject.parent.removeChild(displayObject);
		}
	}
	
	static public function localToLocal(from:DisplayObject, to:DisplayObject):Point
	{
		var point:Point = new Point();
		point = from.localToGlobal(point);
		point = to.globalToLocal(point);
		return point;
	}
	
}
	
class ArrayUtils {
	
	static public function contains<T>(array:Array<T>, element:T):Bool {
		return array.indexOf(element) > -1;
	}
	
}
	
class TransformUtils {
	
	static public function getGlobalMatrix(t:Transform):Matrix {
		return t.concatenatedMatrix;
	}
	
	static public function setGlobalMatrix(t:Transform, gm1:Matrix):Void {
		t.matrix = new Matrix();
		var gm2 = getGlobalMatrix(t);
		var dif = MatrixUtils.difference(gm2, gm1);
		t.matrix = dif;
	}
	
	static public function differenceMatrix(t1:Transform, t2:Transform):Matrix {
		return MatrixUtils.difference(getGlobalMatrix(t1), getGlobalMatrix(t2));
	}
	
}
	
class MatrixUtils {
	
	static public function difference(m2:Matrix, m1:Matrix):Matrix {
		m1 = m1.clone();
		m2 = m2.clone();
		m2.invert();
		m1.concat(m2);
		return m1;
	}
	
	static public function applyMatrix(t:Transform, m:Matrix):Void {
		m = m.clone();
		m.concat(t.matrix);
		t.matrix = m;
	}
	
}