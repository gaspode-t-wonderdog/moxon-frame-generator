// "Self-calculating Moxon antenna frame generator"
// Original idea: https://www.thingiverse.com/thing:2068392
// Based on empirical formulas by L.B. Cebik (W4RNL)
// https://www.antenna2.net/cebik/books/Moxon-Rectangle-Notes.pdf
// 2025 DO2THX (tom@jitter.eu)
// License: CC-BY-NC-SA

// ===== USER ADJUSTABLE PARAMETERS =====

// === BASIC ANTENNA DESIGN ===
// Design frequency in MHz
freq_mhz = 433;
// Wire diameter in mm
wire_dia_mm = 1.0;

// === MATERIAL PROPERTIES ===
correction_factor = 1.1;

// === FRAME CONSTRUCTION ===
// Frame wall thickness (mm)
frame_width = 7.0;
// Frame height/thickness (mm)
frame_thickness = 2.5;
// Corner rounding radius (mm)
corner_radius = 3.0;

// === WIRE CHANNEL ===
// Wire clearance tolerance (mm) for 3D-printing
wire_tolerance = 0;
// Channel depth as fraction of wire diameter
wire_depth_ratio = 0.33;

// === HANDLE & MOUNTING ===
// Handle length (mm) - set to 0 to disable
handle_length = 60;
// Handle width (mm)
handle_width = 21;

// === CONNECTOR ===
// RF connector type (see README)
connector = "bnc"; // ["none", "sma", "sma2", "bnc", "bnc2", "screw"]
// Screw diameter (mm) - for screw connector type
screw_dia = 4.4;

// === APPEARANCE ===
// Frequency label text size (mm)
text_size = 7;
// Text font
text_font = "Liberation Sans:style=Bold";
// Show frequency label on handle
show_frequency_text = true;

// === RENDERING QUALITY ===
// Circle resolution - higher values = smoother curves but slower rendering
$fn = 64;

// ===== DERIVED PARAMETERS (DO NOT EDIT) =====

function moxon_calculate_dimensions(f_mhz, dia_mm) = 
	let(
		// Calculate wavelength in mm
		c = 299792458,              // Speed of light in m/s
		wavelength_mm = (c / (f_mhz * 1000000)) * 1000,

		// Convert wire diameter to wavelengths
		dia_wavelengths = dia_mm / wavelength_mm,

		// Validate wire diameter range (1E-5 to 1E-2 wavelengths)
		dia_wl_min = 1e-5,
		dia_wl_max = 1e-2,
		dia_valid = (dia_wavelengths >= dia_wl_min && dia_wavelengths <= dia_wl_max),

		// Use log10 of diameter in wavelengths
		log_dia = log(dia_wavelengths) / log(10),  // Convert to common log (base 10)

		// Cebik's empirical coefficients for 50-ohm Moxon
		// A dimension coefficients
		AA = -0.0008571428571,
		AB = -0.009571428571,
		AC = 0.3398571429,

		// B dimension coefficients
		BA = -0.002142857143,
		BB = -0.02035714286,
		BC = 0.008285714286,

		// C dimension coefficients
		CA = 0.001809523381,
		CB = 0.01780952381,
		CC = 0.05164285714,

		// D dimension coefficients
		DA = 0.001,
		DB = 0.07178571429,

		// Calculate dimensions in wavelengths using Cebik's formulas
		A_wl = (AA * pow(log_dia, 2)) + (AB * log_dia) + AC,
		B_wl = (BA * pow(log_dia, 2)) + (BB * log_dia) + BC,
		C_wl = (CA * pow(log_dia, 2)) + (CB * log_dia) + CC,
		D_wl = (DA * log_dia) + DB,
		E_wl = B_wl + C_wl + D_wl,

		// Convert to millimeters
		A_mm = A_wl * wavelength_mm,
		B_mm = B_wl * wavelength_mm,
		C_mm = C_wl * wavelength_mm,
		D_mm = D_wl * wavelength_mm,
		E_mm = E_wl * wavelength_mm,

		// Calculate some useful metrics
		boom_length_wl = E_wl,
		total_wire_length_mm = 2 * (A_mm + E_mm - 2 * C_mm),  // Approximate wire length
		compactness = A_wl / 0.5  // Compared to half-wave dipole
	)
	[A_mm, B_mm, C_mm, D_mm, E_mm, wavelength_mm, dia_valid, boom_length_wl, total_wire_length_mm, compactness];

// Calculate the actual dimensions
calc_result = moxon_calculate_dimensions(freq_mhz * correction_factor, wire_dia_mm);
A = calc_result[0];
B = calc_result[1];
C = calc_result[2];
D = calc_result[3];
E = calc_result[4];

wavelength = calc_result[5];
diameter_valid = calc_result[6];
boom_length_wavelengths = calc_result[7];
wire_length_mm = calc_result[8];
compactness_factor = calc_result[9];

// Wire channel parameters
wire_channel_dia = wire_dia_mm + wire_tolerance;	// Add tolerance for 3D printing
wire_depth = wire_dia_mm * wire_depth_ratio;

// Verbose output
echo(str("=== MOXON CALCULATOR RESULTS ==="));
echo(str("Design frequency: ", freq_mhz, " MHz"));
echo(str("Wire diameter: ", wire_dia_mm, " mm (", round(wire_dia_mm/wavelength * 1000000)/1000000, " λ)"));
echo(str(""));
echo(str("Calculated dimensions:"));
echo(str("A (width): ", round(A*100)/100, " mm (", round(A/wavelength*1000)/1000, " λ)"));
echo(str("B (driver tail): ", round(B*100)/100, " mm"));
echo(str("C (gap): ", round(C*100)/100, " mm")); 
echo(str("D (reflector tail): ", round(D*100)/100, " mm"));
echo(str("E (height): ", round(E*100)/100, " mm (", round(E/wavelength*1000)/1000, " λ)"));
echo(str(""));
echo(str("Additional info:"));
echo(str("Wavelength: ", round(wavelength*100)/100, " mm"));
echo(str("Estimated wire length: ", round(wire_length_mm), " mm"));
echo(str("Compactness: ", round(compactness_factor*100), "% of dipole width"));
echo(str("Wire diameter valid: ", diameter_valid ? "✓" : "⚠ Outside 1E-5 to 1E-2 λ range"));

// Validation warnings
if (!diameter_valid) {
	echo(str("⚠ WARNING: Wire diameter outside validated range!"));
	echo(str("   Formulas valid for diameters 1E-5 to 1E-2 wavelengths"));
	echo(str("   Current: ", round(wire_dia_mm/wavelength * 1000000)/1000000, " λ"));
}

// ===== 3D MODEL GENERATION =====

difference() {
	union() {
		// base shape
		linear_extrude(frame_thickness)
			fillet_o(3) fillet_i(1.5)
				base();

		// Frequency text on handle near connector
		if (show_frequency_text) {
			translate([0, -(E/2 - 5), frame_thickness])
				linear_extrude(0.5) {
					text(str(freq_mhz), size=text_size, font=text_font, halign = "center");
				}
		}
	}

	// Wire channels - vertical sides
	translate([-A/2, E/2 - corner_radius, frame_thickness-wire_depth])
		rotate([90, 0, 0]) linear_extrude(E - corner_radius*2) circle(wire_channel_dia/2);
	translate([A/2, E/2 - corner_radius, frame_thickness-wire_depth])
		rotate([90, 0, 0]) linear_extrude(E - corner_radius*2) circle(wire_channel_dia/2);

	// Wire channels - horizontal sides
	translate([-A/2 + corner_radius, E/2, frame_thickness-wire_depth])
		rotate([0, 90, 0]) linear_extrude(A - corner_radius*2) circle(wire_channel_dia/2);
	translate([-A/2 + corner_radius, -E/2, frame_thickness-wire_depth])
		rotate([0, 90, 0]) linear_extrude(A - corner_radius*2) circle(wire_channel_dia/2);

	// Wire channel rounded corners
	translate([-A/2 + corner_radius, E/2 - corner_radius, frame_thickness-wire_depth])
		rotate([0, 0, 90]) rotate_extrude(angle=90) translate ([corner_radius,0,0]) circle(wire_channel_dia/2);
	translate([A/2 - corner_radius, E/2 - corner_radius, frame_thickness-wire_depth])
		rotate_extrude(angle=90) translate ([corner_radius,0,0]) circle(wire_channel_dia/2);
	translate([-A/2 + corner_radius, -E/2 + corner_radius, frame_thickness-wire_depth])
		rotate([0, 0, 180]) rotate_extrude(angle=90) translate ([corner_radius,0,0]) circle(wire_channel_dia/2);
	translate([A/2 - corner_radius, -E/2 + corner_radius, frame_thickness-wire_depth])
		rotate([0, 0, 270]) rotate_extrude(angle=90) translate ([corner_radius,0,0]) circle(wire_channel_dia/2);

	// left wire endstop
	translate([-(A/2 +  wire_channel_dia/2 + 1), E/2 - B - C, 0])
		cube(size=[ wire_channel_dia + 2, C, frame_thickness]);
	// right wire endstop
	translate([(A/2 -  wire_channel_dia/2 - 1), E/2 - B - C, 0])
		cube(size=[wire_channel_dia + 2, C, frame_thickness]);

	// Big notch for wire insertion
	translate([0, E/2+frame_width/2, 0])
		rcube([10, 20+frame_width, frame_thickness], 3, true, false);

	// Smaller notch for wire routing
	translate([0, E/2, 0])
		rcube([5, 40, frame_thickness], 1.5, true, false);

	// Holes for cable ties (scaled with antenna size)
	if (E > 80) {
		cable_ties(4);
		translate([0, -20, 0])
			cable_ties(4);
	}
	else if (E > 40) {
		translate([0, -7, 0])
			cable_ties(4);
	}
	if (handle_length > 30) {
		translate([0, -(E/2) - 15, 0])
			cable_ties(4);
	}

	// Holes for mounting a connector
	if (handle_length > 0) {
		translate([0, -E/2 - frame_width - handle_length + 14, 0])
			connectors();
	}
}

module base() {
	difference() {
		// outer roundtangle
		square([A + frame_width, E + frame_width], center=true);
		// cutout
		square([(A - frame_width), E - frame_width], center=true);
	}

	// handle
	translate([0, -handle_length/2, 0])
		fillet_o(6)
			square([handle_width, E + handle_length + frame_width], center=true);
}

module cable_ties(spacing) {
	translate([-spacing, 0, 0])
		rcube([1.5, 5, frame_thickness], 0.5, true, false);
	translate([spacing, 0, 0])
		rcube([1.5, 5, frame_thickness], 0.5, true, false);
}

module connectors() {
	if (connector=="sma") {
		// 2-hole SMA jack
		cylinder(h=(frame_thickness), r=4.5/2);
		translate([6, 0, 0])
			cylinder(h=(frame_thickness), r=3/2);
		translate([-6, 0, 0])
			cylinder(h=(frame_thickness), r=3/2);
	}
	if (connector=="sma2") {
		// holes for another SMA jack with recessed hex nut
		cylinder(h=(frame_thickness), r=6.5/2);
		translate([0, 0, 1])
			cylinder(h=(frame_thickness), r=9.5/2, $fn=6);
	}
	else if (connector=="bnc") {
		// 4-hole BNC jack
		translate([0, 1, 0]) {
			translate([0, 0, 0])
				cylinder(h=(frame_thickness), r=11/2);
			translate([6.35, 6.35, 0])
				cylinder(h=(frame_thickness), r=3.3/2);
			translate([-6.35, 6.35, 0])
				cylinder(h=(frame_thickness), r=3.3/2);
			translate([6.35, -6.35, 0])
				cylinder(h=(frame_thickness), r=3.3/2);
			translate([-6.35, -6.35, 0])
				cylinder(h=(frame_thickness), r=3.3/2);
		}
	}
	else if (connector=="bnc2") {
		// another BNC jack (without mounting holes)
		difference() {
			cylinder(h=(frame_thickness), r=9.2/2);
			translate([0, 5.1, 0])
				cube([10, 2, frame_thickness*2], center=true);
			translate([0, -5.1, 0])
				cube([10, 2, frame_thickness*2], center=true);
		}
	}
	else if (connector=="screw") {
		// just a screw hole
		cylinder(h=(frame_thickness), r=screw_dia/2);
	}
}

module fillet_o(r) {
	offset(r) offset(-r) children();
}

module fillet_i(r) {
	offset(r = -r) offset(delta = r) children();
}

// Rounded cube function (adapted from NopSCADlib)
module rcube(size, r = 0, xy_center = false, z_center = false) {
	linear_extrude(size.z, center = z_center, convexity = 5)
		offset(r) offset(-r) square([size.x, size.y], center = xy_center);
}
