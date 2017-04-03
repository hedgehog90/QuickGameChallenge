package states;
import motion.Actuate;
import motion.easing.Expo;
import motion.easing.Quad;
import openfl.Assets;
import openfl.Lib;
import openfl.display.DisplayObject;
import openfl.display.MovieClip;
import openfl.display.SimpleButton;
import openfl.display.Sprite;
import openfl.events.MouseEvent;

/**
 * ...
 * @author Tom Wilson
 */
class MainMenu extends GameObject
{
	var menu:MovieClip;
	var button:Sprite;
	var copyright:Sprite;
	var title:Sprite;
	var _button:Button;
	var bg:Sprite;
	var bgContainer:Sprite;
	var uiContainer:Sprite;
	var frosts:Array<FlappyFrost> = [];
	var world:World;

	public function new() 
	{
		super();
		
		addChild(bgContainer = new Sprite());
		addChild(world = new World());
		addChild(uiContainer = new Sprite());
		
		initMenu();
		initFrosts();
	}
	
	function initFrosts() 
	{
		for (i in 0...1) {
			var frost = new FlappyFrost(world);
			frost.x = App.SCREEN_WIDTH * Math.random();
			frost.y = Random.float(100, App.SCREEN_HEIGHT - 100);
			frost.toggleAutoFly(Random.float(-50, 50) + frost.y);
			frosts.push(frost);
		}
	}
	
	function initMenu() 
	{
		bg = new Sprite();
		bg.graphics.beginFill(0xffffff, 1);
		bg.graphics.drawRect(0, 0, App.SCREEN_WIDTH, App.SCREEN_HEIGHT);
		bgContainer.addChild(bg);
		
		menu = Assets.getMovieClip("assets:main_menu");
		uiContainer.addChild(menu);
		
		button = cast(menu.getChildByName("startButton"), Sprite);
		copyright = cast(menu.getChildByName("copyright"), Sprite);
		title = cast(menu.getChildByName("title"), Sprite);
		
		Main.self.menuContainer.addChild(this);
		
		Actuate.tween(title, 1, { scaleX: 1.1, scaleY: 1.1 }).ease(Quad.easeInOut).repeat().reflect();
		title.rotation = -5;
		Actuate.tween(title, 0.5, { rotation: 5 }).ease(Quad.easeInOut).repeat().reflect();
		
		_button = new Button(button);
		_button.onClick = function(){
			Main.self.fadeTo(function(){
				new states.Game();
				destroy();
			});
		};
	}
	
	function destroy() 
	{
		_button.destroy();
		parent.removeChild(this);
		for (f in frosts) {
			f.destroy();
		}
	}
	
	public function update() 
	{
		button.x = App.SCREEN_WIDTH / 2;
		button.y = App.SCREEN_HEIGHT / 2;
		
		copyright.x = App.SCREEN_WIDTH;
		copyright.y = App.SCREEN_HEIGHT;
		
		title.x = App.SCREEN_WIDTH/2;
		title.y = Math.max(App.SCREEN_HEIGHT * 0.133, title.height / 2 + 10);
		
		bg.scaleX = App.stageScaleX;
		bg.scaleY = App.stageScaleY;
		for (f in frosts) {
			f.update();
			if (f.x > App.SCREEN_WIDTH + 100) {
				f.x = -100;
			}
			world.camera.x = f.x;
			world.camera.y = f.y;
		}
		camera.update();
	}
	
}