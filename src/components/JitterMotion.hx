package components;
import components.Component;
import components.JitterMotion.JitterMotionProperties;
import noisehx.Perlin;

/**
 * ...
 * @author Tom Wilson
 */
class JitterMotion extends Component
{	
	var timePosition:Float;
	var timeScale:Float;
	var timeRotation:Float;
    var noiseVectors:Array<Array<Float>> = [];
	public var properties:JitterMotionProperties;
	
	static var perlin = new Perlin();

	public function new() 
	{
		super();
		properties = new JitterMotionProperties();
    }

	override public function register() 
	{
		super.register();
		
		timePosition = Math.random() * 10;
        timeScale = Math.random() * 10;
        timeRotation = Math.random() * 10;

        for (i in 0...5)
        {
            var theta = Math.random() * Math.PI * 2;
            noiseVectors[i] = [Math.cos(theta), Math.sin(theta)];
        }
		
        updateValues();
    }

    override public function update()
	{
		super.update();
		
        timePosition += App.deltaTime * properties.positionFrequency;
        timeScale += App.deltaTime * properties.scaleFrequency;
        timeRotation += App.deltaTime * properties.rotationFrequency;

        updateValues();
    }
	
	function updateValues() 
	{
		var x = 0.0;
		var y = 0.0;
		var scaleX = 1.0;
		var scaleY = 1.0;
		var rotation = 0.0;
		
		if (properties.positionAmount != 0.0)
        {
           x = Fbm(noiseVectors[0][0] * timePosition, noiseVectors[0][1] * timePosition, properties.positionOctave) * properties.positionXComponent * properties.positionAmount * 2;
           y = Fbm(noiseVectors[1][0] * timePosition, noiseVectors[1][1] * timePosition, properties.positionOctave) * properties.positionYComponent * properties.positionAmount * 2;
        }

        if (properties.scaleAmount != 0.0)
        {
           scaleX = 1 + Fbm(noiseVectors[2][0] * timeScale, noiseVectors[2][1] * timeScale, properties.scaleOctave) * properties.scaleXComponent * properties.scaleAmount * 2;
           scaleY = 1 + Fbm(noiseVectors[3][0] * timeScale, noiseVectors[3][1] * timeScale, properties.scaleOctave) * properties.scaleYComponent * properties.scaleAmount * 2;
        }

        if (properties.rotationAmount != 0.0)
        {
            rotation = Fbm(noiseVectors[4][0] * timeRotation, noiseVectors[4][1] * timeRotation, properties.rotationOctave) * properties.rotationComponent * properties.rotationAmount * 2;
        }
		
		gameObject.x = x;
		gameObject.y = y;
		gameObject.scaleX = scaleX;
		gameObject.scaleY = scaleY;
		gameObject.rotation = rotation;
		
		/*gameObject.x += x - lastX;
		gameObject.y += y - lastY;
		gameObject.scaleX += scaleX - lastScaleX;
		gameObject.scaleY += scaleY - lastScaleY;
		gameObject.rotation += rotation - lastRotation;
		
		lastX = x;
		lastY = y;
		lastScaleX = scaleX;
		lastScaleY = scaleY;
		lastRotation = rotation;*/
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
	
    public var positionFrequency:Float = 0.2;
    public var scaleFrequency:Float = 0.2;
    public var rotationFrequency:Float = 0.2;

    public var positionAmount:Float = 10;
    public var scaleAmount:Float = 0.0;
    public var rotationAmount:Float = 15.0;

    public var positionXComponent:Float = 1;
    public var positionYComponent:Float = 1;
    public var scaleXComponent:Float = 1;
    public var scaleYComponent:Float = 1;
    public var rotationComponent:Float = 1;

    public var positionOctave:Int = 3;
    public var rotationOctave:Int = 3;
    public var scaleOctave:Int = 3;
	
	public function new() 
	{
    }
	
	/*public function set(properties:Dynamic) 
	{
		var fields = Reflect.fields(properties);
		for (f in fields) {
			Reflect.setField(this, f, Reflect.field(properties, properties));
		}
	}*/
}