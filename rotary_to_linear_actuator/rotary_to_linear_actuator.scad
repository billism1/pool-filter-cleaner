// Rotary to Linear Actuator – Step 1: Crank Wheel
//
// Connects to the 3/4" (19.05 mm) aluminum tube coming from the
// mating_bevel_gear in filter_holder_with_gear.scad.
//
// Converts rotary motion into linear (back-and-forth) motion via
// a crank-slider mechanism with a 6-inch (152.4 mm) stroke.
//
// 3D Printing:
//   • Designed to print on its side (−Z face down on print bed).
//   • The −Z face of the wheel disc is flat (no protruding hub).
//   • Hub tube and crank pin both extend from the +Z face only.
//
// Orientation in the designer:
//   • Tube bore runs along the Y axis (horizontal / parallel to
//     the XY bottom plane).
//   • Wheel disc stands vertically in the XZ plane.
//   • Crank pin projects in the −Y direction from the front face.
//   • Bottom of wheel rim sits on the XY plane (Z = 0).

$fn = 80;  // High facet count for smooth curves.  Use 60 for fast previews.

// --- Render toggles ------------------------------------------
build_crank_wheel     = true;   // Render the crank wheel
build_connecting_rod  = true;   // Render the connecting rod
build_frame_bracket   = true;   // Render the frame / mounting bracket

// ============================================================
//  Parameters
// ============================================================

// --- Tube / Rod (must match filter_holder_with_gear.scad) ----
rod_diameter       = 19.05;   // 3/4″ aluminum tube OD
rod_clearance      = 0.5;     // Clearance for snug fit + set-screw clamping
rod_hole_diameter  = rod_diameter + rod_clearance;   // 19.55 mm

// --- Hub (cylindrical boss around the tube bore) -------------
//     Only extends on the +Z (crank pin) side for 3D-print-friendliness.
//     The −Z face is flat against the wheel disc (print bed side).
hub_wall_thickness = 6;
hub_outer_diameter = rod_hole_diameter + 2 * hub_wall_thickness;  // ≈31.55 mm
hub_extension      = 10;      // How far the hub extends beyond the +Z wheel face

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
crank_pin_diameter      = 8;    // Sized for 608 2RS bearing bore (8 mm)
crank_pin_height        = 20;   // Exposed shaft for bearing + connecting-rod
crank_pin_fillet_dia    = 14;   // Wider tapered base for stress relief
crank_pin_fillet_height = 2;

// --- 608 2RS Bearing (on crank pin) --------------------------
bearing_608_bore        = 8;    // Inner diameter
bearing_608_od          = 22;   // Outer diameter
bearing_608_width       = 7;    // Width / thickness
bearing_608_clearance   = 0.2;  // Press-fit tolerance for OD pocket in socket

// --- Lightening holes (material saving, same style as mating_bevel_gear) ---
lightening_hole_count           = 6;
lightening_hole_diameter         = 35;     // Diameter of each circular hole
lightening_hole_circle_radius    = (hub_outer_diameter / 2 + wheel_diameter / 2) / 2;  // Midway between hub and rim

// --- Connecting Rod ------------------------------------------
con_rod_length         = 200;   // Centre-to-centre distance (mm) — ≈2.6× crank radius
con_rod_bar_thickness  = 10;    // Flat-bar section thickness
con_rod_big_bore       = bearing_608_od + bearing_608_clearance;  // Socket bore fits bearing OD (22.2 mm)
con_rod_big_od         = con_rod_big_bore + 8;   // Wall around bearing (≈30.2 mm)
con_rod_small_bore     = bearing_608_od + bearing_608_clearance;  // Same 608 bearing at small end too
con_rod_small_od       = con_rod_small_bore + 8; // Wall around bearing (≈30.2 mm)
con_rod_socket_height  = bearing_608_width + 3;  // Bearing width + 1 mm shoulder each side (9 mm)
con_rod_pin_gap        = 1;     // Clearance above crank-pin fillet before bearing sits

// --- Frame / Mounting Bracket --------------------------------
//     Stationary bracket on the −Z side of the wheel (opposite
//     hub / set screws / crank pin).  Houses an S6904ZZ bearing
//     for the aluminum tube and extends along the slider axis
//     with two guide-rod support walls for the sleigh.
//
//     3D Print: lay flat with −Z face on bed; walls print upward.
frame_thickness         = 12;
frame_gap               = 2;        // Air gap between wheel −Z face and frame +Z face
frame_width             = 70;       // Y dimension of main plate
frame_x_start           = -40;      // Left edge relative to wheel centre
frame_x_end             = 300;      // Right edge (past max slider pos ≈ 276 mm)
frame_length            = frame_x_end - frame_x_start;  // ≈ 340 mm

// S6904ZZ bearing pocket (same bearing as filter holders)
frame_bearing_od_wiggle = 0.25;
frame_bearing_od        = 37 + frame_bearing_od_wiggle;  // 37.25 mm
frame_bearing_width     = 9;        // = bearing thickness

// Ring cutout below bearing (prevents rotating inner race from rubbing frame)
frame_ring_gap          = 0.633;    // Gap between tube hole edge and cutout
frame_ring_radial       = 2.5;      // Radial thickness of cutout
frame_ring_depth        = 2;        // Axial depth into frame below bearing
frame_tube_clearance    = 2.0;      // Loose fit — bearing provides alignment
frame_tube_hole_d       = rod_diameter + frame_tube_clearance;  // ≈ 21 mm
frame_ring_inner_d      = frame_tube_hole_d + 2 * frame_ring_gap;   // ≈ 22.3 mm
frame_ring_outer_d      = frame_ring_inner_d + 2 * frame_ring_radial; // ≈ 27.3 mm

// Guide rod support walls
guide_rod_diameter      = 8;        // Standard 8 mm smooth steel rod
guide_rod_clearance     = 0.3;
guide_rod_hole_d        = guide_rod_diameter + guide_rod_clearance;   // 8.3 mm
guide_rod_spacing       = 50;       // Y centre-to-centre between two parallel rods
guide_wall_x1           = 95;       // Near wall X centre (just past wheel edge ≈ 91.2)
guide_wall_x2           = 285;      // Far wall X centre
guide_wall_thick        = 10;       // Wall thickness in X direction
guide_wall_height       = 16;       // Height above frame +Z face (top stays below con-rod socket at z=9)
guide_rod_z_offset      = 10;       // Guide rod centre above frame +Z face

// Derived
hub_total_height = wheel_thickness + hub_extension;  // Total hub height from −Z face

// ============================================================
//  Echo key dimensions for verification
// ============================================================
echo(str("Crank wheel diameter: ", wheel_diameter, " mm"));
echo(str("Crank radius (pin offset): ", crank_radius,
         " mm  →  stroke = ", stroke_length, " mm"));
echo(str("Tube bore diameter: ", rod_hole_diameter, " mm"));
echo(str("Hub OD: ", hub_outer_diameter, " mm,  hub extension: ", hub_extension, " mm"));
echo(str("Hub total height (disc + extension): ", hub_total_height, " mm"));
echo(str("Connecting rod: length=", con_rod_length, " mm  big bore=",
         con_rod_big_bore, " mm  small bore=", con_rod_small_bore,
         " mm  socket height=", con_rod_socket_height, " mm"));
echo(str("Frame: ", frame_length, "×", frame_width, "×", frame_thickness,
         " mm  bearing pocket OD=", frame_bearing_od, " mm"));
echo(str("  Guide rods: ", guide_rod_diameter, " mm, spacing=",
         guide_rod_spacing, " mm, walls at x=", guide_wall_x1,
         " & ", guide_wall_x2));
echo(str("  Slider travel: x=", con_rod_length - crank_radius,
         " to x=", con_rod_length + crank_radius, " mm"));

// ============================================================
//  Crank Wheel Module  (built with rotation axis along Z)
// ============================================================
module crank_wheel_body() {
    difference() {
        union() {
            // ---- Wheel disc (centred at origin) ----
            cylinder(h = wheel_thickness, d = wheel_diameter, center = true);

            // ---- Hub (extends only on +Z / crank-pin side; flat on −Z / print-bed side) ----
            translate([0, 0, -wheel_thickness / 2])
                cylinder(h = hub_total_height, d = hub_outer_diameter);

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

        // ---- Tube bore (through entire hub + disc) ----
        translate([0, 0, -wheel_thickness / 2 - 1])
            cylinder(h = hub_total_height + 2, d = rod_hole_diameter);

        // ---- Set-screw holes (on +Z hub extension, 180° apart) ----
        //      Located on the crank-pin side of the hub, accessible from outside.
        ss_z = wheel_thickness / 2 + hub_extension / 2;

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
//  Connecting Rod Module
// ============================================================
// Socket-style rod for hub clearance:
//   • z = 0 is the bottom of the sockets (sits just above crank-pin fillet)
//   • Socket bosses extend from z=0 to z=con_rod_socket_height
//   • The flat bar body sits on top: z=con_rod_socket_height to
//     z=con_rod_socket_height + con_rod_bar_thickness
//   • Pin bores go through the full height so the rod slides onto the pin
//
// 3D Printing: print with the flat bar face (top, away-from-wheel side)
//   on the bed; sockets extend upward from the bed.
module connecting_rod() {
    total_h = con_rod_socket_height + con_rod_bar_thickness;

    difference() {
        union() {
            // Big-end socket boss (full height)
            cylinder(h = total_h, d = con_rod_big_od);

            // Small-end socket boss (full height)
            translate([con_rod_length, 0, 0])
                cylinder(h = total_h, d = con_rod_small_od);

            // Rod body (elevated flat bar connecting both sockets)
            translate([0, 0, con_rod_socket_height])
                hull() {
                    cylinder(h = con_rod_bar_thickness, d = con_rod_big_od);
                    translate([con_rod_length, 0, 0])
                        cylinder(h = con_rod_bar_thickness, d = con_rod_small_od);
                }
        }

        // Big-end pin bore (through-hole for crank pin)
        translate([0, 0, -1])
            cylinder(h = total_h + 2, d = con_rod_big_bore);

        // Small-end pin bore (through-hole for wrist/pivot pin)
        translate([con_rod_length, 0, -1])
            cylinder(h = total_h + 2, d = con_rod_small_bore);
    }
}

// ============================================================
//  Frame / Mounting Bracket Module
// ============================================================
// Built with +Z face at z = 0 (faces the wheel).
// −Z face is the print-bed side.
// Two guide-rod support walls rise from the +Z face at the
// ends of the slider travel range.
module frame_bracket() {
    difference() {
        union() {
            // ---- Main plate ----
            translate([frame_x_start, -frame_width / 2, -frame_thickness])
                cube([frame_length, frame_width, frame_thickness]);

            // ---- Guide support wall 1 (near end, just past wheel edge) ----
            translate([guide_wall_x1 - guide_wall_thick / 2,
                       -frame_width / 2, 0])
                cube([guide_wall_thick, frame_width, guide_wall_height]);

            // ---- Guide support wall 2 (far end) ----
            translate([guide_wall_x2 - guide_wall_thick / 2,
                       -frame_width / 2, 0])
                cube([guide_wall_thick, frame_width, guide_wall_height]);
        }

        // ---- S6904ZZ bearing pocket (recessed from +Z face) ----
        translate([0, 0, -frame_bearing_width])
            cylinder(h = frame_bearing_width + 0.1, d = frame_bearing_od);

        // ---- Ring cutout below bearing pocket ----
        //      Prevents the rotating bearing inner race from rubbing
        //      against the frame body (same technique as filter_holder).
        translate([0, 0, -(frame_bearing_width + frame_ring_depth)]) {
            difference() {
                cylinder(h = frame_ring_depth + 1, d = frame_ring_outer_d);
                cylinder(h = frame_ring_depth + 1, d = frame_ring_inner_d);
            }
        }

        // ---- Tube through-hole (loose fit below bearing) ----
        translate([0, 0, -frame_thickness - 1])
            cylinder(h = frame_thickness + 2, d = frame_tube_hole_d);

        // ---- Guide rod holes in wall 1 ----
        for (y_off = [-guide_rod_spacing / 2, guide_rod_spacing / 2]) {
            translate([guide_wall_x1 - guide_wall_thick / 2 - 1,
                       y_off, guide_rod_z_offset])
                rotate([0, 90, 0])
                    cylinder(h = guide_wall_thick + 2, d = guide_rod_hole_d);
        }

        // ---- Guide rod holes in wall 2 ----
        for (y_off = [-guide_rod_spacing / 2, guide_rod_spacing / 2]) {
            translate([guide_wall_x2 - guide_wall_thick / 2 - 1,
                       y_off, guide_rod_z_offset])
                rotate([0, 90, 0])
                    cylinder(h = guide_wall_thick + 2, d = guide_rod_hole_d);
        }
    }
}

// ============================================================
//  Assembly — place parts in final orientation
// ============================================================
//  rotate([90, 0, 0])  →  local Z becomes world −Y  (tube runs along Y)
//  translate up so bottom rim sits on Z = 0

// ---- Crank wheel ----
if (build_crank_wheel)
translate([0, 0, wheel_diameter / 2])
    rotate([90, 0, 0])
        crank_wheel_body();

// ---- Connecting rod on the crank pin ----
// Socket bottom (z=0 of module) sits just above the crank-pin fillet.
con_rod_base_z = wheel_thickness / 2
               + crank_pin_fillet_height
               + con_rod_pin_gap;

// Inline slider-crank: slider axis is local X through the wheel centre.
// At the default position (pin at top, [0, crank_radius]) the rod
// angles down toward the slider at [sqrt(L²−R²), 0].
con_rod_swing = atan2(-crank_radius,
                      sqrt(con_rod_length * con_rod_length
                           - crank_radius * crank_radius));

if (build_connecting_rod)
translate([0, 0, wheel_diameter / 2])
    rotate([90, 0, 0])
        translate([0, crank_radius, con_rod_base_z])
            rotate([0, 0, con_rod_swing])
                connecting_rod();

// ---- Frame bracket (stationary, on −Z side of wheel) ----
//      +Z face of frame sits frame_gap below the wheel's −Z face.
if (build_frame_bracket)
translate([0, 0, wheel_diameter / 2])
    rotate([90, 0, 0])
        translate([0, 0, -(wheel_thickness / 2 + frame_gap)])
            frame_bracket();
