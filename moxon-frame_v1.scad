// simple moxon antenna frame generator
// based on this idea: https://www.thingiverse.com/thing:2068392

// values come from https://www.antenna2.net/cebik/content/moxon/moxpage.html
// or any other online calculator
// current values (all in mm, btw :) are for 433 MHz

// license: CC-BY-NC-SA


A = 249.33;
B = 33.8;
C = 10.84;
D = 47.73;
E = 92.37;

dia = 1.05;					// wire diameter (+ some tolerance for printing, maybe)

frame = 7;					// frame width

thickness = (dia < 1.5)? 1.5: 1;
							// base plate thickness

wire_radius_outer = 2;		// rounding radius for the wire cutout rectangles
wire_radius_inner = 2;		// 2mm for 1mm copper wires, >=3 for 1.5

handle_length = 60;

connector = "sma";			// "sma" (2-hole sma jack), "bnc" (4-hole jack), "screw" or none
screw_dia = 4.4;

freq = "433";				// only used for text generation
tsize = 7;
font = "Core Sans D 55 Bold";


$fn = 255;



difference() {
	union() {
		// outer rectangle (or roundtangle :)
		rcube([A + frame, E + frame, dia + thickness], 3, true, false);
		// handle
		translate(v = [0, -(E/2) - frame - handle_length/2 + 10, 0])
			rcube([21, handle_length+10, dia + thickness], 6.5, true, false);
	}

	// wire cutout
	translate(v = [0, 0, thickness])
		difference() {
			rcube([(A + dia), (E + dia), dia], wire_radius_outer, true, false);
			rcube([(A - dia), (E - dia), dia], wire_radius_inner, true, false);
			// left wire endstop
			translate(v = [-(A/2 + dia/2), E/2 - B - C, 0])
				cube(size=[dia, C, thickness + dia]);
			// right wire endstop
			translate(v = [(A/2 - dia/2), E/2 - B - C, 0])
				cube(size=[dia, C, thickness + dia]);
		}

	// left wing cutout
	translate(v = [-((A/2 + frame)/2), 0, 0])
		rcube([(A/2 - frame*2), E - frame, thickness + dia], 2.5, true, false);

	// right wing cutout
	translate(v = [(A/2 + frame)/2, 0, 0])
		rcube([(A/2 - frame*2), E - frame, thickness + dia], 2.5, true, false);

	// big notch
	translate(v = [0, E/2, 0])
		rcube([10, 20, thickness + dia], 3, true, false);

	// smaller notch
	translate(v = [0, E/2, 0])
		rcube([5, 40, thickness + dia], 1.5, true, false);

	// holes for cable ties
	if (E>80) {
		cable_ties(4);
		translate(v = [0, -20, 0])
			cable_ties(4);
	}
	else if (E>40) {
		translate(v = [0, -7, 0])
			cable_ties(4);
	}
	if (handle_length > 30) {
		translate(v = [0, -(E/2) - 15, 0])
			cable_ties(4);
	}

	// holes for mounting a connector
	translate(v = [0, -(E/2) - frame - handle_length + 15, 0])
		connectors();

	// text
	translate(v = [0, -(E/2 - 5), thickness + dia - 0.6])
		linear_extrude(0.6)
			text(freq, size=tsize, font=font, halign = "center");
}


// modules

module cable_ties(spacing) {

	translate(v = [-spacing, 0, 0])
		rcube([1.5, 5, thickness + dia], 0.5, true, false);
	translate(v = [spacing, 0, 0])
		rcube([1.5, 5, thickness + dia], 0.5, true, false);
}

module connectors() {

	if (connector=="sma") {
		// holes for SMA jack
		cylinder(h=(dia + thickness), r=4.5/2);
		translate(v = [6, 0, 0])
			cylinder(h=(dia + thickness), r=3/2);
		translate(v = [-6, 0, 0])
			cylinder(h=(dia + thickness), r=3/2);
	}
	else if (connector=="bnc") {
		// holes for BNC jack
		translate(v = [0, 1, 0])   // 2do placement
			cylinder(h=(dia + thickness), r=11/2);
		translate(v = [6, 7, 0])
			cylinder(h=(dia + thickness), r=3/2);
		translate(v = [-6, 7, 0])
			cylinder(h=(dia + thickness), r=3/2);
		translate(v = [6, -5, 0])
			cylinder(h=(dia + thickness), r=3/2);
		translate(v = [-6, -5, 0])
			cylinder(h=(dia + thickness), r=3/2);
	}
	else if (connector=="screw") {
		// just a screw hole
		cylinder(h=(dia + thickness), r=screw_dia/2);
	}
}


// adapted from https://github.com/nophead/NopSCADlib

module rcube(size, r = 0, xy_center = false, z_center = false) {
	linear_extrude(size.z, center = z_center, convexity = 5)
		offset(r) offset(-r) square([size.x, size.y], center = true);
}