Matrix = function() {
	if (arguments.length == 0) {
		this.setTo(1,0,0,1,0,0);
	} else if (arguments.length == 1 && typeof(arguments[0]) == "object") {
		this.setTo(arguments[0].a, arguments[0].b, arguments[0].c, arguments[0].d, arguments[0].tx, arguments[0].ty);
	} else if (arguments.length == 6) {
		this.setTo(arguments[0], arguments[1], arguments[2], arguments[3], arguments[4], arguments[5]);
	} else {
		throw new Error();
	}
};

Matrix.prototype.scale = function(sx,sy) {
	this.a *= sx;
	this.b *= sy;
	this.c *= sx;
	this.d *= sy;
	this.tx *= sx;
	this.ty *= sy;
	return this;
};

Matrix.prototype.identity = function() {
	return this.setTo(1,0,0,1,0,0);
};

Matrix.prototype.translate = function(dx,dy) {
	this.tx += dx;
	this.ty += dy;
	return this;
};

Matrix.prototype.concat = function(m) {
	return new Matrix(fl.Math.concatMatrix(this, m));
};

Matrix.prototype.invert = function() {
	return new Matrix(fl.Math.invertMatrix(this));
};

Matrix.prototype.transformPoint = function(pt) {
	return new Point(fl.Math.transformPoint(this, pt));
};

Matrix.prototype.deltaTransformPoint = function(pt) {
	return new Point(pt.x * this.a + pt.y * this.c, pt.x * this.b + pt.y * this.d);
};

Matrix.prototype.copyFrom = function(m) {
	return this.setTo(m.a, m.b, m.c, m.d, m.tx, m.ty);
};

Matrix.prototype.setTo = function(a, b, c, d, tx, ty) {
	this.a = a;
	this.b = b;
	this.c = c;
	this.d = d;
	this.tx = tx;
	this.ty = ty;
	return this;
};

Matrix.prototype.toString = function() {
	return "{ a = " + this.a+", "+"b = " + this.b+", "+"c = " + this.c+", "+"d = " + this.d+", "+"tx = " + this.tx+", "+"ty = " + this.ty+" }";
};

Matrix.prototype.clone = function() {
	return new Matrix(this);
};

Point = function() {
	if (arguments.length == 0){
		this.x = this.y = 0;
	} else if (arguments.length == 1 && typeof(arguments[0]) == "object") {
		this.x = arguments[0].x;
		this.y = arguments[0].y;
	} else if (arguments.length == 2) {
		this.x = arguments[0];
		this.y = arguments[1];
	} else {
		throw new Error();
	}
};

Point.prototype.toString = function() {
	return "{ x = " + this.x+", "+"y = " + this.y+" }";
};

Point.prototype.clone = function() {
	return new Point(this);
};
