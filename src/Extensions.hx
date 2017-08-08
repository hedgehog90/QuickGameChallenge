package;

using Extensions;

import nape.geom.Vec2;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Transform;
import spritesheet.data.BehaviorData;

/**
 * ...
 * @author Tom Wilson
 */

class Extensions {}
	
class DisplayObjectExtension {
	static public function removeFromParent(displayObject:DisplayObject):Void {
		if (displayObject.parent != null) {
			displayObject.parent.removeChild(displayObject);
		}
	}
	
	static private var tempPt:Point = new Point();
	static public function localToLocal(from:DisplayObject, to:DisplayObject, pt:Point = null):Point
	{
		if (pt == null) {
			pt = tempPt;
			pt.setTo(0, 0);
		}
		pt = to.globalToLocal(from.localToGlobal(pt));
		return pt;
	}
	
	static public function getChildren(o:DisplayObject):Array<DisplayObject> {
		var arr:Array<DisplayObject> = [];
		if (Std.is(o, DisplayObjectContainer)) {
			var container = cast(o, DisplayObjectContainer);
			for (i in 0...container.numChildren) {
				var child = container.getChildAt(i);
				arr.push(child);
			}
		}
		return arr;
	}
	
	static public function removeChildren(o:DisplayObject):Void {
		if (Std.is(o, DisplayObjectContainer)) {
			var container = cast(o, DisplayObjectContainer);
			while (container.numChildren > 0) {
				container.removeChildAt(0);
			}
		}
	}
	
	static public function getChildrenRecursively(o:DisplayObject):Array<DisplayObject> {
		var children = [];
		for (c in o.getChildren()) {
			children.push(c);
			children.pushMany(getChildrenRecursively(o));
		}
		return children;
	}
	
	static public function recurse(o:DisplayObject, check:DisplayObject->Utils.RecurseResult):Void {
		Utils.recurse(o, function(o:DisplayObject) { return o.getChildren(); }, check);
	}
	
	static public function getSymbolName(o:DisplayObject):String {
		#if flash
		return Type.getClassName(Type.getClass(o));
		#end
		
		var symbol = Reflect.getProperty(o, "__symbol");
		if (symbol != null) {
			return Reflect.getProperty(symbol, "className");
		}
		
		return null;
	}
	
}
	
class ArrayExtension {
	
	static public function contains<T>(array:Array<T>, element:T):Bool {
		return array.indexOf(element) > -1;
	}
	static public function pushMany<T>(array:Array<T>, many:Iterable<T>):Void {
		for (e in many) array.push(e);
	}
	
}
	
class TransformExtension {
	
	static public function getGlobalMatrix(t:Transform):Matrix {
		return t.concatenatedMatrix;
	}
	
	static public function setGlobalMatrix(t:Transform, gm1:Matrix):Void {
		t.matrix = new Matrix();
		var gm2 = t.getGlobalMatrix();
		var dif = gm2.difference(gm1);
		t.matrix = dif;
	}
	
	static public function differenceMatrix(t1:Transform, t2:Transform):Matrix {
		return getGlobalMatrix(t1).difference(getGlobalMatrix(t2));
	}
	
}
	
class MatrixExtension {
	
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
	
class Vec2Extension {
	static public function equals(a:Vec2, b:Vec2):Bool {
		return a.x == b.x && a.y == b.y;
	}
}
	
/*class AnimatedSpriteExtension {
	
	static public function getSize(data:BehaviorData):Point {
		return new Point(data.frameData[0].sourceSize.w, data.frameData[0].sourceSize.h);
	}
	
}*/