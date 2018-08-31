Path = function() {};

Path.join = function(/* path segments */) {
	var allParts = [];
	for (var i = 0; i < arguments.length; i++) {
		var parts = arguments[i].split(/[\/\\]+/g);
		for (var j = 0; j < parts.length; j++) {
			if (parts[j] != "") allParts.push(parts[j]);
		}
	}
	return allParts.join("/");
};

Path.dirname = function(path) {
	return Path.normalize(path).split("/").slice(0, -1).join("/");
};

Path.basename = function(path) {
	return Path.normalize(path).split("/").pop();
};

Path.basenameWithoutExt = function(path) {
	return Path.basename(path).split(".").slice(0,-1).join(".");
};

Path.normalize = function(p) {
	if (Path.isURI(p)) p = FLfile.uriToPlatformPath(p);
	parts = p.split(/[\/\\]+/g);
	var newParts = [];
	for (var i = 0; i < parts.length; i++) {
		if (i != 0 && parts[i] == ".") {
			continue;
		} else if (parts[i] == "..") {
			newParts.pop();
		} else {
			newParts.push(parts[i]);
		}
	}
	return newParts.join("/");
};

Path.removeTrailingSeparator = function(str) {
	return str.replace(/[\/\\]+$/g, "");
};

Path.uri = function(p) {
	return !Path.isURI(p) ? FLfile.platformPathToURI(p) : p;
};

Path.platform = function(p) {
	if (Path.isURI(p)) return FLfile.uriToPlatformPath(p);
	else return p.replace(/\/+/g, "\\");
};

Path.isURI = function(p) {
	return p.substring(0,8).toLowerCase() == "file:///";
};

Path.assertDir = function(path) {
	var uri = Path.uri(path);
	if (!Path.exists(path)) return Path.createDir(uri);
	return true;
};

Path.createDir = function(path) {
	var uri = Path.uri(path);
	return FLfile.createFolder(uri);
};

Path.exists = function(path) {
	return FLfile.exists(Path.uri(path));
};

Path.write = function(path, text, appendMode) {
	return FLfile.write(Path.uri(path), text, appendMode);
};

Path.read = function(path) {
	return FLfile.read(Path.uri(path));
};

Path.remove = function(path) {
	return FLfile.remove(Path.uri(path));
};

Path.listDir = function(path) {
	return FLfile.listFolder(Path.uri(path));
};