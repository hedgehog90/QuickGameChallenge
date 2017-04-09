package motion.easing;
import motion.easing.IEasing;
import openfl.errors.Error;

/**
 * ...
 * @author Tom Wilson
 */
class Bezier implements IEasing
{
	var mX1:Float;
	var mY1:Float;
	var mX2:Float;
	var mY2:Float;
	var mSampleValues:Array<Float> = [];
	
	static var NEWTON_ITERATIONS:Int = 4;
	static var NEWTON_MIN_SLOPE:Float = 0.001;
	static var SUBDIVISION_PRECISION:Float = 0.0000001;
	static var SUBDIVISION_MAX_ITERATIONS:Int = 10;

	static var kSplineTableSize:Int = 11;
	static var kSampleStepSize:Float = 1.0 / (kSplineTableSize - 1.0);
	
	public function new(mX1:Float, mY1:Float, mX2:Float, mY2:Float) 
	{
		this.mY2 = mY2;
		this.mX2 = mX2;
		this.mY1 = mY1;
		this.mX1 = mX1;
		
		if (mX1 < 0 || mX1 > 1 || mX2 < 0 || mX2 > 1) {
			throw new Error("BezierEasing x values must be in [0, 1] range.");
		}
		if (mX1 != mY1 || mX2 != mY2)
			calcSampleValues();
	}
	
    function A (aA1:Float, aA2:Float):Float { return 1.0 - 3.0 * aA2 + 3.0 * aA1; }
    function B (aA1:Float, aA2:Float):Float { return 3.0 * aA2 - 6.0 * aA1; }
    function C (aA1:Float):Float      		{ return 3.0 * aA1; }
	
    // Returns x(t) given t, x1, and x2, or y(t) given t, y1, and y2.
    function calcBezier (aT:Float, aA1:Float, aA2:Float):Float {
		return ((A(aA1, aA2)*aT + B(aA1, aA2))*aT + C(aA1))*aT;
    }
   
    // Returns dx/dt given t, x1, and x2, or dy/dt given t, y1, and y2.
    function getSlope (aT:Float, aA1:Float, aA2:Float):Float {
		return 3.0 * A(aA1, aA2)*aT*aT + 2.0 * B(aA1, aA2) * aT + C(aA1);
    }

    function newtonRaphsonIterate (aX:Float, aGuessT:Float):Float {
		for (i in 0...NEWTON_ITERATIONS) {
			var currentSlope = getSlope(aGuessT, mX1, mX2);
			if (currentSlope == 0.0) return aGuessT;
				var currentX = calcBezier(aGuessT, mX1, mX2) - aX;
			aGuessT -= currentX / currentSlope;
		}
		return aGuessT;
    }

    function calcSampleValues():Void {
		for (i in 0...kSplineTableSize) {
			mSampleValues[i] = calcBezier(i * kSampleStepSize, mX1, mX2);
		}
    }

    function binarySubdivide (aX:Float, aA:Float, aB:Float) {
		var currentX:Float, currentT:Float = 0.0;
		var i = 0;
		do {
			currentT = aA + (aB - aA) / 2.0;
			currentX = calcBezier(currentT, mX1, mX2) - aX;
			if (currentX > 0.0) {
				aB = currentT;
			} else {
				aA = currentT;
			}
		} while (Math.abs(currentX) > SUBDIVISION_PRECISION && ++i < SUBDIVISION_MAX_ITERATIONS);
		return currentT;
    }

	public function calculate(k:Float):Float 
	{
		if (mX1 == mY1 && mX2 == mY2) {
			return k; // linear
		}
			// Because JavaScript number are imprecise, we should guarantee the extremes are right.
		if (k == 0) {
			return 0;
		}
		if (k == 1) {
			return 1;
		}
		return calcBezier(getTForX(k), mY1, mY2);
	}

	public function getTForX(aX:Float):Float 
	{
		var intervalStart = 0.0;
		var currentSample = 1;
		var lastSample = kSplineTableSize - 1;

		while (currentSample != lastSample && mSampleValues[currentSample] <= aX) {
			intervalStart += kSampleStepSize;
			currentSample++;
		}
		--currentSample;

		// Interpolate to provide an initial guess for t
		var dist = (aX - mSampleValues[currentSample]) / (mSampleValues[currentSample+1] - mSampleValues[currentSample]);
		var guessForT = intervalStart + dist * kSampleStepSize;

		var initialSlope = getSlope(guessForT, mX1, mX2);
		if (initialSlope >= NEWTON_MIN_SLOPE) {
			return newtonRaphsonIterate(aX, guessForT);
		} else if (initialSlope == 0.0) {
			return guessForT;
		} else {
			return binarySubdivide(aX, intervalStart, intervalStart + kSampleStepSize);
		}
	}

	public function ease(t:Float, b:Float, c:Float, d:Float):Float 
	{
		return 0;
	}
	
	
}