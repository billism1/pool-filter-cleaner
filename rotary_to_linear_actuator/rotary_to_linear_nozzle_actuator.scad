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

$fn = 180;  // High facet count for smooth curves.  Use 60 for fast previews.

// --- Render toggles ------------------------------------------
build_crank_wheel     = true;   // Render the crank wheel
build_connecting_rod  = false;   // Render the connecting rod
build_frame_bracket   = true;   // Render the frame / mounting bracket
build_spacer_ring     = true;   // Render the spacer ring (between wheel and frame bearing)
show_aluminum_tube    = true;   // Render the aluminum tube as a visual reference (gray color)
show_spray_tube       = true;   // Render the spray pipe (parallel to connecting rod, gray)
show_crank_pin        = false;   // Render the crank pin as a visual reference (metallic)

// --- Crank position (rotation state) ------------------------
//     Allows visual inspection of the assembly at each of the
//     four extreme crank positions to verify clearances, stroke,
//     and connecting-rod alignment.
//     0 = Top, 1 = Right (max extension), 2 = Bottom, 3 = Left (max retraction)
crank_position = 3;

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
//     Now a separate metal pin (8 mm steel rod) inserted into
//     a blind hole in the wheel.  No longer 3D-printed.
crank_pin_diameter      = 8;    // 8 mm steel pin diameter (= 608 2RS bore)
crank_pin_height        = 20;   // Exposed shaft above wheel +Z face for bearing + con-rod
crank_pin_hole_depth    = 8;    // Depth of blind hole from +Z face (leaves 4 mm of material)
crank_pin_fillet_dia    = 14;   // Wider tapered boss around hole for pin stabilisation
crank_pin_fillet_height = 2;    // Height of fillet boss above +Z face

// --- 608 2RS Bearing (on crank pin) --------------------------
bearing_608_bore        = 8;    // Inner diameter
bearing_608_od          = 22;   // Outer diameter
bearing_608_width       = 7;    // Width / thickness
bearing_608_clearance   = 0.2;  // Press-fit tolerance for OD pocket in socket
bearing_608_shoulder_hole_d = 16; // Shoulder hole: clears inner race (~12 mm OD),
                                  // outer race (22 mm OD) seats on remaining ring

// --- Lightening holes (material saving, same style as mating_bevel_gear) ---
lightening_hole_count           = 6;
lightening_hole_diameter         = 35;     // Diameter of each circular hole
lightening_hole_circle_radius    = (hub_outer_diameter / 2 + wheel_diameter / 2) / 2;  // Midway between hub and rim

// --- Connecting Rod ------------------------------------------
con_rod_length         = 240;   // Centre-to-centre distance (mm) — ≈2.6× crank radius
con_rod_bar_thickness  = 8;    // Flat-bar section thickness
con_rod_bar_width      = 25;    // Rod body width (narrower than socket OD)
con_rod_big_bore       = bearing_608_od + bearing_608_clearance;  // Socket bore fits bearing OD (22.2 mm)
con_rod_big_od         = con_rod_big_bore + 8;   // Wall around bearing (≈30.2 mm)
con_rod_small_bore     = bearing_608_od + bearing_608_clearance;  // Same 608 bearing at small end too
con_rod_small_od       = con_rod_small_bore + 8; // Wall around bearing (≈30.2 mm)
con_rod_socket_height  = bearing_608_width + 6;  // Bearing width + 1 mm shoulder each side (9 mm)
con_rod_pin_gap        = 1;     // Clearance above crank-pin fillet before bearing sits
con_rod_gusset_length  = 10;    // How far each wedge extends from socket edge along rod
con_rod_gusset_width   = 10;    // Y width of gusset (matches bar thickness)

// --- Frame / Mounting Bracket --------------------------------
//     Stationary bracket on the −Z side of the wheel (opposite
//     hub / set screws / crank pin).  Houses an S6904ZZ bearing
//     for the aluminum tube.
//
//     3D Print: lay flat with −Z face on bed.
frame_thickness         = 12;
frame_gap               = 2;        // Air gap between wheel −Z face and frame +Z face
frame_width             = 70;       // Y dimension of plate
frame_plate_y_min       = -(wheel_diameter / 2 + 5);  // 5 mm beyond wheel bottom
frame_plate_y_max       =  (wheel_diameter / 2 + 5);  // 5 mm beyond wheel top (symmetric)
frame_plate_y_span      = frame_plate_y_max - frame_plate_y_min;  // Total Y span of plate
frame_half_length       = 125;      // Half-length of plate (each side of wheel centre)
frame_x_start           = -frame_half_length;  // Left edge (symmetric)
frame_x_end             =  frame_half_length;  // Right edge (symmetric)
frame_length            = frame_x_end - frame_x_start;  // 250 mm

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

frame_edge_radius       = 3;        // Fillet radius on vertical edges of plate

// Frame lightening holes (circular, same style as wheel)
frame_light_hole_diameter        = 35;   // Hole diameter (slightly smaller than wheel's 35 mm to suit plate)
frame_light_hole_edge_margin     = 10;   // Minimum distance from hole edge to plate edge
frame_light_hole_spacing         = 45;   // Centre-to-centre spacing (diameter + margin gap)
frame_light_hole_bearing_margin  = 5;    // Minimum distance from hole edge to bearing pocket edge

// Derived: centre the hole grid symmetrically on the plate
frame_light_center_x  = (frame_x_start + frame_x_end) / 2;
frame_light_center_y  = (frame_plate_y_min + frame_plate_y_max) / 2;
frame_light_usable_x  = frame_length       - 2 * (frame_light_hole_edge_margin + frame_light_hole_diameter / 2);
frame_light_usable_y  = frame_plate_y_span  - 2 * (frame_light_hole_edge_margin + frame_light_hole_diameter / 2);
frame_light_nx        = floor(frame_light_usable_x / frame_light_hole_spacing) + 1;
frame_light_ny        = floor(frame_light_usable_y / frame_light_hole_spacing) + 1;
frame_light_x_start   = frame_light_center_x - (frame_light_nx - 1) / 2 * frame_light_hole_spacing;
frame_light_y_start   = frame_light_center_y - (frame_light_ny - 1) / 2 * frame_light_hole_spacing;

// --- Spacer Ring ---------------------------------------------
//     Thin ring on the aluminum tube between the wheel's −Z face
//     and the S6904ZZ bearing inner race in the frame bracket.
//     Rotates with the tube/wheel.  Contacts only the bearing
//     inner race (not outer race or balls), so the wheel never
//     rubs against the stationary frame.
spacer_ring_bore       = rod_hole_diameter;       // Snug fit on tube (19.55 mm)
spacer_ring_od         = 24;       // Sized to contact only S6904ZZ inner race (OD ≈25 mm)
spacer_ring_thickness  = frame_gap; // Fills the gap between wheel and bearing (2 mm)

// --- Spray Tube (visual reference) ---------------------------
//     3/4″ aluminum tube running parallel to the connecting rod,
//     offset 20 mm from it on the crank-pin side of the wheel.
//     Extends 3 feet (914.4 mm) in the +X direction from the
//     wheel centre.  Stationary — does not rotate with the wheel.
spray_tube_length    = 914.4;   // 3 feet = 914.4 mm
spray_tube_spacing   = 20;      // Edge-to-edge gap from connecting rod (mm)
spray_tube_wall      = 1.65;    // Same wall thickness as main aluminum tube

// Derived
hub_total_height    = wheel_thickness + hub_extension;  // Total hub height from −Z face

// Spray tube Z position in wheel-local coords (perpendicular to wheel face)
// Places the tube 20 mm past the connecting rod's outer surface on the
// crank-pin (+Z) side, so it clears the rod at all crank angles.
con_rod_total_h     = con_rod_socket_height + con_rod_bar_thickness;
con_rod_base_z_val  = wheel_thickness / 2 + crank_pin_fillet_height + con_rod_pin_gap;
spray_tube_z_local = -(wheel_thickness / 2) - frame_gap - (frame_thickness / 2); // Center the long aluminum tube on the thickness of the frame.

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
echo(str("Crank pin: ", crank_pin_diameter, " mm dia × ",
         crank_pin_hole_depth + crank_pin_height, " mm total  (hole depth=",
         crank_pin_hole_depth, " mm, exposed=", crank_pin_height,
         " mm, remaining wall=", wheel_thickness - crank_pin_hole_depth, " mm)"));
echo(str("Crank position: ", crank_pos_name, " (", crank_angle, "°)",
         "  pin=(", pin_x, ", ", pin_y, ")  slider_x=", slider_x));
echo(str("Tube bore diameter: ", rod_hole_diameter, " mm"));
echo(str("Hub OD: ", hub_outer_diameter, " mm,  hub extension: ", hub_extension, " mm"));
echo(str("Hub total height (disc + extension): ", hub_total_height, " mm"));
echo(str("Connecting rod: length=", con_rod_length, " mm  big bore=",
         con_rod_big_bore, " mm  small bore=", con_rod_small_bore,
         " mm  socket height=", con_rod_socket_height, " mm"));
echo(str("Frame: ", frame_length, "×", frame_plate_y_span, "×", frame_thickness,
         " mm  (plate Y: ", frame_plate_y_min, " to ", frame_plate_y_max,
         ")  bearing pocket OD=", frame_bearing_od, " mm"));
echo(str("  Slider travel: x=", con_rod_length - crank_radius,
         " to x=", con_rod_length + crank_radius, " mm"));
echo(str("Spacer ring: bore=", spacer_ring_bore, " OD=", spacer_ring_od,
         " thickness=", spacer_ring_thickness, " mm"));
echo(str("Spray tube: length=", spray_tube_length, " mm  OD=", rod_diameter,
         " mm  spacing=", spray_tube_spacing, " mm  local Z=",
         spray_tube_z_local, " mm"));

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

            // (Crank pin is a separate metal pin — see show_crank_pin)

            // ---- Fillet boss around pin hole (stabilises inserted pin) ----
            translate([0, crank_radius, wheel_thickness / 2])
                cylinder(h = crank_pin_fillet_height,
                         d1 = crank_pin_fillet_dia, d2 = crank_pin_diameter);
        }

        // ---- Tube bore (through entire hub + disc) ----
        translate([0, 0, -wheel_thickness / 2 - 1])
            cylinder(h = hub_total_height + 2, d = rod_hole_diameter);

        // ---- Crank pin hole (blind hole from +Z face for 8 mm metal pin) ----
        //      Depth = crank_pin_hole_depth (8 mm); leaves 4 mm solid on −Z side.
        translate([0, crank_radius, wheel_thickness / 2 - crank_pin_hole_depth])
            cylinder(h = crank_pin_hole_depth + crank_pin_fillet_height + 1, d = crank_pin_diameter);

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
//   • Pin bores are stepped: bearing pocket at full OD from the
//     open end (z=0), then a shoulder with a smaller hole that
//     clears the inner race but seats the outer race.  The smaller
//     hole continues through to the print-bed side.
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
                    cylinder(h = con_rod_bar_thickness, d = con_rod_bar_width);
                    translate([con_rod_length, 0, 0])
                        cylinder(h = con_rod_bar_thickness, d = con_rod_bar_width);
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

        // Big-end bore (stepped: bearing pocket + shoulder hole)
        //   Pocket: z=0 to bearing width, at bearing OD for press-fit
        //   Shoulder hole: bearing width to total_h, clears inner race
        translate([0, 0, -1])
            cylinder(h = bearing_608_width + 1, d = con_rod_big_bore);
        translate([0, 0, bearing_608_width])
            cylinder(h = total_h - bearing_608_width + 1,
                     d = bearing_608_shoulder_hole_d);

        // Small-end bore (same stepped design)
        translate([con_rod_length, 0, -1])
            cylinder(h = bearing_608_width + 1, d = con_rod_small_bore);
        translate([con_rod_length, 0, bearing_608_width])
            cylinder(h = total_h - bearing_608_width + 1,
                     d = bearing_608_shoulder_hole_d);
    }
}

// ============================================================
//  Spacer Ring Module
// ============================================================
// Thin ring that sits on the tube between wheel and frame bearing.
// Printed flat (ring face on bed).
module spacer_ring() {
    difference() {
        cylinder(h = spacer_ring_thickness, d = spacer_ring_od);

        // Tube bore
        translate([0, 0, -1])
            cylinder(h = spacer_ring_thickness + 2, d = spacer_ring_bore);
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
module frame_bracket() {
    difference() {
        union() {
            // ---- Main plate (rounded vertical edges) ----
            //      Extended in −Y to reach 5 mm below the wheel bottom.
            translate([frame_x_start, frame_plate_y_min, -frame_thickness])
                rounded_rect([frame_length, frame_plate_y_span, frame_thickness],
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

        // ---- Lightening holes (centred grid, skipping bearing area) ----
        //      Grid is centred on the plate so holes are equidistant from
        //      all four edges.  Any hole that would encroach on the bearing
        //      pocket is automatically skipped.
        for (ix = [0 : frame_light_nx - 1])
            for (iy = [0 : frame_light_ny - 1]) {
                hx = frame_light_x_start + ix * frame_light_hole_spacing;
                hy = frame_light_y_start + iy * frame_light_hole_spacing;
                if (sqrt(hx * hx + hy * hy) >
                    frame_bearing_od / 2 + frame_light_hole_diameter / 2 + frame_light_hole_bearing_margin)
                    translate([hx, hy, -frame_thickness - 1])
                        cylinder(h = frame_thickness + 2, d = frame_light_hole_diameter);
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

// ---- Spacer ring (rotates with tube, between wheel and frame bearing) ----
if (build_spacer_ring)
translate([0, 0, wheel_diameter / 2])
    rotate([90, 0, 0])
        rotate([0, 0, crank_angle])
            translate([0, 0, -(wheel_thickness / 2 + spacer_ring_thickness)])
                spacer_ring();

// ---- Frame bracket (stationary, on −Z side of wheel) ----
//      +Z face of frame sits frame_gap below the wheel's −Z face.
if (build_frame_bracket)
translate([0, 0, wheel_diameter / 2])
    rotate([90, 0, 0])
        translate([0, 0, -(wheel_thickness / 2 + frame_gap)])
            frame_bracket();

// ---- Crank pin (visual reference, metallic) ----
//      8 mm steel pin inserted into the wheel's blind hole.
//      Exposed portion extends crank_pin_height above the +Z face.
if (show_crank_pin) {
    color("Silver")
    translate([0, 0, wheel_diameter / 2])
        rotate([90, 0, 0])
            rotate([0, 0, crank_angle])
                translate([0, crank_radius, wheel_thickness / 2 - crank_pin_hole_depth])
                    cylinder(h = crank_pin_hole_depth + crank_pin_height,
                             d = crank_pin_diameter);
}

if (show_aluminum_tube) {
    // ---- Aluminum tube (visual reference, gray) ----
    //      Runs along the wheel's rotation axis (Z in wheel-local coords).
    //      Starts at the top of the hub extension, passes through the wheel,
    //      spacer ring, and frame bearing, then extends 150 mm beyond the frame.
    tube_visual_length = hub_total_height          // hub top to wheel −Z face
                       + frame_gap                 // spacer ring / gap
                       + frame_thickness           // through the frame
                       + 150;                      // extension beyond frame
    color("DimGray")
    translate([0, 0, wheel_diameter / 2])
        rotate([90, 0, 0])
            rotate([0, 0, crank_angle])
                translate([0, 0, -wheel_thickness / 2 - frame_gap - frame_thickness - 150])
                    difference() {
                        cylinder(h = tube_visual_length, d = rod_diameter);
                        translate([0, 0, -1])
                            cylinder(h = tube_visual_length + 2, d = rod_diameter - 2 * 1.65);
                    }
}

// ---- Spray tube (visual reference, gray) ----
//      3/4″ aluminum tube running parallel to the connecting rod,
//      20 mm past its outer surface on the crank-pin side.
//      Runs from X = 0 (wheel centre) to X = 914.4 mm (3 ft).
//      At world Z = wheel_diameter/2 (same height as the existing
//      drive tube, i.e. the Z centre of that tube).
if (show_spray_tube) {
    color("DimGray")
    translate([0, 0, wheel_diameter / 2])
        rotate([90, 0, 0])
            translate([130, 0, spray_tube_z_local])
                rotate([0, 90, 0])
                    difference() {
                        cylinder(h = spray_tube_length, d = rod_diameter);
                        translate([0, 0, -1])
                            cylinder(h = spray_tube_length + 2,
                                     d = rod_diameter - 2 * spray_tube_wall);
                    }
}

