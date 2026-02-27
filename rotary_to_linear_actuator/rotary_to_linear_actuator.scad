// Rotary to Linear Actuator – Step 1: Crank Wheel
//
// Connects to the 3/4" (19.05 mm) aluminum tube coming from the
// mating_bevel_gear in filter_holder_with_gear.scad.
//
// Converts rotary motion into linear (back-and-forth) motion via
// a crank-slider mechanism with a 6-inch (152.4 mm) stroke.
//
// Orientation in the designer:
//   • Tube bore runs along the Y axis (horizontal / parallel to
//     the XY bottom plane).
//   • Wheel disc stands vertically in the XZ plane.
//   • Crank pin projects in the −Y direction from the front face.
//   • Bottom of wheel rim sits on the XY plane (Z = 0).

$fn = 180;  // High facet count for smooth curves.  Use 60 for fast previews.

// ============================================================
//  Parameters
// ============================================================

// --- Tube / Rod (must match filter_holder_with_gear.scad) ----
rod_diameter       = 19.05;   // 3/4″ aluminum tube OD
rod_clearance      = 0.5;     // Clearance for snug fit + set-screw clamping
rod_hole_diameter  = rod_diameter + rod_clearance;   // 19.55 mm

// --- Hub (cylindrical boss around the tube bore) -------------
hub_wall_thickness = 6;
hub_outer_diameter = rod_hole_diameter + 2 * hub_wall_thickness;  // ≈31.55 mm
hub_length         = 35;      // Total length along tube axis

// --- Set Screws (M4 self-threading into plastic) -------------
set_screw_diameter = 3.4;     // 85% of 4 mm nominal
set_screw_depth    = hub_outer_diameter / 2 + 2;  // Reaches to tube bore

// --- Stroke / Crank -----------------------------------------
stroke_length      = 152.4;   // 6 inches = 152.4 mm
crank_radius       = stroke_length / 2;   // 76.2 mm

// --- Wheel Disc ----------------------------------------------
wheel_rim_width    = 15;      // Material beyond crank-pin centre
wheel_diameter     = 2 * (crank_radius + wheel_rim_width);  // ≈182.4 mm
wheel_thickness    = 12;      // Face-to-face thickness of disc

// --- Crank Pin -----------------------------------------------
crank_pin_diameter      = 10;
crank_pin_height        = 20;  // Exposed shaft for connecting-rod
crank_pin_fillet_dia    = 18;  // Wider tapered base for stress relief
crank_pin_fillet_height = 4;

// --- Lightening holes (material saving, same style as mating_bevel_gear) ---
lightening_hole_count           = 6;
lightening_hole_diameter         = 35;     // Diameter of each circular hole
lightening_hole_circle_radius    = (hub_outer_diameter / 2 + wheel_diameter / 2) / 2;  // Midway between hub and rim

// Derived
hub_extension = (hub_length - wheel_thickness) / 2;  // Each side beyond disc face

// ============================================================
//  Echo key dimensions for verification
// ============================================================
echo(str("Crank wheel diameter: ", wheel_diameter, " mm"));
echo(str("Crank radius (pin offset): ", crank_radius,
         " mm  →  stroke = ", stroke_length, " mm"));
echo(str("Tube bore diameter: ", rod_hole_diameter, " mm"));
echo(str("Hub OD: ", hub_outer_diameter, " mm,  hub length: ", hub_length, " mm"));
echo(str("Hub extension per side: ", hub_extension, " mm"));

// ============================================================
//  Crank Wheel Module  (built with rotation axis along Z)
// ============================================================
module crank_wheel_body() {
    difference() {
        union() {
            // ---- Wheel disc (centred at origin) ----
            cylinder(h = wheel_thickness, d = wheel_diameter, center = true);

            // ---- Hub (extends beyond both wheel faces) ----
            cylinder(h = hub_length, d = hub_outer_diameter, center = true);

            // ---- Crank pin on +Z face, at top of wheel ----
            translate([0, crank_radius, wheel_thickness / 2]) {
                // Tapered fillet at base
                cylinder(h = crank_pin_fillet_height,
                         d1 = crank_pin_fillet_dia, d2 = crank_pin_diameter);
                // Straight pin shaft (total height includes fillet)
                cylinder(h = crank_pin_height + crank_pin_fillet_height,
                         d = crank_pin_diameter);
            }
        }

        // ---- Tube bore (through entire hub) ----
        cylinder(h = hub_length + 2, d = rod_hole_diameter, center = true);

        // ---- Set-screw holes (on −Z hub extension, 180° apart) ----
        //      In final orientation these end up on the +Y side
        //      (opposite the crank pin), fully accessible.
        ss_z = -(wheel_thickness / 2 + hub_extension / 2);

        // Hole at 0° (along +X)
        translate([0, 0, ss_z])
            rotate([0, 90, 0])
                cylinder(h = set_screw_depth, d = set_screw_diameter);

        // Hole at 180° (along −X)
        translate([0, 0, ss_z])
            rotate([0, -90, 0])
                cylinder(h = set_screw_depth, d = set_screw_diameter);

        // ---- Lightening holes (circular, same style as mating_bevel_gear) ----
        for (i = [0 : lightening_hole_count - 1]) {
            angle = i * 360 / lightening_hole_count;
            rotate([0, 0, angle])
                translate([lightening_hole_circle_radius, 0, -wheel_thickness / 2 - 1])
                    cylinder(h = wheel_thickness + 2,
                             d = lightening_hole_diameter);
        }
    }
}

// ============================================================
//  Place wheel in final orientation
// ============================================================
//  rotate([90, 0, 0])  →  original Z becomes −Y  (tube runs along Y)
//  translate up so bottom rim sits on Z = 0

translate([0, 0, wheel_diameter / 2])
    rotate([90, 0, 0])
        crank_wheel_body();
