package components;
import components.Component;
import components.JitterMotion.JitterMotionProperties;
import noisehx.Perlin;
import openfl.display.DisplayObject;
import openfl.display.Sprite;

/**
 * ...
 * @author Tom Wilson
 */
class JitterMotion extends Component
{
	public var gameObject(get, null):Sprite;
	function get_gameObject():Sprite { return cast(_gameObject, Sprite); }
	
	static var perlin = new Perlin();
	
	var timePosition:Float;
	var timeScale:Float;
	var timeRotation:Float;
    var noiseVectors:Array<Array<Float>> = [];
	
	var origX:Float;
	var origY:Float;
	var origScaleX:Float;
	var origScaleY:Float;
	var origRotation:Float;
	
	var lastX:Float=0;
	var lastY:Float=0;
	var lastScaleX:Float=1.0;
	var lastScaleY:Float=1.0;
	var lastRotation:Float=0;
	
	public var properties:JitterMotionProperties;
	public var restrained:Bool = true;

	public function new() 
	{
		super();
		properties = new JitterMotionProperties();
		properties.set();
    }

	override public function onEnable() 
	{
		super.onEnable();
		
		timePosition = Random.float(0,10);
        timeScale = Random.float(0,10);
        timeRotation = Random.float(0,10);

        for (i in 0...5)
        {
            var theta = Math.random() * Math.PI * 2;
            noiseVectors[i] = [Math.cos(theta), Math.sin(theta)];
        }
		
		recordOrigValues();
		
        updateValues();
    }
	
	public function recordOrigValues() 
	{
		origX = gameObject.x;
		origY = gameObject.y;
		origScaleX = gameObject.scaleX;
		origScaleY = gameObject.scaleY;
		origRotation = gameObject.rotation;
	}

    override public function onUpdate()
	{
		super.onUpdate();
		
        timePosition += App.deltaTime/1000.0 * properties.positionFrequency;
        timeScale += App.deltaTime/1000.0 * properties.scaleFrequency;
        timeRotation += App.deltaTime/1000.0 * properties.rotationFrequency;

        updateValues();
    }
	
	function updateValues() 
	{
		var x:Float = 0.0;
		var y:Float = 0.0;
		var scaleX:Float = 1.0;
		var scaleY:Float = 1.0;
		var rotation:Float = 0.0;
		
		if (properties.positionAmount != 0.0)
        {
			var positionFbm1 = Fbm(noiseVectors[0][0] * timeScale, noiseVectors[0][1] * timeScale, properties.positionOctave);
			var positionFbm2 = properties.positionLock ? positionFbm1 : Fbm(noiseVectors[1][0] * timeScale, noiseVectors[1][1] * timeScale, properties.positionOctave);
           x = positionFbm1 * properties.positionXComponent * properties.positionAmount * 2;
           y = positionFbm2 * properties.positionYComponent * properties.positionAmount * 2;
        }

        if (properties.scaleAmount != 0.0)
        {
			var scaleFbm1 = Fbm(noiseVectors[2][0] * timeScale, noiseVectors[2][1] * timeScale, properties.scaleOctave);
			var scaleFbm2 = properties.scaleLock ? scaleFbm1 : Fbm(noiseVectors[3][0] * timeScale, noiseVectors[3][1] * timeScale, properties.scaleOctave);
           scaleX = 1+scaleFbm1 * properties.scaleXComponent * properties.scaleAmount * 2;
           scaleY = 1+scaleFbm2 * properties.scaleYComponent * properties.scaleAmount * 2;
        }

        if (properties.rotationAmount != 0.0)
        {
            rotation = Fbm(noiseVectors[4][0] * timeRotation, noiseVectors[4][1] * timeRotation, properties.rotationOctave) * properties.rotationComponent * properties.rotationAmount * 2;
        }
		
		if (restrained) {
			gameObject.x = origX + x;
			gameObject.y = origY + y;
			gameObject.rotation = origRotation + rotation;
			gameObject.scaleX = origScaleX * scaleX;
			gameObject.scaleY = origScaleY * scaleY;
		} else {
			gameObject.x += x - lastX;
			gameObject.y += y - lastY;
			gameObject.scaleX += scaleX - lastScaleX;
			gameObject.scaleY += scaleY - lastScaleY;
			gameObject.rotation += rotation - lastRotation;
		}
		
		lastX = x;
		lastY = y;
		lastScaleX = scaleX;
		lastScaleY = scaleY;
		lastRotation = rotation;
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

class JitterMotionProperties {
	
    public var positionFrequency:Float = 0;
    public var scaleFrequency:Float = 0;
    public var rotationFrequency:Float = 0;

    public var positionAmount:Float = 0;
    public var scaleAmount:Float = 0;
    public var rotationAmount:Float = 0;

    public var positionXComponent:Float = 0;
    public var positionYComponent:Float = 0;
    public var scaleXComponent:Float = 0;
    public var scaleYComponent:Float = 0;
    public var rotationComponent:Float = 0;

    public var positionOctave:Int = 3;
    public var rotationOctave:Int = 3;
    public var scaleOctave:Int = 3;
	
    public var positionLock:Bool = false;
    public var scaleLock:Bool = false;
	
	public function new() 
	{
    }
	
	public function set(pa:Float=10, pf:Float=0.2, pxc:Float=1, pyc:Float=1, ra:Float=15, rf:Float=0.2, rc:Float=1, sa:Float=0, sf:Float=0.2, sxc:Float=1, syc:Float=1) 
	{
		positionAmount = pa;
		positionFrequency = pf;
		positionXComponent = pxc;
		positionYComponent = pyc;
		
		rotationAmount = ra;
		rotationFrequency = rf;
		rotationComponent = rc;
		
		scaleAmount = sa;
		scaleFrequency = sf;
		scaleXComponent = sxc;
		scaleYComponent = syc;
	}
	
	/*public function set(properties:Dynamic) 
	{
		var fields = Reflect.fields(properties);
		for (f in fields) {
			Reflect.setField(this, f, Reflect.field(properties, properties));
		}
	}*/
}