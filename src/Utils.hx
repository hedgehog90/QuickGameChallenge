package;
import openfl.geom.Matrix;
import openfl.geom.Transform;

/**
 * ...
 * @author Tom Wilson
 */

class Utils {}

class TransformUtils 
{
	static public function getGlobalMatrix(transform:Transform) {
		return transform.concatenatedMatrix;
	}
}

class MatrixUtils 
{
	static public function difference(m1:Matrix, m2:Matrix) {
		return multiply(m2, inverse(m1));
	}
		
	static public function multiply (m2:Matrix, m1:Matrix):Matrix {
		var a = m1.a * m2.a + m1.b * m2.c;
		var b = m1.a * m2.b + m1.b * m2.d;
		var c = m1.c * m2.a + m1.d * m2.c;
		var d = m1.c * m2.b + m1.d * m2.d;
		var tx = m1.tx * m2.a + m1.ty * m2.c + m2.tx;
		var ty = m1.tx * m2.b + m1.ty * m2.d + m2.ty;
		return new Matrix(a,b,c,d,tx,ty);
	}

	static public function inverse(m:Matrix):Matrix {
		var norm = m.a * m.d - m.b * m.c;
		var output = new Matrix();
		if (norm == 0) {
			output.a = output.b = output.c = output.d = 0;
			output.tx = -m.tx;
			output.ty = -m.ty;
		} else {
			norm = 1.0 / norm;
			output.a = m.d * norm;
			output.d = m.a * norm;
			output.b = m.b * -norm;
			output.c = m.c * -norm;
			output.tx = -output.a * m.tx - output.c * m.ty;
			output.ty = -output.b * m.tx - output.d * m.ty;
		}
		return output;
	}
	
}