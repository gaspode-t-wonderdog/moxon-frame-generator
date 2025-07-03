// "Self-calculating Moxon antenna frame generator"
// Original idea: https://www.thingiverse.com/thing:2068392
// Based on empirical formulas by L.B. Cebik (W4RNL)
// 2025 DN9TT (tom@jitter.eu)
// License: CC-BY-NC-SA

freq_mhz = 433;              // Design frequency in MHz
wire_dia_mm = 1.0;           // Wire diameter in mm
wire_vf = 0.95;              // Wire velocity factor (0.94-0.98 for PVC/insulated, 1.0 for bare)
structure_correction = 1.03; // Structure dielectric loading (1.02-1.05 for plastic frames)
frame = 7;                   // Frame width
thickness = 2.5;             // Frame thickness
corner_radius = 3;
wire_depth_ratio = 0.33;     // Wire channel depth as fraction of diameter
handle_length = 60;
connector = "bnc";           // "sma", "bnc", "screw", or "none"
screw_dia = 4.4;
tsize = 6;
font = "Core Sans D 55 Bold";
$fn = 255;

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
        A_wl = (AA * pow(dia_wavelengths, 2)) + (AB * dia_wavelengths) + AC,
        B_wl = (BA * pow(dia_wavelengths, 2)) + (BB * dia_wavelengths) + BC,
        C_wl = (CA * pow(dia_wavelengths, 2)) + (CB * dia_wavelengths) + CC,
        D_wl = (DA * dia_wavelengths) + DB,
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
A_vf = A_raw * wire_vf;
B_vf = B_raw * wire_vf;
C_vf = C_raw * wire_vf;
D_vf = D_raw * wire_vf;
E_vf = E_raw * wire_vf;

// Apply structure correction (for plastic frame loading)
A = A_vf * structure_correction;
B = B_vf * structure_correction;
C = C_vf * structure_correction;
D = D_vf * structure_correction;
E = E_vf * structure_correction;
wavelength = calc_result[5];
diameter_valid = calc_result[6];
boom_length_wavelengths = calc_result[7];
wire_length_mm = calc_result[8] * wire_vf * structure_correction;
compactness_factor = calc_result[9];

// Wire channel parameters
dia = wire_dia_mm + 0.1;    // Add tolerance for 3D printing
wire_depth = dia * wire_depth_ratio;

// Verbose
echo(str("=== MOXON CALCULATOR RESULTS ==="));
echo(str("Design frequency: ", freq_mhz, " MHz"));
echo(str("Wire diameter: ", wire_dia_mm, " mm (", round(wire_dia_mm/wavelength * 1000000)/1000000, " λ)"));
echo(str("Wire velocity factor: ", wire_vf, " (", wire_vf == 1.0 ? "bare wire" : "insulated wire", ")"));
echo(str("Structure correction: ", structure_correction, " (plastic frame dielectric loading)"));
echo(str("   → Combined effect: ", round((wire_vf * structure_correction - 1)*1000)/10, "% dimension change"));
echo(str("   → Without corrections, antenna would resonate ~", round(freq_mhz/(wire_vf * structure_correction)), " MHz"));
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

if (wire_vf < 0.92 || wire_vf > 1.0) {
    echo(str("⚠ WARNING: Wire velocity factor outside typical range!"));
    echo(str("   Typical values: PVC=0.94-0.96, PTFE=0.95-0.97, PE=0.66, bare=1.0"));
}

if (structure_correction < 1.0 || structure_correction > 1.06) {
    echo(str("⚠ WARNING: Structure correction outside validated range!"));
    echo(str("   Research shows 1.02-1.05 for plastic structures, 1.0 for no frame"));
}

difference() {
    union() {
        // Outer roundtangle
        rcube([A + frame, E + frame, thickness], 3, true, false);
        // Handle
        translate(v = [0, -E/2 - frame - handle_length/2 + 10, 0])
            rcube([21, handle_length + 10, thickness], 6.5, true, false);
    }

    // Wire channels - vertical sides
    translate(v = [-A/2, E/2 - corner_radius, thickness-wire_depth])
        rotate([90, 0, 0])  
        linear_extrude(E - corner_radius*2) circle(dia/2);
    translate(v = [A/2, E/2 - corner_radius, thickness-wire_depth])
        rotate([90, 0, 0])  
        linear_extrude(E - corner_radius*2) circle(dia/2);
        
    // Wire channels - horizontal sides
    translate(v = [-A/2 + corner_radius, E/2, thickness-wire_depth])
        rotate([0, 90, 0]) 
        linear_extrude(A - corner_radius*2) circle(dia/2);
    translate(v = [-A/2 + corner_radius, -E/2, thickness-wire_depth])
        rotate([0, 90, 0]) 
        linear_extrude(A - corner_radius*2) circle(dia/2);

    // Wire channel rounded corners
    translate(v = [-A/2 + corner_radius, E/2 - corner_radius, thickness-wire_depth])
        rotate([0, 0, 90]) 
        rotate_extrude(angle=90) translate ([corner_radius,0,0]) circle(dia/2);
    translate(v = [A/2 - corner_radius, E/2 - corner_radius, thickness-wire_depth])
        rotate_extrude(angle=90) translate ([corner_radius,0,0]) circle(dia/2);
    translate(v = [-A/2 + corner_radius, -E/2 + corner_radius, thickness-wire_depth])
        rotate([0, 0, 180]) 
        rotate_extrude(angle=90) translate ([corner_radius,0,0]) circle(dia/2);
    translate(v = [A/2 - corner_radius, -E/2 + corner_radius, thickness-wire_depth])
        rotate([0, 0, 270]) 
        rotate_extrude(angle=90) translate ([corner_radius,0,0]) circle(dia/2);

    // Left wire endstop (driver tail)
    translate(v = [-(A/2 + dia/2 + 1), E/2 - B - C, 0])
        cube(size=[dia + 2, C, thickness]);
    // Right wire endstop (reflector tail)
    translate(v = [(A/2 - dia/2 - 1), E/2 - B - C, 0])
        cube(size=[dia + 2, C, thickness]);

    // Left wing cutout
    translate(v = [-((A/2 + frame)/2), 0, 0])
        rcube([(A/2 - frame*2), E - frame, thickness], 2.5, true, false);

    // Right wing cutout
    translate(v = [(A/2 + frame)/2, 0, 0])
        rcube([(A/2 - frame*2), E - frame, thickness], 2.5, true, false);

    // Big notch for wire insertion
    translate(v = [0, E/2, 0])
        rcube([10, 20, thickness], 3, true, false);

    // Smaller notch for wire routing
    translate(v = [0, E/2, 0])
        rcube([5, 40, thickness], 1.5, true, false);

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
    translate(v = [0, -E/2 - frame - handle_length + 15, 0])
        connectors();

    // Frequency text on handle near connector
    translate(v = [0, -E/2 - frame - handle_length + 30, thickness - 0.6])
        linear_extrude(0.6) {
            text(str(freq_mhz), size=tsize, font=font, halign = "center");
        }
}

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
        translate(v = [0, 1, 0])
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

// Rounded cube function (adapted from NopSCADlib)
module rcube(size, r = 0, xy_center = false, z_center = false) {
    linear_extrude(size.z, center = z_center, convexity = 5)
        offset(r) offset(-r) square([size.x, size.y], center = true);
}
