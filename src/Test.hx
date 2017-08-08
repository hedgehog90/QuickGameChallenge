package;
import openfl.Assets;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.FPS;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Matrix;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;

/**
 * ...
 * @author Tom Wilson
 */
class Test extends Sprite
{
	var tf:TextField;
	var fps:FPS;
	var cloudContainer:Sprite;
	var clouds:Array<DisplayObject> = new Array<DisplayObject>();

	public function new() 
	{
		super();
		
		addChild(cloudContainer = new Sprite());
		addChild(fps = new FPS());
		
		tf = new TextField();
		tf.width = 100;
		tf.autoSize = TextFieldAutoSize.LEFT;
		tf.x = fps.x;
		tf.y = fps.y + fps.height + 10;
		addChild(tf);
		
		createClouds();
		
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
		
		Lib.current.stage.addEventListener(MouseEvent.CLICK, onClick);
	}
	
	private function onClick(e:MouseEvent):Void 
	{
		createClouds();
	}
	
	private function onEnterFrame(e:Event):Void 
	{
		tf.text = Std.string(clouds.length);
		for (mc in clouds) {
			mc.x = Random.float(0, App.SCREEN_WIDTH);
			mc.y = Random.float(0, App.SCREEN_HEIGHT);
			mc.scaleX = Random.float(0.1, 1);
			mc.scaleY = Random.float(0.1, 1);
			mc.rotation = Random.float(0, 360);
		}
	}
	
	function createClouds() 
	{
		
		for (i in 0...100) {
			var n = Random.int(1, 4);
			var mc = Assets.getMovieClip('assets:cloud${n}');
			//mc.cacheAsBitmap = true;
			var bitmapData:BitmapData = new BitmapData(Std.int(mc.width), Std.int(mc.height));
			var r = mc.getRect(null);
			var m = new Matrix();
			m.tx = -r.x;
			m.ty = -r.y;
			bitmapData.draw(mc, m);
			var bitmap = new Bitmap(bitmapData);
			cloudContainer.addChild(bitmap);
			clouds.push(bitmap);
			//cloudContainer.addChild(mc);
			//clouds.push(mc);
			//cloudContainer.addChild(mc);
			//clouds.push(mc);
		}
	}
	
}