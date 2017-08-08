package components;

using Extensions;
using Lambda;

import components.Coin;
import components.MainMenu;
import haxe.macro.ComplexTypeTools;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.events.Event;

/**
 * ...
 * @author Tom Wilson
 */
typedef Constructible = {
    public function new():Void;
}

class Component
{
	static public var ALL_COMPONENTS(default,null):Array<Component> = [];
	static public var GAME_OBJECT_COMPONENT_MAP(default, null):Map<DisplayObject, Array<Component>> = new Map<DisplayObject, Array<Component>>();
	
	public var gameObject(default, set):DisplayObject;
	function set_gameObject(value:DisplayObject):DisplayObject 
	{
		if (gameObject != value) {
			gameObject = value;
			if (Std.is(gameObject, Sprite)) gameObjectSprite = cast(gameObject, Sprite);
			if (Std.is(gameObject, MovieClip)) gameObjectMovieClip = cast(gameObject, MovieClip);
		}
		return gameObject;
	}
	public var gameObjectSprite(default, null):Sprite;
	public var gameObjectMovieClip(default, null):MovieClip;
	
	public var isEnabled(default, set):Bool;
	private function set_isEnabled(value:Bool):Bool 
	{
		if (isEnabled != value) {
			isEnabled = value;
			if (isEnabled) onEnable();
			else onDisable();
		}
		return isEnabled;
	}
	
	public var isDestroyed(default, null):Bool;
	
	static public function update() 
	{
		var components = Component.ALL_COMPONENTS.copy();
		for (component in components) {
			if (!component.isDestroyed) component.onPreUpdate();
		}
		for (component in components) {
			if (!component.isDestroyed) component.onUpdate();
		}
		for (component in components) {
			if (!component.isDestroyed) component.onPostUpdate();
		}
	}
	
	//-------------------------------------------------------------------------------------------------
	
	@:generic
	static public function createGameObject<T:(Constructible, Component)>(componentClasses:Array<Class<T>>, displayClass:Class<DisplayObject> = null):DisplayObject
	{
		if (displayClass == null) displayClass = Sprite;
		var go = Type.createInstance(displayClass, []);
		for (componentClazz in componentClasses)
			new T().attach(go);
		return go;
	}
	
	@:generic
	static public function addComponent<T:(Constructible, Component)>(go:DisplayObject, type:Class<T>):T
	{
		var c = new T();
		c.attach(go);
		return c;
	}
	
	static public function removeComponent(go:DisplayObject, component:Component):Void
	{
		if (component.gameObject == go) component.detach();
	}
	
	@:generic
	static public function getComponents<T:Component>(go:DisplayObject, type:Class<T>):Array<T>
	{
		var arr:Array<T> = [];
		var components = getAllComponents(go);
		for (c in components) {
			if (Std.is(c, type)) arr.push(cast c);
		}
		return arr;
	}
	
	static public function getAllComponents(go:DisplayObject):Array<Component>
	{
		return GAME_OBJECT_COMPONENT_MAP.exists(go) ? GAME_OBJECT_COMPONENT_MAP.get(go).copy() : [];
	}
	
	@:generic
	static public function getComponent<T:Component>(go:DisplayObject, type:Class<T>):Null<T>
	{
		var components = getAllComponents(go);
		var a = getAllComponents(go);
		for (c in components) {
			if (Std.is(c, type)) return cast c;
		}
		return null;
	}
	
	@:generic
	static public function getComponentsFromMultiple<T:Component>(gos:Array<DisplayObject>, type:Class<T>):Array<T>
	{
		var arr:Array<T> = [];
		for (go in gos) {
			arr.pushMany(getComponents(go, type));
		}
		return arr;
	}
	
	@:generic
	static public function getParentComponent<T:Component>(go:DisplayObject, type:Class<T>):Null<T>
	{
		var parent = go.parent;
		while (parent != null) {
			var c = getComponent(parent, type);
			if (c != null) return cast c;
			parent = parent.parent;
		}
		return null;
	}
	
	@:generic
	static public function getComponentsInChildren<T:Component>(go:DisplayObject, type:Class<T>, includeSelf:Bool = true):Array<T>
	{
		var arr:Array<T> = [];
		go.recurse(function(child) {
			if (includeSelf || go != child) arr.pushMany(getComponents(child, type));
			return Utils.RecurseResult.Recurse;
		});
		return arr;
	}
	
	@:generic
	static public function getComponentInChildren<T:Component>(go:DisplayObject, type:Class<T>, includeSelf:Bool = true):Null<T>
	{
		var found:T = null;
		go.recurse(function(child) {
			if (includeSelf || go != child) found = getComponent(child, type);
			return found == null ? Utils.RecurseResult.Recurse : Utils.RecurseResult.Exit;
		});
		return found;
	}
	
	static public function destroyGameObject(go:DisplayObject):Void
	{
		for (component in getAllComponents(go))
			component.destroy();
		
		for (child in go.getChildren())
			destroyGameObject(child);
		
		go.removeFromParent();
	}
	
	//-------------------------------------------------------------------------------------------------

	//important incase dce, as it's not referenced anywhere.
	@:keep
	public function new() 
	{
		ALL_COMPONENTS.push(this);
	}
	
	@:final
	public function attach(gameObject:DisplayObject) {
		if (this.gameObject == gameObject) return;
		
		detach();
		
		this.gameObject = gameObject;
		//this.gameObject = new GameObject(gameObject);
		
		if (!GAME_OBJECT_COMPONENT_MAP.exists(gameObject)) GAME_OBJECT_COMPONENT_MAP.set(gameObject, new Array<Component>());
		var components = GAME_OBJECT_COMPONENT_MAP.get(gameObject);
		components.push(this);
		
		onRegister();
		
		if (gameObject.stage != null) {
			isEnabled = true;
		}
		gameObject.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		gameObject.addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
	}
	
	private function onAddedToStage(e:Event):Void 
	{
		isEnabled = true;
	}
	
	private function onRemovedFromStage(e:Event):Void 
	{
		isEnabled = false;
	}
	
	@:final
	public function detach() 
	{
		if (gameObject == null) return;
		
		onUnregister();
		
		var components = GAME_OBJECT_COMPONENT_MAP.get(gameObject);
		components.remove(this);
		if (components.length == 0)
			GAME_OBJECT_COMPONENT_MAP.remove(gameObject);
			
		gameObject.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		gameObject.removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		
		isEnabled = false; // <-- important, onRemovedFromStage won't get called now so do it manually
		
		gameObject = null;
		//gameObject = null;
	}
	
	@:final
	public function destroy() 
	{
		isDestroyed = true;
		detach();
		ALL_COMPONENTS.remove(this);
	}
	
	@:final
	public function destroyWithGameObject() 
	{
		if (gameObject == null) destroy();
		else destroyGameObject(gameObject);
	}
	
	//-------------------------------------------------------------------------------------------------
	
	private function onEnable() 
	{
	}
	
	private function onDisable() 
	{
	}
	
	private function onRegister() 
	{
	}
	
	private function onUnregister() 
	{
	}
	
	private function onPreUpdate() 
	{
	}
	
	private function onUpdate() 
	{
	}
	
	private function onPostUpdate() 
	{
	}
}