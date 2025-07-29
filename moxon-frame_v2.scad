// "Self-calculating Moxon antenna frame generator"
// Original idea: https://www.thingiverse.com/thing:2068392
// Based on empirical formulas by L.B. Cebik (W4RNL)
// https://www.antenna2.net/cebik/books/Moxon-Rectangle-Notes.pdf
// 2025 DN9TT (tom@jitter.eu)
// License: CC-BY-NC-SA

// ===== USER ADJUSTABLE PARAMETERS =====

// === BASIC ANTENNA DESIGN ===
// Design frequency in MHz
freq_mhz = 433; // [50:1:3000]
// Wire diameter in mm
wire_dia_mm = 1.0; // [0.5:0.1:3.0]

// === MATERIAL PROPERTIES ===
// Wire velocity factor (accounts for insulation): 1.0=bare, 0.95=PTFE, 0.94=PVC, 0.66=PE
wire_velocity_factor = 0.95; // [0.60:0.01:1.00]
// Frame dielectric loading correction: 1.0=air, 1.03=plastic frame
structure_correction = 1.03; // [1.00:0.01:1.10]

// === FRAME CONSTRUCTION ===
// Frame wall thickness (mm)
frame_width = 8.0; // [4:0.5:15]
// Frame height/thickness (mm)
frame_thickness = 3.0; // [1.2:0.1:5.0]
// Corner rounding radius (mm)
corner_radius = 3.0; // [0.5:0.5:8]

// === WIRE CHANNEL ===
// Wire clearance tolerance (mm)
wire_tolerance = 0.1; // [0.05:0.05:0.5]
// Channel depth as fraction of wire diameter
wire_depth_ratio = 0.33; // [0.15:0.01:0.60]

// === HANDLE & MOUNTING ===
// Handle length (mm) - set to 0 to disable
handle_length = 60; // [0:5:120]
// Handle width (mm)
handle_width = 21; // [12:1:35]

// === CONNECTOR ===
// RF connector type
connector = "bnc"; // ["none", "sma", "bnc", "screw"]
// Screw diameter (mm) - for screw connector type
screw_dia = 4.4; // [2.5:0.1:8.0]

// === APPEARANCE ===
// Frequency label text size (mm)
text_size = 6; // [3:0.5:15]
// Text font
text_font = "Liberation Sans:style=Bold";
// Show frequency label on handle
show_frequency_text = true;

// === RENDERING QUALITY ===
// Circle resolution - higher values = smoother curves but slower rendering
$fn = 64; // [12:4:200]

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
calc_result = moxon_calculate_dimensions(freq_mhz, wire_dia_mm);
A_raw = calc_result[0];
B_raw = calc_result[1];
C_raw = calc_result[2];
D_raw = calc_result[3];
E_raw = calc_result[4];

// Apply wire velocity factor correction (for insulated wire)
A_vf = A_raw * wire_velocity_factor;
B_vf = B_raw * wire_velocity_factor;
C_vf = C_raw * wire_velocity_factor;
D_vf = D_raw * wire_velocity_factor;
E_vf = E_raw * wire_velocity_factor;

// Apply structure correction (for plastic frame loading)
A = A_vf * structure_correction;
B = B_vf * structure_correction;
C = C_vf * structure_correction;
D = D_vf * structure_correction;
E = E_vf * structure_correction;
wavelength = calc_result[5];
diameter_valid = calc_result[6];
boom_length_wavelengths = calc_result[7];
wire_length_mm = calc_result[8] * wire_velocity_factor * structure_correction;
compactness_factor = calc_result[9];

// Wire channel parameters
dia = wire_dia_mm + wire_tolerance;    // Add tolerance for 3D printing
wire_depth = dia * wire_depth_ratio;

// Verbose output
echo(str("=== MOXON CALCULATOR RESULTS ==="));
echo(str("Design frequency: ", freq_mhz, " MHz"));
echo(str("Wire diameter: ", wire_dia_mm, " mm (", round(wire_dia_mm/wavelength * 1000000)/1000000, " λ)"));
echo(str("Wire velocity factor: ", wire_velocity_factor, " (", wire_velocity_factor == 1.0 ? "bare wire" : "insulated wire", ")"));
echo(str("Structure correction: ", structure_correction, " (plastic frame dielectric loading)"));
echo(str("   → Combined effect: ", round((wire_velocity_factor * structure_correction - 1)*1000)/10, "% dimension change"));
echo(str("   → Without corrections, antenna would resonate ~", round(freq_mhz/(wire_velocity_factor * structure_correction)), " MHz"));
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

if (wire_velocity_factor < 0.92 || wire_velocity_factor > 1.0) {
    echo(str("⚠ WARNING: Wire velocity factor outside typical range!"));
    echo(str("   Typical values: PVC=0.94-0.96, PTFE=0.95-0.97, PE=0.66, bare=1.0"));
}

if (structure_correction < 1.0 || structure_correction > 1.06) {
    echo(str("⚠ WARNING: Structure correction outside validated range!"));
    echo(str("   Research shows 1.02-1.05 for plastic structures, 1.0 for no frame"));
}

// ===== 3D MODEL GENERATION =====

difference() {
    union() {
        // Outer roundtangle
        rcube([A + frame_width, E + frame_width, frame_thickness], 3, true, false);
        // Handle
        if (handle_length > 0) {
            translate(v = [0, -E/2 - frame_width - handle_length/2 + 10, 0])
                rcube([handle_width, handle_length + 10, frame_thickness], 6.5, true, false);
        }
    }

    // Wire channels - vertical sides
    translate(v = [-A/2, E/2 - corner_radius, frame_thickness-wire_depth])
        rotate([90, 0, 0])  
        linear_extrude(E - corner_radius*2) circle(dia/2);
    translate(v = [A/2, E/2 - corner_radius, frame_thickness-wire_depth])
        rotate([90, 0, 0])  
        linear_extrude(E - corner_radius*2) circle(dia/2);
        
    // Wire channels - horizontal sides
    translate(v = [-A/2 + corner_radius, E/2, frame_thickness-wire_depth])
        rotate([0, 90, 0]) 
        linear_extrude(A - corner_radius*2) circle(dia/2);
    translate(v = [-A/2 + corner_radius, -E/2, frame_thickness-wire_depth])
        rotate([0, 90, 0]) 
        linear_extrude(A - corner_radius*2) circle(dia/2);

    // Wire channel rounded corners
    translate(v = [-A/2 + corner_radius, E/2 - corner_radius, frame_thickness-wire_depth])
        rotate([0, 0, 90]) 
        rotate_extrude(angle=90) translate ([corner_radius,0,0]) circle(dia/2);
    translate(v = [A/2 - corner_radius, E/2 - corner_radius, frame_thickness-wire_depth])
        rotate_extrude(angle=90) translate ([corner_radius,0,0]) circle(dia/2);
    translate(v = [-A/2 + corner_radius, -E/2 + corner_radius, frame_thickness-wire_depth])
        rotate([0, 0, 180]) 
        rotate_extrude(angle=90) translate ([corner_radius,0,0]) circle(dia/2);
    translate(v = [A/2 - corner_radius, -E/2 + corner_radius, frame_thickness-wire_depth])
        rotate([0, 0, 270]) 
        rotate_extrude(angle=90) translate ([corner_radius,0,0]) circle(dia/2);

    // Left wire endstop (driver tail)
    translate(v = [-(A/2 + dia/2 + 1), E/2 - B - C, 0])
        cube(size=[dia + 2, C, frame_thickness]);
    // Right wire endstop (reflector tail)
    translate(v = [(A/2 - dia/2 - 1), E/2 - B - C, 0])
        cube(size=[dia + 2, C, frame_thickness]);

    // Left wing cutout
    translate(v = [-((A/2 + frame_width)/2), 0, 0])
        rcube([(A/2 - frame_width*2), E - frame_width, frame_thickness], 2.5, true, false);

    // Right wing cutout
    translate(v = [(A/2 + frame_width)/2, 0, 0])
        rcube([(A/2 - frame_width*2), E - frame_width, frame_thickness], 2.5, true, false);

    // Big notch for wire insertion
    translate(v = [0, E/2, 0])
        rcube([10, 20, frame_thickness], 3, true, false);

    // Smaller notch for wire routing
    translate(v = [0, E/2, 0])
        rcube([5, 40, frame_thickness], 1.5, true, false);

    // Holes for cable ties (scaled with antenna size)
    if (E > 80) {
        cable_ties(4);
        translate(v = [0, -20, 0])
            cable_ties(4);
    }
    else if (E > 40) {
        translate(v = [0, -7, 0])
            cable_ties(4);
    }
    if (handle_length > 30) {
        translate(v = [0, -(E/2) - 15, 0])
            cable_ties(4);
    }

    // Holes for mounting a connector
    if (handle_length > 0) {
        translate(v = [0, -E/2 - frame_width - handle_length + 15, 0])
            connectors();
    }

    // Frequency text on handle near connector
    if (show_frequency_text && handle_length > 0) {
        translate(v = [0, -E/2 - frame_width - handle_length + 30, frame_thickness - 0.6])
            linear_extrude(0.6) {
                text(str(freq_mhz), size=text_size, font=text_font, halign = "center");
            }
    }
}

module cable_ties(spacing) {
    translate(v = [-spacing, 0, 0])
        rcube([1.5, 5, frame_thickness], 0.5, true, false);
    translate(v = [spacing, 0, 0])
        rcube([1.5, 5, frame_thickness], 0.5, true, false);
}

module connectors() {
    if (connector=="sma") {
        // holes for SMA jack
        cylinder(h=(dia + frame_thickness), r=4.5/2);
        translate(v = [6, 0, 0])
            cylinder(h=(frame_thickness), r=3/2);
        translate(v = [-6, 0, 0])
            cylinder(h=(frame_thickness), r=3/2);
    }
    else if (connector=="bnc") {
        // holes for BNC jack
        translate(v = [0, 1, 0])
            cylinder(h=(frame_thickness), r=11/2);
        translate(v = [6, 7, 0])
            cylinder(h=(frame_thickness), r=3/2);
        translate(v = [-6, 7, 0])
            cylinder(h=(frame_thickness), r=3/2);
        translate(v = [6, -5, 0])
            cylinder(h=(frame_thickness), r=3/2);
        translate(v = [-6, -5, 0])
            cylinder(h=(frame_thickness), r=3/2);
    }
    else if (connector=="screw") {
        // just a screw hole
        cylinder(h=(frame_thickness), r=screw_dia/2);
    }
}

// Rounded cube function (adapted from NopSCADlib)
module rcube(size, r = 0, xy_center = false, z_center = false) {
    linear_extrude(size.z, center = z_center, convexity = 5)
        offset(r) offset(-r) square([size.x, size.y], center = true);
}
