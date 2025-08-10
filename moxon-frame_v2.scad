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

dia = 1.1;					// wire diameter (+ some tolerance for 3D-printing, .1 maybe)

frame = 7;					// frame width
thickness = 2.5;			// frame thickness
corner_radius = 3;
wire_depth = dia/3;			// where the wire channel gets placed

handle_length = 60;

connector = "bnc";			// "sma" (2-hole sma jack), "bnc" (4-hole jack), "screw" or none
screw_dia = 4.4;

freq = "433";				// only used for text generation
tsize = 7;
font = "Core Sans D 55 Bold";


$fn = 255;


difference() {
	union() {
		// outer roundtangle
		rcube([A + frame, E + frame, thickness], 3, true, false);
		// handle
		translate(v = [0, -E/2 - frame - handle_length/2 + 10, 0])
			rcube([21, handle_length + 10, thickness], 6.5, true, false);
	}

	// wire channels
	translate(v = [-A/2, E/2 - corner_radius, thickness-wire_depth])
		rotate([90, 0, 0])  linear_extrude(E - corner_radius*2) circle(dia/2);
	translate(v = [A/2, E/2 - corner_radius, thickness-wire_depth])
		rotate([90, 0, 0])  linear_extrude(E - corner_radius*2) circle(dia/2);
	translate(v = [-A/2 + corner_radius, E/2, thickness-wire_depth])
		rotate([0, 90, 0]) linear_extrude(A - corner_radius*2) circle(dia/2);
	translate(v = [-A/2 + corner_radius, -E/2, thickness-wire_depth])
		rotate([0, 90, 0]) linear_extrude(A - corner_radius*2) circle(dia/2);

	// wire channel rounded corners
	translate(v = [-A/2 + corner_radius, E/2 - corner_radius, thickness-wire_depth])
		rotate([0, 0, 90]) rotate_extrude(angle=90) translate ([corner_radius,0,0]) circle(dia/2);
	translate(v = [A/2 - corner_radius, E/2 - corner_radius, thickness-wire_depth])
		rotate_extrude(angle=90) translate ([corner_radius,0,0]) circle(dia/2);
	translate(v = [-A/2 + corner_radius, -E/2 + corner_radius, thickness-wire_depth])
		rotate([0, 0, 180]) rotate_extrude(angle=90) translate ([corner_radius,0,0]) circle(dia/2);
	translate(v = [A/2 - corner_radius, -E/2 + corner_radius, thickness-wire_depth])
		rotate([0, 0, 270]) rotate_extrude(angle=90) translate ([corner_radius,0,0]) circle(dia/2);

	// left wire endstop
	translate(v = [-(A/2 + dia/2 + 1), E/2 - B - C, 0])
		cube(size=[dia + 2, C, thickness]);
	// right wire endstop
	translate(v = [(A/2 - dia/2 - 1), E/2 - B - C, 0])
		cube(size=[dia + 2, C, thickness]);

	// left wing cutout
	translate(v = [-((A/2 + frame)/2), 0, 0])
		rcube([(A/2 - frame*2), E - frame, thickness], 2.5, true, false);

	// right wing cutout
	translate(v = [(A/2 + frame)/2, 0, 0])
		rcube([(A/2 - frame*2), E - frame, thickness], 2.5, true, false);

	// big notch
	translate(v = [0, E/2, 0])
		rcube([10, 20, thickness], 3, true, false);

	// smaller notch
	translate(v = [0, E/2, 0])
		rcube([5, 40, thickness], 1.5, true, false);

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
	translate(v = [0, -E/2 - frame - handle_length + 15, 0])
		connectors();

	// text
	translate(v = [0, -(E/2 - 5), thickness - 0.6])
		linear_extrude(0.6)
			text(freq, size=tsize, font=font, halign = "center");
}


// modules

module cable_ties(spacing) {
	translate(v = [-spacing, 0, 0])
		rcube([1.5, 5, thickness], 0.5, true, false);
	translate(v = [spacing, 0, 0])
		rcube([1.5, 5, thickness], 0.5, true, false);
}

module connectors() {
	if (connector=="sma") {
		// holes for SMA jack
		cylinder(h=(dia + thickness), r=4.5/2);
		translate(v = [6, 0, 0])
			cylinder(h=(thickness), r=3/2);
		translate(v = [-6, 0, 0])
			cylinder(h=(thickness), r=3/2);
	}
	else if (connector=="bnc") {
		// holes for BNC jack
		translate(v = [0, 1, 0])   // 2do placement
			cylinder(h=(thickness), r=11/2);
		translate(v = [6, 7, 0])
			cylinder(h=(thickness), r=3/2);
		translate(v = [-6, 7, 0])
			cylinder(h=(thickness), r=3/2);
		translate(v = [6, -5, 0])
			cylinder(h=(thickness), r=3/2);
		translate(v = [-6, -5, 0])
			cylinder(h=(thickness), r=3/2);
	}
	else if (connector=="screw") {
		// just a screw hole
		cylinder(h=(thickness), r=screw_dia/2);
	}
}


// adapted from https://github.com/nophead/NopSCADlib

module rcube(size, r = 0, xy_center = false, z_center = false) {
	linear_extrude(size.z, center = z_center, convexity = 5)
		offset(r) offset(-r) square([size.x, size.y], center = xy_center);
}
