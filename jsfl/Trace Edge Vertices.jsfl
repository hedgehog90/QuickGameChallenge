fl.runScript(fl.scriptURI+"/../shared/Global.jsfl");

fl.outputPanel.clear();
var doc = fl.getDocumentDOM();

var selected = doc.selection;
selected.forEach(function(e) {
	var pts = [];
	e.contours.forEach(function(c) {
		if (c.orientation == -1) {
			var he = c.getHalfEdge();
			var iStart = he.id;
			var id = 0;
			while (id != iStart) {
				var edge = he.getEdge();
				var vrt = he.getVertex();
				pts.push(new Point(vrt.x, vrt.y));
				he = he.getNext();
				id = he.id;
			}
		}
	});
	trace(pts);
});