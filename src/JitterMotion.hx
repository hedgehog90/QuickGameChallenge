package;
import noisehx.Perlin;
import openfl.display.DisplayObject;

/**
 * ...
 * @author Tom Wilson
 */
class JitterMotion 
{
    public var positionFrequency:Float = 0.2;
    public var scaleFrequency:Float = 0.2;
    public var rotationFrequency:Float = 0.2;

    public var positionAmount:Float = 10;
    public var scaleAmount:Float = 0.15;
    public var rotationAmount:Float = 15.0;

    public var positionXComponent:Float = 1;
    public var positionYComponent:Float = 1;
    public var scaleXComponent:Float = 1;
    public var scaleYComponent:Float = 1;
    public var rotationComponent:Float = 1;

    public var positionOctave:Int = 3;
    public var rotationOctave:Int = 3;
    public var scaleOctave:Int = 3;

	var display:DisplayObject;
    var initialPositionX:Float = 0;
    var initialPositionY:Float = 0;
    var initialScaleX:Float = 1;
    var initialScaleY:Float = 1;
    var initialRotation:Float = 0;
	var timePosition:Float;
	var timeScale:Float;
	var timeRotation:Float;
    var noiseVectors:Array<Array<Float>> = [];
	
	static var perlin = new Perlin();

	public function new(display:DisplayObject) 
	{
		this.display = display;
		timePosition = Math.random() * 10;
        timeScale = Math.random() * 10;
        timeRotation = Math.random() * 10;

        for (i in 0...5)
        {
            var theta = Math.random() * Math.PI * 2;
            noiseVectors[i] = [Math.cos(theta), Math.sin(theta)];
        }

        initialPositionX = display.x;
        initialPositionY = display.y;
        initialScaleX = display.scaleX;
        initialScaleY = display.scaleY;
        initialRotation = display.rotation;
    }

    public function update(deltaTime:Float)
	{
        timePosition += deltaTime * positionFrequency;
        timeRotation += deltaTime * rotationFrequency;

        if (positionAmount != 0.0)
        {
           display.x = Fbm(noiseVectors[0][0] * timePosition, noiseVectors[0][1] * timePosition, positionOctave) * positionXComponent * positionAmount * 2;
           display.y = Fbm(noiseVectors[1][0] * timePosition, noiseVectors[1][1] * timePosition, positionOctave) * positionYComponent * positionAmount * 2;
        }

        if (scaleAmount != 0.0)
        {
           display.scaleX = 1 + Fbm(noiseVectors[2][0] * timePosition, noiseVectors[2][1] * timeScale, scaleOctave) * scaleXComponent * scaleAmount * 2;
           display.scaleY = 1 + Fbm(noiseVectors[3][0] * timePosition, noiseVectors[3][1] * timeScale, scaleOctave) * scaleYComponent * scaleAmount * 2;
		   trace(display.scaleX, display.scaleY);
        }

        if (rotationAmount != 0.0)
        {
            display.rotation = Fbm(noiseVectors[4][0] * timeRotation, noiseVectors[4][1] * timeRotation, rotationOctave) * rotationComponent * rotationAmount * 2;
        }
    }

    static function Fbm(x:Float, y:Float, octave:Int)
    {
        var f = 0.0;
        var w = 1.0;
        for (i in 0...octave)
        {
            f += w * perlin.noise2d(x, y) * 0.5;
            x *= 2;
            y *= 2;
            w *= 0.5;
        }
        return f;
    }
}