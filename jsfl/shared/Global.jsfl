fl.runScript(fl.scriptURI+"/../Path.jsfl");
fl.runScript(fl.scriptURI+"/../Geom.jsfl");
fl.runScript(fl.scriptURI+"/../JSON.jsfl");

var dir = Path.normalize(fl.configDirectory);
var userDir = dir.split("/").slice(0,3).join("/");
var tempDir = Path.join(userDir, "AppData/Local/Temp/jsfl");
Path.assertDir(tempDir);

var ElementType = function() {};
ElementType.shape = "shape";
ElementType.text = "text";
ElementType.tlfText = "tlfText";
ElementType.instance = "instance";
ElementType.shapeObj = "shapeObj";

var InstanceType = function() {};
InstanceType.symbol =  "symbol";
InstanceType.bitmap = "bitmap";
InstanceType.embeddedVideo = "embedded video";
InstanceType.linkedVideo = "linked video";
InstanceType.video = "video";
InstanceType.compiledClip = "compiled clip";

var SymbolType = function() {};
SymbolType.button = "button";
SymbolType.movieClip = "movie clip";
SymbolType.graphic = "graphic";

var ItemType = function() {};
ItemType.undefined =  "undefined";
ItemType.component = "component";
ItemType.movieClip = "movie clip";
ItemType.graphic = "graphic";
ItemType.button = "button";
ItemType.folder = "folder";
ItemType.font = "font";
ItemType.sound = "sound";
ItemType.bitmap = "bitmap";
ItemType.compiledClip = "compiled clip";
ItemType.screen = "screen";
ItemType.video = "video";

var BitmapRenderMode = function() {};
BitmapRenderMode.none =  "none";
BitmapRenderMode.cache = "cache";
BitmapRenderMode.export = "export";

var RegsitrationPoint = function() {};
RegsitrationPoint.topLeft = "top left";
RegsitrationPoint.topCenter = "top center";
RegsitrationPoint.topRight = "top right";
RegsitrationPoint.centerLeft = "center left";
RegsitrationPoint.center = "center";
RegsitrationPoint.centerRight = "center right";
RegsitrationPoint.bottomLeft = "bottom left";
RegsitrationPoint.bottomCenter = "bottom center";
RegsitrationPoint.bottomRight = "bottom right";

Array.prototype.pushMultiple = function(add) {
	for (var i = 0; i < add.length; i++) this.push(add[i]);
};

Array.prototype.contains = function(e) {
	return this.indexOf(e) > -1;
};

Array.prototype.distinct = function(e) {
	var distinct = [];
	for (var i = 0; i < this.length; i++)
		if (!distinct.contains(this[i]))
			distinct.push(this[i]);
	return distinct;
};

function randomString(length, chars) {
	if (length == undefined) length = 16;
	if (chars == undefined) chars = "0123456789abcdefghijklmnopqrstuvwxyz";
	var result = '';
	for (var i = length; i > 0; i--) result += chars[Math.floor(Math.random() * chars.length)];
	return result;
}

function createDialogXML(xmlString, name, buttons) {
	var path = Path.join(tempDir, randomString() + ".xml");
	xmlString = '<dialog title="'+name+'" buttons="'+buttons.join(", ")+'" ><vbox>'+xmlString+'</vbox></dialog>';
	Path.write(path, xmlString);
	var xmlPanelOutput = fl.getDocumentDOM().xmlPanel(Path.uri(path));
	Path.remove(path);
	return xmlPanelOutput;
}

function trace(/* things */) {
	var parts = [];
	for (var i = 0, l = arguments.length; i < l; i++) {
		parts.push(String(arguments[i]));
	}
	fl.trace(parts.join(" "));
}

function applyMatrix(e, matrix) {
	var tp = new Point(e.getTransformationPoint());
	e.matrix = new Matrix(e.matrix).concat(matrix);
	e.setTransformationPoint(matrix.transformPoint(tp));
}

function applyMatrixToContainer(e, matrix, ignoreTranslation) {

	var pt = new Point(matrix.tx, matrix.ty);
	matrix = matrix.invert();
	if (ignoreTranslation) {
		matrix.tx = matrix.ty = 0;
	}

	applyMatrix(e, matrix);

	if (ignoreTranslation) {
		e.x = pt.x;
		e.y = pt.y;
	}

	getChildElements(e).forEach(function (e) {
		applyMatrix(e,matrix.invert());
	});
}

function applyMatrixToShapes(e, matrix) {
	processed = [];
	function recurse(e,m) {
		getChildElements(e).forEach(function(e) {
			if (e.libraryItem) {
				if (processed.contains(e.libraryItem)) return;
				processed.push(e.libraryItem);
			}
			if (e.elementType == ElementType.shape || e.elementType == ElementType.shapeObj) {
				applyMatrix(e, m.invert());
			}
			recurse(e, m);
		});
	}

	applyMatrix(e, matrix);
}

function getChildElements(e, recursive) {
	if (recursive == undefined) recursive = false;
	var children = [];
	if (e.elementType == ElementType.instance) {
		iterateTimelineElements(e.libraryItem.timeline, function(layer, frame, element) {
			children.push(element);
			if (recursive) {
				children.pushMultiple(getChildElements(element, true));
			}
		});
	}
	return children;
}

/**
 * @param timeline {Timeline}
 * @param cb {function(Layer, Frame, Element)}
 */
function iterateTimelineElements(timeline, cb) {
	timeline.layers.forEach(function(layer){
		layer.frames.forEach(function(frame, f){
			if (f == frame.startFrame) {
				frame.elements.forEach(function(element) {
					cb(layer, frame, element);
				});
			}
		});
	});
}

function resetRegistrationPoint(e) {
	if (e.elementType != ElementType.instance) {
		trace(e+" is not an instance. Cannot reset registration point");
		return;
	}
	var matrix = new Matrix(e.matrix);
	var pt = matrix.invert().deltaTransformPoint(new Point(e.x, e.y));
	getChildElements(e).forEach(function(e) {
		e.x += pt.x;
		e.y += pt.y;
	});
	e.x = e.y = 0;
}

function openExplorerAt(path) {
	var command = "explorer \""+Path.platform(path)+"\"";
	FLfile.runCommandLine(command);
}

function loadJson(path){
	try {
		return JSON.decode(Path.read(path));
	} catch (e) {
		trace("Could not load "+path);
		return null;
	}
}

/**
 * @param opts {object}
 * @param opts.bitmap_scale {number}
 * @param opts.bitmap_smoothing {boolean}
 * @param opts.skip_unused {boolean}
 */
function publishDocument(opts) {
	var doc = fl.getDocumentDOM();
	var origDir = Path.dirname(doc.path);

	if (opts == undefined) {
		settingsPath = Path.join(origDir, Path.basenameWithoutExt(doc.path)+".publish_settings.json");
		if (Path.exists(settingsPath)) opts = loadJson(settingsPath);
		if (opts == undefined) opts = {};
	}

	var tempPath = Path.join(tempDir, randomString()+".fla");
	doc.saveAsCopy(Path.uri(tempPath));
	doc = fl.openDocument(Path.uri(tempPath));
	Path.remove(tempPath);

	var profileXML = new XML(doc.exportPublishProfileString(doc.currentPublishProfile));
	var flashFileName = profileXML.PublishFormatProperties.flashFileName;
	flashFileName = Path.normalize(Path.join(origDir, flashFileName));
	profileXML.PublishFormatProperties.flashFileName = flashFileName;
	doc.importPublishProfileString(profileXML.toString());

	var processed = [];
	doc.library.items.forEach(function(item) {
		if (opts.skip_unused && doc.library.unusedItems.contains(item)) return;
		if (!item.timeline) return;

		iterateTimelineElements(item.timeline, function(layer, frame, element) {
			if (element.elementType == ElementType.instance && element.instanceType == InstanceType.symbol && element.bitmapRenderMode == BitmapRenderMode.export) {
				element.bitmapRenderMode = BitmapRenderMode.none;
				if (!processed.contains(element.libraryItem)) {
					processed.push(element.libraryItem);
					convertContentsIntoBitmap(element.libraryItem);
				}
			}
		});
	});

	doc.publish();

	//doc.save(false);

	doc.close(false);

	//fl.publishDocument(Path.uri(tempPath));
	//openExplorerAt(tempDir);

	/*doc.library.items.forEach(function(item) {
	 if (!item.timeline) return;
	 if (item.itemType == ItemType.bitmap) {
	 item.allowSmoothing = false;
	 }
	 });*/

	function convertContentsIntoBitmap(item) {
		doc.library.editItem(item.name);
		doc.selectAll();

		var symbol = null;
		if (opts.bitmap_scale != undefined) {
			symbol = doc.convertToSymbol(SymbolType.movieClip, randomString(), RegsitrationPoint.center);
			resetRegistrationPoint(doc.selection[0]);
			doc.selection[0].scaleX = doc.selection[0].scaleY = opts.bitmap_scale;
		}

		doc.convertSelectionToBitmap();

		if (opts.bitmap_scale != undefined) {
			doc.selection[0].setTransformationPoint(new Point(-doc.selection[0].x, -doc.selection[0].y));
			doc.selection[0].scaleX = doc.selection[0].scaleY = 1 / opts.bitmap_scale;
		}

		if (symbol) {
			doc.library.deleteItem(symbol.name);
		}

		doc.selection[0].libraryItem.allowSmoothing = opts.smoothing;
	}
}