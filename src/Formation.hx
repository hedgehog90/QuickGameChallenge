package;
import openfl.geom.Point;

/**
 * ...
 * @author Tom Wilson
 */
class Formation 
{
	static var sqrt3 = Math.sqrt(3);
	static var cos30 = Math.cos(Math.PI / 180 * 30);
	static var sin30 = Math.sin(Math.PI / 180 * 30);

	static public function rect(w:Int, h:Int):Array<Point> {
		var array:Array<Point> = [];
		for (c in 0...w) {
			for (r in 0...h) {
				var pt = new Point(sqrt3 * (Math.floor(c - r / 2) + r / 2), 3 / 2 * r);
				pt.x -= sqrt3 * (w - 3 / 2) / 2;
				pt.y -= 3 / 2 * (h - 1) / 2;
				array.push(pt);
			}
		}
		return array;
	}

	static public function triangle(s:Int):Array<Point> {
		s += 1;
		var array:Array<Point> = [];
		for (r in 0...s) {
			for (c in 0...r) {
				var pt = new Point(sqrt3 * (c + r / 2), 3 / 2 * r);
				pt.x -= (c * 2 + 1 / 2) * sqrt3;
				pt.y -= 3 / 2 * s / 2;
				array.push(pt);
			}
		}
		return array;
	}

	static public function diamond(s:Int):Array<Point> {
		s += 1;
		var array:Array<Point> = [];
		for (r in 0...s) {
			for (c in 0...r) {
				var pt = new Point(sqrt3 * (c + r / 2), 3 / 2 * r);
				pt.x -= (c * 2 + 1 / 2) * sqrt3;
				pt.y -= 3 / 2 * (s - 1);
				array.push(pt);
				if (r < s) {
					pt = pt.clone();
					pt.y *= -1;
					array.push(pt);
				}
			}
		}
		return array;
	}

	static public function hexagon(s:Int):Array<Point> {
		var array:Array<Point> = [];
		var half:Int = Std.int(s / 2);
		for (r in ((s + 1) % 2)...s) {
			var cols:Int = s - Std.int(Math.abs(r - half));
			for (c in 0...cols) {
				var xLbl:Int = r < half ? c - r : c - half;
				var yLbl:Int = r - half;
				var x = (cos30 * (c * 2 + 1 - cols));
				var y = (sin30 * (r - half) * 3);
				array.push(new Point(x, y));
			}
		}
		return array;
	}

	/*function diamond(size: int, horizontal: Boolean = false): Array {
		var matrix = new Matrix();
		if (horizontal) {
			matrix.rotate(-30 * (Math.PI / 180.0));
			matrix.translate(-size, 0);
		} else {
			matrix.rotate(60 * (Math.PI / 180.0));
			matrix.translate(0, -size);
		}
		if (size <= 1) {
			return [new Point()];
		} else {
			var array: Array = [];
			for (var r = 0; r < size; r++) {
				for (var c = 0; c < size; c++) {
					var pt = new Point(sqrt3 * (c + r / 2), 3 / 2 * r);
					pt = matrix.transformPoint(pt);
					array.push(pt);
				}
			}
		}
		return array;
	}*/
	
}