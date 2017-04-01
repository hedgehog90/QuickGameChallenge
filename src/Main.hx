package;

import lime.app.Future;
import motion.Actuate;
import motion.easing.Elastic;
import openfl.Vector;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.Lib;
import openfl.events.Event;
import openfl.filters.BlurFilter;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import openfl.utils.AssetLibrary;
import thx.promise.Promise;

/**
 * ...
 * @author Tom Wilson
 */
class Main extends Sprite 
{
	var _library:AssetLibrary;
	var frostHead:MovieClip;

	public function new() 
	{
		super();
		addEventListener(Event.ADDED_TO_STAGE, init);
	}
	
	private function init(event:Event)
	{
		removeEventListener(Event.ADDED_TO_STAGE, init);
		
		var promises:Array<Promise<thx.Nil>> = [
			Promise.create(function(resolve:thx.Nil->Void, reject:thx.Error->Void) {
				var loader = AssetLibrary.loadFromFile("assets/assets.bundle");
				loader.onComplete(function(library:AssetLibrary) {
					_library = library;
					resolve(thx.Nil.nil);
				});
				loader.onError(function(e:Dynamic){
					reject(thx.Error.fromDynamic(e));
				});
			})
		];
		
		Promise.afterAll(promises).then(function(result:thx.Result<thx.Nil, thx.Error>){
			start();
		});
	}
	
	function start() 
	{
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
		frostHead = _library.getMovieClip("frost");
		addChild(frostHead);
		frostHead.x = stage.stageWidth / 2;
		frostHead.y = stage.stageHeight / 2;
		
		var tf = new TextField();
		tf.y = frostHead.y + frostHead.height / 2 + 30;
		tf.selectable = false;
		var format = new TextFormat();
		format.size = 30;
		format.font = "Arial";
		format.align = TextFormatAlign.CENTER;
		tf.defaultTextFormat = format;
		tf.text = "LOADING";
		tf.width = stage.stageWidth;
	    addChild(tf);
		
		Actuate.tween(frostHead, 1, { rotation: 360 }).repeat();
		Actuate.tween(frostHead, 1, { scaleX: 1, scaleY: 1 } ).ease(Elastic.easeOut).repeat().reflect();
		//Actuate.effects(frostHead, 1).filter(BlurFilter, { blurX: 1, blurY: 1 }).repeat().reflect();
	}
	
	private function onEnterFrame(e:Event):Void 
	{
	}

}
