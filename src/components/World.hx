package components;
import components.Camera;
import components.Component;
import components.FlappyFrost;
import components.Follow;
import components.JitterMotion;
import motion.Actuate;
import motion.easing.Quart;
import openfl.display.Sprite;
import openfl.geom.Rectangle;

/**
 * ...
 * @author Tom Wilson
 */
class World extends Component
{
	public var cameraOuter(default, null):GameObject;
	public var cameraInner(default, null):GameObject;
	public var debugContainer(default, null):GameObject;
	var bg:GameObject;
	var bgContainer:GameObject;
	var camera:Camera;
	var frost:FlappyFrost;
	var jitter:components.JitterMotion;

	override function register() 
	{
		Main.self.world = this;
		
		super.register();
		
		bg = new GameObject();
		bg.graphics.beginFill(0xffffff, 1);
		bg.graphics.drawRect(0, 0, App.SCREEN_WIDTH, App.SCREEN_HEIGHT);
		
		gameObject.addChild(bg);
		gameObject.addChild(cameraOuter = new GameObject());
		cameraOuter.addChild(cameraInner = new GameObject());
		gameObject.addChild(debugContainer = new GameObject());
		
		camera = new Camera(gameObject);
		cameraInner.addComponent(camera);
		
		jitter = new JitterMotion();
		var menuCameraJitter = new JitterMotionProperties();
		menuCameraJitter.positionAmount = 50;
		menuCameraJitter.positionFrequency = 0.2;
		menuCameraJitter.positionXComponent = 2;
		jitter.properties = menuCameraJitter;
		//jitter.rotationAmount = 30;
		//jitter.rotationFrequency = 1;
		//jitter.scaleFrequency = 1;
		//jitter.scaleAmount = 0.05;
		
		cameraInner.addComponent(jitter);
		
		var frostGo = new GameObject();
		gameObject.addChild(frostGo);
		frostGo.addComponent(frost = new FlappyFrost());
		
		frostGo.x = App.SCREEN_WIDTH * Math.random();
		frostGo.y = Random.float(100, App.SCREEN_HEIGHT - 100);
		frost.toggleAutoFly();
		
		var follow = new Follow();
		follow.target = frostGo;
		follow.bounds = new Rectangle(Math.NEGATIVE_INFINITY, frostGo.y, Math.POSITIVE_INFINITY, frostGo.y);
	
		cameraOuter.addComponent(follow);
	}
	
	public function start() 
	{
		Actuate.tween(camera, 3, {zoom:0.1}).ease(Quart.easeInOut);
	}
	
	override function update() 
	{
		super.update();
		
		//jitter.properties.positionXComponent = 1 / cameraOuter.scaleX;
		//jitter.properties.positionYComponent = 1 / cameraOuter.scaleY;
		//jitter.properties.scaleXComponent = 1 / cameraOuter.scaleX;
		//jitter.properties.scaleYComponent = 1 / cameraOuter.scaleY;
	}
	
}