package components;

using Utils;

import components.MainMenu;
import haxe.macro.ComplexTypeTools;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.events.Event;

/**
 * ...
 * @author Tom Wilson
 */
typedef Constructible = {
    public function new(c:Component):Void;
}

class Component
{
	private var _gameObject(default, null):DisplayObject;
	public var isDestroyed(default, null):Bool;
	
	static public var components(default,null):Array<Component> = [];
	static public var map(default,null):Map<DisplayObject, Array<Component>> = new Map<DisplayObject, Array<Component>>();
	
	static public function update() 
	{
		var components = Component.components.copy();
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
	
	static public function createGameObject(componentClasses:Array<Class<Component>>, displayClass:Class<DisplayObject> = null):DisplayObject
	{
		if (displayClass == null) displayClass = Sprite;
		var go = Type.createInstance(displayClass, []);
		for (componentClazz in componentClasses)
			Type.createInstance(componentClazz, []).attach(go);
		return go;
	}
	
	//-------------------------------------------------------------------------------------------------
	
	@:generic
	static public function addComponent<T:(Constructible, Component)>(go:DisplayObject, type:Class<T>):T
	{
		var c = new T();
		c.attach(go);
	}
	
	static public function removeComponent(go:DisplayObject, component:Component):Void
	{
		if (component._gameObject == go) component.detach();
	}
	
	@:generic
	static public function getComponents<T:Component>(go:DisplayObject, type:Class<T>):Array<T>
	{
		var arr:Array<T> = [];
		var components = getAllComponents(go);
		for (c in components) {
			if (Std.is(c, type)) arr.push(c);
		}
	}
	
	static public function getAllComponents(go:DisplayObject):Array<Component>
	{
		return map.exists(go) ? map.get(go).copy() : [];
	}
	
	@:generic
	static public function getComponent<T:Component>(go:DisplayObject, type:Class<T>):Null<T>
	{
		var components = getAllComponents(go);
		for (c in components) {
			if (Std.is(c, T)) return cast(c,T);
		}
		return null;
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
	
	static public function destroyWithComponents(go:DisplayObject):Void
	{	
		if (Std.is(go, DisplayObjectContainer)) {
			for (child in cast(go, DisplayObjectContainer).getChildren())
				destroyWithComponents(child);
		}
		
		for (component in getComponents(go))
			component.destroy();
		
		go.removeFromParent();
	}
	
	//-------------------------------------------------------------------------------------------------

	public function new() 
	{
		components.push(this);
	}
	
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
	
	//-------------------------------------------------------------------------------------------------
	
	@:final
	public function attach(gameObject:DisplayObject) {
		if (_gameObject == gameObject) return;
		
		detach();
		_gameObject = gameObject;
		//this._gameObject = new GameObject(gameObject);
		
		if (!map.exists(_gameObject)) map.set(_gameObject, new Array<Component>());
		var components = map.get(_gameObject);
		components.push(this);
		
		onRegister();
		
		if (_gameObject.stage != null) {
			onEnable();
		}
		
		_gameObject.addEventListener(Event.ADDED_TO_STAGE, onStageChange);
		_gameObject.addEventListener(Event.REMOVED_FROM_STAGE, onStageChange);
	}
	
	private function onStageChange(e:Event):Void 
	{
		if (_gameObject.stage != null) {
			onEnable();
		} else {
			onDisable();
		}
	}
	
	@:final
	public function detach() 
	{
		if (_gameObject == null) return;
		
		onUnregister();
		
		var components = map.get(_gameObject);
		components.remove(this);
		if (components.length == 0)
			map.remove(_gameObject);
			
		_gameObject.removeEventListener(Event.ADDED_TO_STAGE, onStageChange);
		_gameObject.removeEventListener(Event.REMOVED_FROM_STAGE, onStageChange);
		
		_gameObject = null;
		//_gameObject = null;
	}
	
	@:final
	public function destroy() 
	{
		isDestroyed = true;
		detach();
		components.remove(this);
	}
	
	@:final
	public function destroyWithGameObject() 
	{
		if (_gameObject == null) destroy();
		else destroyWithComponents(_gameObject);
	}
}