package;

using Utils;
using Lambda;

import components.Component;
import motion.Actuate;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.InteractiveObject;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.errors.Error;
import openfl.events.Event;
import openfl.geom.Matrix;

/**
 * ...
 * @author Tom Wilson
 */
class GameObject extends MovieClip
{
	var children:Array<GameObject> = [];
	var components:Array<components.Component> = [];
	var origDisplay:DisplayObject;
	
	public var parentGo(get, null):GameObject;
	
	public function new() 
	{
		super();
		
		addEventListener(Event.REMOVED, function(e:Event) {
			if (Std.is(e.target, GameObject))
				children.remove(cast(e.target, GameObject));
		});
		
		addEventListener(Event.ADDED, function(e:Event) {
			if (Std.is(e.target, GameObject))
				children.push(cast(e.target, GameObject));
		});
		
		/*if (display != null) {
			this.transform.matrix = display.transform.matrix;
			this.transform.colorTransform = display.transform.colorTransform;
			this.blendMode = display.blendMode;
			this.cacheAsBitmap = display.cacheAsBitmap;
			this.filters = display.filters;
			this.mask = display.mask;
			this.name = display.name;
			this.opaqueBackground = display.opaqueBackground;
			this.scrollRect = display.scrollRect;
			this.visible = display.visible;
			
			if (Std.is(display, DisplayObjectContainer)) {
				for (child in cast(display, DisplayObjectContainer).getChildren()) {
					this.addChild(child);
				}
			}
			if (Std.is(display, InteractiveObject)) {
				this.focusRect = cast(display, InteractiveObject).focusRect;
				this.doubleClickEnabled = cast(display, InteractiveObject).doubleClickEnabled;
			}
			if (Std.is(display, Sprite)) {
				this.buttonMode = cast(display, Sprite).buttonMode;
				this.graphics.copyFrom(cast(display, Sprite).graphics);
			}
			if (display.parent != null) {
				cast(display.parent, GameObject).addGameObject(this);
			}
			display.removeFromParent();
		}*/
		
		Main.self.gameObjects.push(this);
	}

	public function destroy() 
	{
		for (child in children.copy()) {
			child.destroy();
		}
		for (component in components.copy()) {
			component.unregister();
			component.destroy();
		}
		Actuate.stop(this);
		this.removeFromParent();
		Main.self.gameObjects.remove(this);
	}
	
	private function update() 
	{
		var components = this.components.copy();
		
		for (component in components)
			component.preUpdate();
		
		for (component in components)
			component.update();
			
		for (component in components)
			component.postUpdate();
	}
	
	public function getParent():GameObject
	{
		return cast(parent, GameObject);
	}
	
	/*override public function addChild(child:DisplayObject):DisplayObject 
	{
		if (Std.is(child, GameObject)) {
			throw new Error("GameObject should be added with addGameObject");
		}
		return super.addChild(child);
	}
	
	override public function removeChild(child:DisplayObject):DisplayObject 
	{
		if (Std.is(child, GameObject)) {
			throw new Error("GameObject should be removed with removeGameObject");
		}
		return super.removeChild(child);
	}
	
	override public function addChildAt(child:DisplayObject, index:Int):DisplayObject 
	{
		throw new Error("GameObject should be added with addGameObject");
		return super.addChildAt(child, index);
	}*/
	
	/*override public function removeChildAt(index:Int):DisplayObject 
	{
		if (Std.is(getChildAt(index), GameObject)) {
			throw new Error("GameObject should be removed with removeGameObject");
		}
		return super.removeChildAt(index);
	}
	
	override public function removeChildren(beginIndex:Int = 0, endIndex:Int = 0x7FFFFFFF):Void 
	{
		for (index in beginIndex...endIndex) {
			if (Std.is(getChildAt(index), GameObject)) {
				throw new Error("GameObject should be removed with removeGameObject");
			}
		}
		super.removeChildren(beginIndex, endIndex);
	}*/
	
	public function getAllComponent():Array<components.Component>
	{
		return components.copy();
	}
	
	public function getComponent(type:Dynamic):components.Component
	{
		for (c in components) {
			if (Std.is(c, type)) return cast(c, components.Component);
		}
		return null;
	}
	
	public function getComponents(type:Dynamic):Array<components.Component>
	{
		return components.filter(function (c) { return Std.is(c,type); }).array();
	}
	
	public function findParentComponent(type:Dynamic):components.Component
	{
		var p = getParent();
		while (p != null) {
			var component = p.getComponent(type);
			if (component != null ) return component;
			p = p.getParent();
		}
		return null;
	}
	
	public function addComponent(component:components.Component) 
	{
		if (component.gameObject != null)
			component.gameObject.removeComponent(component);
		component.gameObject = this;
		components.push(component);
		component.register();
	}
	
	public function removeComponent(component:components.Component) 
	{
		component.unregister();
		component.gameObject = null;
		components.remove(component);
	}
	
	public function get_parentGo():GameObject 
	{
		return cast(parent, GameObject);
	}
	
	public function getChildGoByName(name:String):GameObject 
	{
		return cast(getChildByName(name), GameObject);
	}
	
	static public function createWithDisplayObject(display:DisplayObject, recursive:Bool = true):GameObject
	{
		var go = new GameObject();
		go.origDisplay = display;
		go.addChild(display);
		go.transform.matrix = display.transform.matrix;
		go.name = display.name;
		
		display.transform.matrix = new Matrix();
		if (recursive) {
			if (Std.is(display, DisplayObjectContainer)) {
				var children = cast(display, DisplayObjectContainer).getChildren();
				for (c in children) {
					go.addChild(createWithDisplayObject(c, true));
				}
			}
		}
		return go;
	}
	
	static public function create(components:Array<Component>):GameObject
	{
		var go = new GameObject();
		for (c in components) go.addComponent(c);
		return go;
	}
	
	/*static public function create(parent:GameObject, components:Array<components.Component>):GameObject
	{
		var go = new GameObject();
		parent.addChild(go);
		for (c in components)
			go.addComponent(c);
		return go;
	}*/
}