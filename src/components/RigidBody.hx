package components;

import components.Collider;
import nape.geom.Mat23;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Compound;
import nape.phys.MassMode;
import nape.shape.Circle;
import nape.shape.Shape;
import openfl.geom.Point;
import openfl.media.SoundMixer;

using Extensions;
using components.Component;

/**
 * ...
 * @author Tom Wilson
 */
class RigidBody extends Component
{
	public var body(default, null):Body;
	var world:World;
	
	override function onEnable() 
	{
		super.onEnable();
		world = gameObject.getParentComponent(World);
		body = new Body(BodyType.DYNAMIC);
		body.space = world.space;
		body.userData.gameObject = gameObject;
		updateColliders();
	}
	
	override function onDisable() 
	{
		super.onDisable();
		body.space = null;
		body = null;
		world = null;
	}
	
	override function onPreUpdate() 
	{
		super.onPreUpdate();
		
		var pt = world.getPosition(gameObject);
		body.position.x = pt.x;
		body.position.y = pt.y;
	}
	
	override function onPostUpdate() 
	{
		super.onPostUpdate();
		
		world.setPosition(gameObject, body.position.x, body.position.y);
		gameObject.rotation = Utils.rad2deg(body.rotation);
	}
	
	public function updateColliders() 
	{ 
		body.shapes.clear();
		var colliders = gameObject.getComponentsInChildren(Collider);
		for (c in colliders) {
			for (s in c.shapes) {
				var matrix = gameObject.transform.differenceMatrix(c.gameObject.transform);
				var m23 = Mat23.fromMatrix(matrix).equiorthogonalise();
				s.transform(m23);
				body.shapes.add(s);
			}
		}
	}
	
}