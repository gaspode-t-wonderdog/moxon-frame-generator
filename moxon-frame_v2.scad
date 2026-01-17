// simple moxon antenna frame generator
// based on this idea: https://www.thingiverse.com/thing:2068392

// values come from https://www.antenna2.net/cebik/content/moxon/moxpage.html
// or any other online calculator
// current values (all in mm, btw :) are for 433 MHz

// license: CC-BY-NC-SA


A = 226.54;				// those values are calculated for 433 MHz with
B = 30.51;				// a correction factor of 1.1 (476.3 Mhz)
C = 10.05;
D = 43.42;
E = 83.98;

dia = 1.0;				// wire diameter (+ some tolerance for 3D-printing, +- 0.05 maybe)

frame = 7;				// frame width
thickness = 2.5;			// frame thickness
corner_radius = 3;
wire_depth = dia/3;			// where the wire channel gets placed

handle_width = 21;
handle_length = 60;

connector = "bnc";			// "sma" (2-hole sma jack), "bnc" (4-hole jack), sma2/bnc2 (no mounting holes), "screw" or none
screw_dia = 4.4;

freq = "433";				// only used for text generation for now
tsize = 7;
font = "Liberation Sans:style=Bold";


$fn = 255;


difference() {
	union() {
		// base shape
		linear_extrude(thickness)
			fillet_o(3) fillet_i(1.5)
				base();

		// text
		translate(v = [0, -(E/2 - 5), thickness])
			linear_extrude(0.5)
				text(freq, size=tsize, font=font, halign = "center");
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
	translate(v = [0, -E/2 - frame - handle_length + 14, 0])
		connectors();
}


// modules

module base() {
	difference() {
		// outer roundtangle
		square([A + frame, E + frame], center=true);
		// cutout
		square([(A - frame), E - frame], center=true);
	}

	// handle
	translate(v = [0, -handle_length/2, 0])
		fillet_o(6)
			square([handle_width, E + handle_length + frame], center=true);
}

module cable_ties(spacing) {
	translate(v = [-spacing, 0, 0])
		rcube([1.5, 5, thickness], 0.5, true, false);
	translate(v = [spacing, 0, 0])
		rcube([1.5, 5, thickness], 0.5, true, false);
}

module connectors() {
	if (connector=="sma") {
		// 2-hole SMA jack
		cylinder(h=(thickness), r=4.5/2);
		translate(v = [6, 0, 0])
			cylinder(h=(thickness), r=3/2);
		translate(v = [-6, 0, 0])
			cylinder(h=(thickness), r=3/2);
	}
	if (connector=="sma2") {
		// holes for another SMA jack with recessed hex nut
		cylinder(h=(thickness), r=6.5/2);
		translate(v = [0, 0, 1])
			cylinder(h=(thickness), r=9.5/2, $fn=6);
	}
	else if (connector=="bnc") {
		// 4-hole BNC jack
		translate(v = [0, 1, 0]) {
			translate(v = [0, 0, 0])
				cylinder(h=(thickness), r=11/2);
			translate(v = [6.35, 6.35, 0])
				cylinder(h=(thickness), r=3.3/2);
			translate(v = [-6.35, 6.35, 0])
				cylinder(h=(thickness), r=3.3/2);
			translate(v = [6.35, -6.35, 0])
				cylinder(h=(thickness), r=3.3/2);
			translate(v = [-6.35, -6.35, 0])
				cylinder(h=(thickness), r=3.3/2);
		}
	}
	else if (connector=="bnc2") {
		// another BNC jack (without mounting holes)
		difference() {
			cylinder(h=(thickness), r=9.2/2);
			translate(v = [0, 5.1, 0])
				cube([10, 2, thickness*2], center=true);
			translate(v = [0, -5.1, 0])
				cube([10, 2, thickness*2], center=true);
		}
	}
	else if (connector=="screw") {
		// just a screw hole
		cylinder(h=(thickness), r=screw_dia/2);
	}
}

module fillet_o(r) {
	offset(r) offset(-r) children();
}

module fillet_i(r) {
	offset(r = -r) offset(delta = r) children();
}

// adapted from https://github.com/nophead/NopSCADlib

module rcube(size, r = 0, xy_center = false, z_center = false) {
	linear_extrude(size.z, center = z_center, convexity = 5)
		offset(r) offset(-r) square([size.x, size.y], center = xy_center);
}
