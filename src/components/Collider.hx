package components;
import components.Component;
import nape.geom.GeomPoly;
import nape.geom.Vec2;
import nape.phys.Material;
import nape.shape.Circle;
import nape.shape.Polygon;
import nape.shape.Shape;
using components.Component;

using Extensions;

/**
 * ...
 * @author Tom Wilson
 */

class Collider extends Component
{
	private var _shapes:Array<Shape> = [];
	public var shapes(get, null):Array<Shape>;
	public var material:Material;
	
	public function addBox(pos:Vec2, size:Vec2, material:Material = null):Polygon {
		var shape = new Polygon(Polygon.rect(pos.x - size.x, pos.y - size.y, size.x * 2, size.y * 2, true), material);
		_shapes.push(shape);
		return shape;
	}
	
	public function addCircle(pos:Vec2, radius:Float, material:Material=null):Circle {
		var shape = new Circle(radius, pos, material);
		_shapes.push(shape);
		return shape;
	}
	
	public function addPolygon(vertices:Array<Vec2>, material:Material = null):Array<Polygon> {
		var poly = new GeomPoly(vertices);
		var polyList = poly.convexDecomposition(true);
		var polygons:Array<Polygon> = [];
		for (poly in polyList) {
			var p = new Polygon(poly, material);
			polygons.push(p);
			//_shapes.push(p);
		}
		_shapes.pushMany(polygons);
		return polygons;
	}
	
	public function setAllSensors(value:Bool) 
	{
		for (s in _shapes) s.sensorEnabled = value;
	}
	
	function get_shapes():Array<Shape> 
	{
		var shapes = _shapes.copy();
		for (i in 0...shapes.length) shapes[i] = shapes[i].copy();
		return shapes;
	}
}