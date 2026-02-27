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
build_carriage        = true;   // Render the sleigh / carriage

// --- Crank position (rotation state) ------------------------
//     Allows visual inspection of the assembly at each of the
//     four extreme crank positions to verify clearances, stroke,
//     and connecting-rod alignment.
//     0 = Top, 1 = Right (max extension), 2 = Bottom, 3 = Left (max retraction)
crank_position = 0;

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
con_rod_length         = 220;   // Centre-to-centre distance (mm) — ≈2.6× crank radius
con_rod_bar_thickness  = 10;    // Flat-bar section thickness
con_rod_big_bore       = bearing_608_od + bearing_608_clearance;  // Socket bore fits bearing OD (22.2 mm)
con_rod_big_od         = con_rod_big_bore + 8;   // Wall around bearing (≈30.2 mm)
con_rod_small_bore     = bearing_608_od + bearing_608_clearance;  // Same 608 bearing at small end too
con_rod_small_od       = con_rod_small_bore + 8; // Wall around bearing (≈30.2 mm)
con_rod_socket_height  = bearing_608_width + 3;  // Bearing width + 1 mm shoulder each side (9 mm)
con_rod_pin_gap        = 1;     // Clearance above crank-pin fillet before bearing sits
con_rod_gusset_length  = 10;    // How far each wedge extends from socket edge along rod
con_rod_gusset_width   = 10;    // Y width of gusset (matches bar thickness)

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
frame_x_end             = 345;      // Right edge (past max slider pos ≈ 276 mm)
frame_length            = frame_x_end - frame_x_start;  // ≈ 360 mm

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
guide_wall_x1           = 100;      // Near wall X centre (clear of wheel edge ≈ 91.2 + margin)
guide_wall_x2           = 340;      // Far wall X centre
guide_wall_thick        = 10;       // Wall thickness in X direction
guide_wall_height       = 25;       // Height above frame +Z face
guide_rod_z_offset      = 12;       // Guide rod centre above frame +Z face
frame_edge_radius       = 3;        // Fillet radius on vertical edges of plate & walls

// --- Carriage / Sleigh ---------------------------------------
//     Rides on two 8 mm guide rods via LM8UU linear bearings.
//     Wrist pin connects to the connecting rod small end.
//     PVC pipe clamp mounts on top.
//
//     3D Print: flat face (−Z) on bed; wrist pin and clamp
//     extend upward.

// LM8UU linear bearing (standard dimensions)
lm8uu_bore              = 8;        // Inner diameter (matches guide rod)
lm8uu_od                = 15;       // Outer diameter
lm8uu_length            = 24;       // Length
lm8uu_clearance         = 0.2;      // Press-fit tolerance on OD pocket

// Carriage body
carriage_wall           = 4;        // Wall thickness around bearing pockets
carriage_bearing_spacing = 40;      // X spacing between bearing pair centres on each rod
carriage_body_width     = guide_rod_spacing + lm8uu_od + 2 * carriage_wall;  // Y dimension
carriage_body_length    = carriage_bearing_spacing + lm8uu_length + 2 * carriage_wall;  // X dimension
carriage_body_height    = lm8uu_od + 2 * carriage_wall;   // Z dimension (around bearing OD, = 19 mm)

// Con-rod socket clearance recess
//     The carriage top extends ~2.5 mm above the con-rod socket bottom.
//     A circular recess at the wrist-pin location lets the socket
//     nest into the carriage top without collision.
carriage_recess_d       = con_rod_small_od + 4;  // Clearance around 30.2 mm socket (≈34.2 mm)
carriage_recess_depth   = 3;        // Removes top 3 mm at pin location (clears 2.5 mm overlap + gap)

// Wrist pin (connects to con-rod small end via 608 bearing)
wrist_pin_diameter      = 8;        // Matches 608 2RS bearing bore
wrist_pin_height        = crank_pin_height;  // Same as crank pin
wrist_pin_fillet_dia    = 14;
wrist_pin_fillet_height = 2;

// Guide rod centre Z in carriage-local coords
// The carriage is built with its −Z face at z=0 (print bed).
// Guide rod centres sit at z = carriage_body_height / 2
carriage_rod_z          = carriage_body_height / 2;

// PVC pipe clamp placeholder
pvc_pipe_od             = 26.7;     // 3/4" PVC pipe OD (standard Schedule 40)
pvc_clamp_clearance     = 0.5;
pvc_clamp_wall          = 4;

// Derived
hub_total_height = wheel_thickness + hub_extension;  // Total hub height from −Z face

// --- Crank position geometry (derived from crank_position) ---
crank_angle = crank_position == 0 ?    0 :   // Top
              crank_position == 1 ?  -90 :   // Right
              crank_position == 2 ? -180 :   // Bottom
              crank_position == 3 ? -270 : 0;// Left

crank_pos_name = crank_position == 0 ? "Top" :
                 crank_position == 1 ? "Right" :
                 crank_position == 2 ? "Bottom" :
                 crank_position == 3 ? "Left" : "Top";

// Pin position in wheel-local XY after rotation
pin_x = -crank_radius * sin(crank_angle);
pin_y =  crank_radius * cos(crank_angle);

// Slider axis is the X axis (Y = 0); small end stays on this line
slider_x = pin_x + sqrt(con_rod_length * con_rod_length - pin_y * pin_y);

// Connecting rod swing angle (from big end at pin toward small end on X axis)
con_rod_swing = atan2(-pin_y, slider_x - pin_x);

// ============================================================
//  Echo key dimensions for verification
// ============================================================
echo(str("Crank wheel diameter: ", wheel_diameter, " mm"));
echo(str("Crank radius (pin offset): ", crank_radius,
         " mm  →  stroke = ", stroke_length, " mm"));
echo(str("Crank position: ", crank_pos_name, " (", crank_angle, "°)",
         "  pin=(", pin_x, ", ", pin_y, ")  slider_x=", slider_x));
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
echo(str("Carriage: ", carriage_body_length, "×", carriage_body_width,
         "×", carriage_body_height, " mm  LM8UU pockets: ",
         lm8uu_od + lm8uu_clearance, " mm bore × ", lm8uu_length, " mm"));

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

            // ---- Gusset wedges (inside face of each socket only) ----
            //      Base penetrates into the socket cylinder so there's
            //      no visible seam on the socket wall.
            // Big-end gusset (toward small end, +X direction)
            translate([0, 0, 0])
                hull() {
                    translate([5, -con_rod_gusset_width / 2, 0])
                        cube([0.01, con_rod_gusset_width, con_rod_socket_height]);
                    translate([con_rod_big_od / 2 + con_rod_gusset_length,
                               -con_rod_gusset_width / 2,
                               con_rod_socket_height - 0.01])
                        cube([0.01, con_rod_gusset_width, 0.01]);
                }
            // Small-end gusset (toward big end, −X direction)
            translate([con_rod_length, 0, 0])
                hull() {
                    translate([-5, -con_rod_gusset_width / 2, 0])
                        cube([0.01, con_rod_gusset_width, con_rod_socket_height]);
                    translate([-(con_rod_small_od / 2 + con_rod_gusset_length),
                               -con_rod_gusset_width / 2,
                               con_rod_socket_height - 0.01])
                        cube([0.01, con_rod_gusset_width, 0.01]);
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
//  Carriage / Sleigh Module
// ============================================================
// Built with −Z face at z = 0 (print bed).
// Guide rod axes run along X at z = carriage_rod_z.
// Wrist pin projects from +Z face, centred in X.
// Origin is at the centre of the body in XY, bottom at z=0.
module carriage() {
    pocket_d = lm8uu_od + lm8uu_clearance;

    difference() {
        union() {
            // ---- Main body (rounded vertical edges) ----
            translate([-carriage_body_length / 2,
                       -carriage_body_width / 2, 0])
                rounded_rect([carriage_body_length,
                              carriage_body_width,
                              carriage_body_height],
                             frame_edge_radius);

            // ---- Wrist pin (on +Z face, starts from recess floor) ----
            translate([0, 0, carriage_body_height - carriage_recess_depth]) {
                cylinder(h = wrist_pin_fillet_height,
                         d1 = wrist_pin_fillet_dia,
                         d2 = wrist_pin_diameter);
                cylinder(h = wrist_pin_height + wrist_pin_fillet_height,
                         d = wrist_pin_diameter);
            }
        }

        // ---- Con-rod socket clearance recess ----
        //      Circular pocket at top centre so the con-rod small-end
        //      socket can nest without colliding with the carriage body.
        translate([0, 0, carriage_body_height - carriage_recess_depth - 0.01])
            cylinder(h = carriage_recess_depth + 0.02, d = carriage_recess_d);

        // ---- LM8UU bearing pockets (4 total: 2 per rod) ----
        //      Each pocket extends to the nearest X face of the carriage
        //      so bearings can be inserted from the outside.
        for (y_off = [-guide_rod_spacing / 2, guide_rod_spacing / 2]) {
            // Outer pair — pocket extends to outer X face
            for (x_sign = [-1, 1]) {
                x_centre = x_sign * carriage_bearing_spacing / 2;
                // Pocket from bearing centre toward the nearest carriage edge
                pocket_start = x_centre - lm8uu_length / 2;
                pocket_end   = x_sign > 0
                    ? carriage_body_length / 2 + 1
                    : -(carriage_body_length / 2 + 1);
                pocket_len = abs(pocket_end - pocket_start);
                translate([min(pocket_start, pocket_end), y_off, carriage_rod_z])
                    rotate([0, 90, 0])
                        cylinder(h = pocket_len, d = pocket_d);
            }
        }

        // ---- Guide rod through-channels ----
        //      Full-length slots so rods can pass through the body
        for (y_off = [-guide_rod_spacing / 2, guide_rod_spacing / 2]) {
            translate([-carriage_body_length / 2 - 1, y_off, carriage_rod_z])
                rotate([0, 90, 0])
                    cylinder(h = carriage_body_length + 2,
                             d = guide_rod_hole_d);
        }
    }
}

// ============================================================
//  Helper: cube with rounded vertical (XY) edges
// ============================================================
module rounded_rect(size, r) {
    hull() {
        for (x = [r, size.x - r], y = [r, size.y - r])
            translate([x, y, 0])
                cylinder(r = r, h = size.z);
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
            // ---- Main plate (rounded vertical edges) ----
            translate([frame_x_start, -frame_width / 2, -frame_thickness])
                rounded_rect([frame_length, frame_width, frame_thickness],
                             frame_edge_radius);

            // ---- Guide support wall 1 (near end, just past wheel edge) ----
            translate([guide_wall_x1 - guide_wall_thick / 2,
                       -frame_width / 2, 0])
                rounded_rect([guide_wall_thick, frame_width, guide_wall_height],
                             frame_edge_radius);

            // ---- Guide support wall 2 (far end) ----
            translate([guide_wall_x2 - guide_wall_thick / 2,
                       -frame_width / 2, 0])
                rounded_rect([guide_wall_thick, frame_width, guide_wall_height],
                             frame_edge_radius);
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
        rotate([0, 0, crank_angle])
            crank_wheel_body();

// ---- Connecting rod on the crank pin ----
// Socket bottom (z=0 of module) sits just above the crank-pin fillet.
con_rod_base_z = wheel_thickness / 2
               + crank_pin_fillet_height
               + con_rod_pin_gap;

if (build_connecting_rod)
translate([0, 0, wheel_diameter / 2])
    rotate([90, 0, 0])
        translate([pin_x, pin_y, con_rod_base_z])
            rotate([0, 0, con_rod_swing])
                connecting_rod();

// ---- Frame bracket (stationary, on −Z side of wheel) ----
//      +Z face of frame sits frame_gap below the wheel's −Z face.
if (build_frame_bracket)
translate([0, 0, wheel_diameter / 2])
    rotate([90, 0, 0])
        translate([0, 0, -(wheel_thickness / 2 + frame_gap)])
            frame_bracket();

// ---- Carriage / Sleigh ----
//      Slides along X at slider_x.  Guide rod centres in wheel-local
//      coords are at z = -(wheel_thickness/2 + frame_gap) + guide_rod_z_offset.
//      Carriage body centre aligns its rod pockets to the guide rods.
carriage_z_local = -(wheel_thickness / 2 + frame_gap)
                 + guide_rod_z_offset
                 - carriage_rod_z;   // Shift so rod centres align

if (build_carriage)
translate([0, 0, wheel_diameter / 2])
    rotate([90, 0, 0])
        translate([slider_x, 0, carriage_z_local])
            carriage();

// ---- Guide rods (visual reference, silver color) ----
guide_rod_local_z = -(wheel_thickness / 2 + frame_gap) + guide_rod_z_offset;
guide_rod_length  = guide_wall_x2 - guide_wall_x1 + guide_wall_thick;  // wall-to-wall span
color("Silver")
translate([0, 0, wheel_diameter / 2])
    rotate([90, 0, 0])
        for (y_off = [-guide_rod_spacing / 2, guide_rod_spacing / 2])
            translate([guide_wall_x1 - guide_wall_thick / 2,
                       y_off, guide_rod_local_z])
                rotate([0, 90, 0])
                    cylinder(h = guide_rod_length, d = guide_rod_diameter);
