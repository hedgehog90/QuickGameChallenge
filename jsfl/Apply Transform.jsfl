fl.runScript(fl.scriptURI+"/../shared/Global.jsfl");

fl.outputPanel.clear();

var doc = fl.getDocumentDOM();

var selected = doc.selection;

selected.forEach(function(e) {
	applyMatrixToContainer(e, new Matrix(e.matrix), true);
});