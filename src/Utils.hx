package;

/**
 * ...
 * @author Tom Wilson
 */

enum RecurseResult {
	Recurse; // normal
	SkipChildren; // skip children
	SkipSiblings; // skip siblings
	Exit; // exit completely
}

class Utils 
{
	static public function recurse(root:Dynamic, getChildren:Dynamic, check:Dynamic):Void {
		function _recurse(o) {
			var result = Reflect.callMethod(check, check, [o]);
			if (result == RecurseResult.Recurse) {
				var children:Iterable<Dynamic> = cast Reflect.callMethod(getChildren, getChildren, [o]);
				for (c in children) {
					var result2 = _recurse(c);
					if (result2 == RecurseResult.SkipSiblings) break;
					if (result2 == RecurseResult.Exit) return result2;
				}
			}
			return result;
		}
		_recurse(root);
	}
	
	//t is percent between 0 and 1
	static public function evaluatePercent(a:Float, b:Float, t:Float):Float {
		return a + (b - a) * t;
	}
	
	//t is between a and b
	static public function evaluate(a:Float, b:Float, t:Float):Float {
		return evaluatePercent(a, b, (t - a) / (b - a));
	}
	
	//t is between a and b
	static public function calculatePercent(a:Float, b:Float, t:Float):Float {
		return (evaluate(a, b, t) - a) / (b - a);
	}
	
	static public function deg2rad(v:Float) {
		return v * Math.PI / 180;
	}
	
	static public function rad2deg(v:Float) {
		return v * 180 / Math.PI;
	}
}