// Pool Filter Cleaner - Filter Holder
// This OpenSCAD script generates a part to hold a pool filter on a 0.75" diameter aluminum rod for easy cleaning.

// Key Dimensions:
// Pool filter inner hole diameter: 76.2 mm (3 inches)
// Support rod diameter: 19.05 mm (0.75 inch)

include <BOSL2/std.scad>
include <BOSL2/gears.scad>
// https://github.com/BelfrySCAD/BOSL2

// Parameters

$fn = 180; // Number of facets for smoothness. Use 180+ for final renders, but 60 is good for quick previews.

//--- Part Dimensions (in mm)

build_pool_filter_holder = true; // Whether to build the main filter holder part
build_connecting_gear = false; // Whether to build the gear that meshes with the flange gear
build_compound_gear = true; // Whether to build the compound gear (spur gear + straight bevel gear for 90° direction change)
build_mating_bevel_gear = true; // Whether to build the larger mating bevel gear (90° axis change)

place_bearing_at_holder_interior = false;
place_bearing_at_holder_exterior = true;

place_bearing_at_simple_gear_base = true;   // Whether to place a bearing pocket at the base of the simple gear
place_bearing_at_compound_gear_base = true; // Whether to place a bearing pocket at the base of the compound gear

// Plug that fits inside the filter
plug_major_diameter = 76.2; // Tapers from this diameter (76.2 mm == 3.0 inches)
plug_minor_diameter = 76.2; // To this diameter for a snug fit (76.2 mm == 3.0 inches)
plug_length = 16; // How far it goes into the filter

// Flange that stays outside the filter
flange_diameter = 135;
flange_thickness = 10;

// Central hole for the support rod
rod_diameter = 19.05;   // (19.05 mm == 0.75 inches)
rod_clearance = 2.55;   // Small clearance so bearing inner diameter contacts rod, not this holder assembly
rod_hole_diameter_loose = rod_diameter + rod_clearance;

// Rod specifications for gears that have a snug fitting tube for the rod (like the mating bevel gear)
gear_rod_clearance = 0.5;         // Clearance for easy insertion
gear_rod_hole_diameter_snug = rod_diameter + gear_rod_clearance;

// Drain holes around the flange
drain_hole_diameter = 20;
drain_hole_count = 6; // Number of holes around the flange
drain_hole_circle_radius = plug_major_diameter / 2; // Centers on the outside diameter of the plug

// Bearing holder at the end of the plug
// S6904ZZ Ball Bearing: 37mm OD, 9mm thick, 20mm ID
bearing_outer_diameter_wiggle_room = 0.25; // Extra space around bearing for tolerance
bearing_outer_diameter = 37 + bearing_outer_diameter_wiggle_room; // Outer diameter of bearing
bearing_thickness = 9; // Thickness/depth of bearing
bearing_inner_diameter = 20; // Inner diameter of bearing

bearing_tube_wall_thickness = 4;         // Wall thickness around the bearing
bearing_tube_outer_diameter = bearing_outer_diameter + 2 * bearing_tube_wall_thickness; // 45mm
bearing_tube_height = bearing_thickness; // Height of the tube that holds the bearing (same as bearing thickness for a flush fit)
bearing_tube_screw_hole_diameter = 3.4;    // Diameter of set screw holes. 3.4mm (85% of 4mm) for M4 screws, which are common and provide good holding strength.

// Ring cutout parameters (creates gap between bearing inner race and plug)
ring_cutout_gap_from_rod_hole = 0.633; // Gap between rod hole edge and ring cutout inner edge
ring_cutout_radial_thickness = 2.5; // Radial thickness of the ring cutout
ring_cutout_depth = 2; // How deep the cutout extends into the plug from bearing area
ring_cutout_inner_diameter = rod_hole_diameter_loose + 2 * ring_cutout_gap_from_rod_hole; // Inner diameter of ring cutout
ring_cutout_outer_diameter = ring_cutout_inner_diameter + 2 * ring_cutout_radial_thickness; // Outer diameter of ring cutout

// Gear teeth parameters (using BOSL2 involute gears)
gear_num_teeth = 50;          // Number of teeth around the flange
gear_mod = 2.8;               // Gear module (controls tooth size) - mod = pitch_diameter / teeth
gear_pressure_angle = 20;     // Standard pressure angle for involute gears
gear_thickness = 10; // Thickness of the gear teeth (same as flange thickness for a flush fit)
gear_clearance = 0.2;         // Clearance for gear meshing
// Calculated: pitch_diameter = mod * teeth = 2.8 * 40 = 112mm
gear_outer_diameter = gear_mod * (gear_num_teeth + 2); // Outer/tip diameter of gear teeth = 117.6mm

// The flange is split into two sections (bottom to top):
// 1. Gear section: has gear teeth, diameter = flange_diameter, thickness = gear_thickness
// 2. Plain section: smooth disc, diameter = gear_outer_diameter, thickness = flange_thickness
//    The bottom outer edge is chamfered (inverted cone) so it prints without support.
flange_chamfer_angle = 30; // Angle from horizontal for support-free 3D printing
flange_overhang_radius = (gear_outer_diameter - flange_diameter) / 2; // Radial overhang distance
flange_chamfer_height = flange_overhang_radius * tan(flange_chamfer_angle); // Height of chamfer cone
flange_total_thickness = gear_thickness + flange_thickness; // Combined height of both flange sections
total_length = plug_length + flange_total_thickness; // Total length of the piece (both flange sections + plug)

// Module to create gear teeth ring using BOSL2 involute gears
module gear_teeth_ring(mod, teeth, thickness, bore_diameter) {
    // Create a proper involute gear using BOSL2
    // The gear is positioned with teeth that properly mesh with other gears
    difference() {
        spur_gear(
            mod=mod,
            teeth=teeth,
            thickness=thickness,
            pressure_angle=gear_pressure_angle,
            clearance=gear_clearance,
            backlash=0.1,
            anchor=BOT  // Anchor at bottom so gear starts at Z=0
        );
        // Remove center to leave only the ring of teeth on the flange edge
        translate([0, 0, -1])
            cylinder(d=bore_diameter, h=thickness + 2);
    }
}

// Module to create a complete gear with hub using BOSL2 involute gears
module simple_gear(mod, num_teeth, thickness) {
    // Parameters for the rod holding tube
    tube_outer_diameter = gear_rod_hole_diameter_snug + (6 * 2);  // Outer diameter of tube // TODO: Parameterize wall thickness
    tube_height = 30;          // Height of the tube
    set_screw_depth = tube_outer_diameter / 2 + 2; // Depth of screw hole
    
    // Material saving parameters - create hollow center with spokes
    //hub_diameter = tube_outer_diameter + 8;  // Solid hub around the tube for strength
    hub_diameter = bearing_outer_diameter + thickness * 1.2;

    gear_pitch_diameter = (mod * num_teeth) - 5;  // Calculated pitch diameter of the gear
    spoke_width = 10;  // Width of spokes connecting hub to gear teeth
    num_spokes = 6;   // Number of spokes for support
    
    difference() {
        union() {
            // Proper involute gear using BOSL2
            spur_gear(
                mod=mod,
                teeth=num_teeth,
                thickness=thickness,
                pressure_angle=gear_pressure_angle,
                clearance=gear_clearance,
                backlash=0.1,
                shaft_diam=0,  // No built-in shaft, we'll add our own tube
                anchor=BOT     // Anchor at bottom so gear starts at Z=0
            );
            
            // Rod holding tube extending from center
            translate([0, 0, thickness])
                cylinder(h = tube_height, d = tube_outer_diameter, center = false);
        }
        
        // Remove material between hub and gear teeth (leaving spokes)
        // Only remove if the gear is large enough to benefit from it
        if (gear_pitch_diameter > hub_diameter + 20) {
            // Cutout stops at 85% of pitch radius to preserve gear teeth
            cutout_outer_radius = (gear_pitch_diameter / 2) * 0.85;
            
            difference() {
                // Remove ring of material from hub edge to cutout radius
                translate([0, 0, -0.5])
                    linear_extrude(height = thickness + 1)
                        difference() {
                            circle(d = cutout_outer_radius * 2);
                            circle(d = hub_diameter);
                        }
                
                // Add back spokes
                for (i = [0:num_spokes-1]) {
                    rotate([0, 0, i * 360 / num_spokes])
                        translate([-spoke_width/2, 0, -1])
                            cube([spoke_width, cutout_outer_radius, thickness + 3]);
                }
            }
        }
        
        // Central hole for the rod (goes all the way through)
        translate([0, 0, -1])
            cylinder(h = thickness + tube_height + 2, d = gear_rod_hole_diameter_snug, center = false);
        
        // Set screw hole 1 (at 0 degrees)
        translate([0, 0, thickness + tube_height / 2]) {
            rotate([0, 90, 0]) {
                cylinder(h = set_screw_depth, d = bearing_tube_screw_hole_diameter, center = false);
            }
        }
        
        // Set screw hole 2 (at 180 degrees)
        translate([0, 0, thickness + tube_height / 2]) {
            rotate([0, -90, 0]) {
                cylinder(h = set_screw_depth, d = bearing_tube_screw_hole_diameter, center = false);
            }
        }
        
        if (place_bearing_at_simple_gear_base) {
            // Bearing pocket recessed into the base of the gear (same as holder exterior placement)
            translate([0, 0, -0.1]) {
                cylinder(h = bearing_tube_height + 0.1, d = bearing_outer_diameter, center = false);
            }
            
            // Ring cutout for bearing area (gap between bearing inner race and gear body)
            translate([0, 0, bearing_tube_height - 1]) {
                difference() {
                    cylinder(h = ring_cutout_depth + 1, d = ring_cutout_outer_diameter, center = false);
                    cylinder(h = ring_cutout_depth + 1, d = ring_cutout_inner_diameter, center = false);
                }
            }
        }
    }
}

// Module to create a compound gear: same-size spur gear on the bottom with a straight
// bevel gear on top for 90-degree direction change.  The small (top) end of the bevel
// gear is sized to transition smoothly into the rod-holding tube.
module compound_gear(mod, num_teeth, thickness, small_num_teeth, small_mod, bevel_mate_teeth) {
    // Parameters for the rod holding tube
    tube_outer_diameter = gear_rod_hole_diameter_snug + (6 * 2);  // Outer diameter of tube
    tube_height = 0;          // Height of the tube
    //set_screw_depth = tube_outer_diameter / 2 + 2; // Depth of screw hole
    set_screw_depth = tube_outer_diameter / 2 + 15 ; // Depth of screw hole. Make deeper for set screw location in hub.
    
    // Material saving parameters - create hollow center with spokes
    hub_diameter = bearing_outer_diameter + thickness * 1.5;
    
    gear_pitch_diameter = (mod * num_teeth) - 5;  // Calculated pitch diameter of the gear
    spoke_width = 10;  // Width of spokes connecting hub to gear teeth
    num_spokes = 6;   // Number of spokes for support
    
    // --- Straight bevel gear calculations ---
    // pitch_angle is determined by the tooth ratio so the two bevel gears mesh at 90°
    bevel_pitch_angle = atan2(small_num_teeth, bevel_mate_teeth);
    bevel_outer_radius = small_mod * (small_num_teeth + 2) / 2; // Outer (tip) radius at big end
    bevel_root_radius = small_mod * (small_num_teeth - 2.5) / 2; // Root (trough) radius at big end (dedendum = 1.25*mod)
    bevel_pitch_radius = small_mod * small_num_teeth / 2;       // Pitch radius at big end
    bevel_cone_distance = bevel_pitch_radius / sin(bevel_pitch_angle); // Slant distance to cone apex
    
    // Calculate face_width so the small-end ROOT (trough) diameter equals the tube outer diameter
    // This way the tooth troughs at the top of the bevel gear meet the tube OD for a smooth transition.
    // small_end_root_radius = bevel_root_radius * (1 - face_width / cone_distance)
    // Solving for face_width:
    bevel_face_width = bevel_cone_distance * (1 - (tube_outer_diameter / 2) / bevel_root_radius);
    
    // Axial height of the bevel gear (projection of face_width onto the gear axis)
    bevel_height = bevel_face_width * cos(bevel_pitch_angle);
    
    // Small-end tip diameter (for debug output)
    small_end_tip_diameter = 2 * bevel_outer_radius * (1 - bevel_face_width / bevel_cone_distance);
    small_end_root_diameter = 2 * bevel_root_radius * (1 - bevel_face_width / bevel_cone_distance);
    
    echo(str("Bevel gear: teeth=", small_num_teeth, " mate_teeth=", bevel_mate_teeth,
             " pitch_angle=", bevel_pitch_angle, "°"));
    echo(str("  big-end OD=", 2*bevel_outer_radius, "mm  big-end root D=", 2*bevel_root_radius, "mm"));
    echo(str("  small-end tip D=", small_end_tip_diameter, "mm  small-end root D≈", small_end_root_diameter, "mm"));
    echo(str("  tube OD=", tube_outer_diameter, "mm"));
    echo(str("  face_width=", bevel_face_width, "mm  axial height=", bevel_height, "mm"));
    echo(str("  cone_distance=", bevel_cone_distance, "mm  face/cone ratio=",
             bevel_face_width/bevel_cone_distance));
    
    difference() {
        union() {
            // Main spur gear (bottom) using BOSL2
            spur_gear(
                mod=mod,
                teeth=num_teeth,
                thickness=thickness,
                pressure_angle=gear_pressure_angle,
                clearance=gear_clearance,
                backlash=0.1,
                shaft_diam=0,
                anchor=BOT
            );
            
            // Straight bevel gear on top of the spur gear
            // Big end (wider) sits on the spur gear; small end (narrower) faces up
            translate([0, 0, thickness])
                bevel_gear(
                    mod=small_mod,
                    teeth=small_num_teeth,
                    mate_teeth=bevel_mate_teeth,
                    face_width=bevel_face_width,
                    pressure_angle=gear_pressure_angle,
                    clearance=gear_clearance,
                    backlash=0.1,
                    spiral=0,         // STRAIGHT bevel – no spiral or hypoid
                    cutter_radius=0,  // Must be 0 for truly straight teeth
                    shaft_diam=0,
                    anchor=BOT
                );
            
            // Rod holding tube extending from center above the bevel gear
            // Starts where the small end of the bevel gear ends – diameters match
            translate([0, 0, thickness + bevel_height])
                cylinder(h = tube_height, d = tube_outer_diameter, center = false);
        }
        
        // Remove material between hub and main spur gear teeth (leaving spokes)
        if (gear_pitch_diameter > hub_diameter + 20) {
            cutout_outer_radius = (gear_pitch_diameter / 2) * 0.85;
            
            difference() {
                translate([0, 0, -0.5])
                    linear_extrude(height = thickness + 1)
                        difference() {
                            circle(d = cutout_outer_radius * 2);
                            circle(d = hub_diameter);
                        }
                
                // Add back spokes
                for (i = [0:num_spokes-1]) {
                    rotate([0, 0, i * 360 / num_spokes])
                        translate([-spoke_width/2, 0, -1])
                            cube([spoke_width, cutout_outer_radius, thickness + 3]);
                }
            }
        }
        
        // Central hole for the rod (goes all the way through)
        translate([0, 0, -1])
            cylinder(h = thickness + bevel_height + tube_height + 2, d = rod_hole_diameter_loose, center = false); // Loose to allow easy rotation arround the rod (with help of bearing)
        
        // Set screw hole 1 (at 0 degrees) - in the tube section
        //translate([0, 0, thickness + bevel_height + tube_height / 2]) { set screw location in extruding tube.
        translate([0, 0, thickness / 2]) { // set screw location in hub.
            rotate([0, 90, 0]) {
                cylinder(h = set_screw_depth, d = bearing_tube_screw_hole_diameter, center = false);
            }
        }
        
        // Set screw hole 2 (at 180 degrees) - in the tube section
        //translate([0, 0, thickness + bevel_height + tube_height / 2]) { set screw location in extruding tube.
        translate([0, 0, thickness / 2]) { // set screw location in hub.
            rotate([0, -90, 0]) {
                cylinder(h = set_screw_depth, d = bearing_tube_screw_hole_diameter, center = false);
            }
        }
        
        if (place_bearing_at_compound_gear_base) {
            // Bearing pocket recessed into the base of the gear (same as holder exterior placement)
            translate([0, 0, -0.1]) {
                cylinder(h = bearing_tube_height + 0.1, d = bearing_outer_diameter, center = false);
            }
            
            // Ring cutout for bearing area (gap between bearing inner race and gear body)
            translate([0, 0, bearing_tube_height - 1]) {
                difference() {
                    cylinder(h = ring_cutout_depth + 1, d = ring_cutout_outer_diameter, center = false);
                    cylinder(h = ring_cutout_depth + 1, d = ring_cutout_inner_diameter, center = false);
                }
            }
        }
    }
}

// Module to create the mating (larger) straight bevel gear that meshes with the
// compound gear's bevel pinion at 90 degrees.  Has its own rod-holding tube,
// set screws, and optional bearing pocket.
module mating_bevel_gear(mod, num_teeth, mate_teeth, pinion_face_width) {
    // Parameters for the rod holding tube
    tube_outer_diameter = gear_rod_hole_diameter_snug + (6 * 2);  // Same tube spec as other gears
    tube_height = 10;
    set_screw_depth = tube_outer_diameter / 2 + 2;
    
    // --- Bevel gear geometry ---
    // For a 90° shaft angle, this gear's pitch_angle = atan2(num_teeth, mate_teeth)
    bevel_pitch_angle = atan2(num_teeth, mate_teeth);
    bevel_pitch_radius = mod * num_teeth / 2;
    bevel_outer_radius = mod * (num_teeth + 2) / 2;
    bevel_root_radius = mod * (num_teeth - 2.5) / 2;
    bevel_cone_distance = bevel_pitch_radius / sin(bevel_pitch_angle);
    
    // Use the same face_width as the pinion so the teeth match
    bevel_face_width = pinion_face_width;
    
    // Axial height of this bevel gear
    bevel_height = bevel_face_width * cos(bevel_pitch_angle);
    
    // Small-end diameters
    small_end_tip_diameter = 2 * bevel_outer_radius * (1 - bevel_face_width / bevel_cone_distance);
    small_end_root_diameter = 2 * bevel_root_radius * (1 - bevel_face_width / bevel_cone_distance);
    
    echo(str("Mating bevel gear: teeth=", num_teeth, " mate_teeth=", mate_teeth,
             " pitch_angle=", bevel_pitch_angle, "°"));
    echo(str("  big-end OD=", 2*bevel_outer_radius, "mm  root D=", 2*bevel_root_radius, "mm"));
    echo(str("  small-end tip D=", small_end_tip_diameter, "mm  root D=", small_end_root_diameter, "mm"));
    // Flange at the big end to house the bearing pocket (same thickness as other gear flanges)
    flange_height = gear_thickness / 1.5;  // Match the spur gear / flange thickness used elsewhere
    flange_diameter = 2 * bevel_root_radius + 5;  // Match the big-end root circle of the bevel gear
    
    echo(str("  face_width=", bevel_face_width, "mm  axial height=", bevel_height, "mm"));
    echo(str("  cone_distance=", bevel_cone_distance, "mm"));
    echo(str("  flange_height=", flange_height, "mm  flange_diameter=", flange_diameter, "mm"));
    
    difference() {
        union() {
            // Solid flange disc at the big end (bottom) – provides material for bearing pocket
            cylinder(h = flange_height, d = flange_diameter, center = false);
            
            // Straight bevel gear body sitting on top of the flange
            translate([0, 0, flange_height])
                bevel_gear(
                    mod=mod,
                    teeth=num_teeth,
                    mate_teeth=mate_teeth,
                    face_width=bevel_face_width,
                    pressure_angle=gear_pressure_angle,
                    clearance=gear_clearance,
                    backlash=0.1,
                    spiral=0,
                    cutter_radius=0,
                    shaft_diam=0,
                    anchor=BOT
                );
            
            // Rod holding tube extending from the small end (top)
            translate([0, 0, flange_height + bevel_height])
                cylinder(h = tube_height, d = tube_outer_diameter, center = false);
        }
        
        // Central hole for the rod (all the way through)
        translate([0, 0, -1])
            cylinder(h = flange_height + bevel_height + tube_height + 2, d = gear_rod_hole_diameter_snug, center = false);
        
        // Set screw hole 1 (at 0 degrees) - in the tube section
        translate([0, 0, flange_height + bevel_height + (tube_height / 2) + 1]) {
            rotate([0, 90, 0]) {
                cylinder(h = set_screw_depth, d = bearing_tube_screw_hole_diameter, center = false);
            }
        }
        
        // Set screw hole 2 (at 180 degrees) - in the tube section
        translate([0, 0, flange_height + bevel_height + (tube_height / 2) + 1]) {
            rotate([0, -90, 0]) {
                cylinder(h = set_screw_depth, d = bearing_tube_screw_hole_diameter, center = false);
            }
        }
        
        // // Bearing pocket recessed into the big-end (bottom) face of the bevel gear
        // translate([0, 0, -0.1]) {
        //     cylinder(h = bearing_tube_height + 0.1, d = bearing_outer_diameter, center = false);
        // }
        
        // // Ring cutout for bearing area (gap between bearing inner race and gear body)
        // translate([0, 0, bearing_tube_height - 1]) {
        //     difference() {
        //         cylinder(h = ring_cutout_depth + 1, d = ring_cutout_outer_diameter, center = false);
        //         cylinder(h = ring_cutout_depth + 1, d = ring_cutout_inner_diameter, center = false);
        //     }
        // }
        
        // "Drain" holes (same layout/offsets as main filter holder plug geometry)
        for (i = [0:drain_hole_count-1]) {
            angle = i * 360 / drain_hole_count;
            rotate([0, 0, angle]) {
                translate([drain_hole_circle_radius, 0, -1]) {
                    cylinder(h = flange_height + bevel_height + tube_height + 2, d = drain_hole_diameter, center = false);
                }
            }
        }
    }
}

// Module to create the part
module filter_holder() {
    // Use difference() to create the central hole by subtracting a cylinder
    difference() {
        // Main body of the piece
        union() {
            // 1a. Bottom flange section with gear teeth (Z=0 to gear_thickness)
            cylinder(h = gear_thickness, d = flange_diameter, center = false);
            
            // 1b. Involute gear teeth on the bottom section (using BOSL2)
            // Teeth extend up into the chamfer zone so their tops aren't exposed
            gear_teeth_ring(gear_mod, gear_num_teeth, gear_thickness + flange_chamfer_height, flange_diameter);

            // 1c. Upper plain flange section - diameter extends to gear tooth tips
            // Bottom outer edge is chamfered at 22.5° for support-free 3D printing
            translate([0, 0, gear_thickness]) {
                // Chamfer cone at bottom (transitions from flange_diameter up to gear_outer_diameter)
                cylinder(h = flange_chamfer_height, d1 = flange_diameter, d2 = gear_outer_diameter, center = false);
                // Remaining straight cylinder above chamfer
                translate([0, 0, flange_chamfer_height]) {
                    cylinder(h = flange_thickness - flange_chamfer_height, d = gear_outer_diameter, center = false);
                }
            }

            // 2. The slightly tapered plug that goes into the filter
            // It's positioned on top of both flange sections
            translate([0, 0, flange_total_thickness]) {
                cylinder(h = plug_length, d1 = plug_minor_diameter, d2 = plug_major_diameter, center = false);
            }
            
            if (place_bearing_at_holder_interior) {
                // 3. Bearing holder tube extension at the end of the plug
                translate([0, 0, flange_total_thickness + plug_length]) {
                    cylinder(h = bearing_tube_height, d = bearing_tube_outer_diameter, center = false);
                }
            }
        }

        // 4. The central hole for the rod
        // This cylinder is slightly taller to ensure a clean cut through the entire piece
        // It's translated down slightly to start before the main body begins
        translate([0, 0, -1]) {
            cylinder(h = flange_total_thickness + plug_length + 2, d = rod_hole_diameter_loose, center = false);
        }
        
        if (place_bearing_at_holder_interior) {
            // 5. Bearing pocket at the top of the extension tube (open at top for bearing insertion)
            translate([0, 0, flange_total_thickness + plug_length]) {
                cylinder(h = bearing_tube_height + 0.1, d = bearing_outer_diameter, center = false);
            }
        }
        
        if (place_bearing_at_holder_exterior) {
            // 5b. Bottom bearing pocket - recessed into bottom of flange, flush with bottom surface
            // Pocket goes UP into the flange from the bottom
            translate([0, 0, -0.1]) {
                cylinder(h = bearing_tube_height + 0.1, d = bearing_outer_diameter, center = false);
            }
        }
        
        if (place_bearing_at_holder_interior) {
            // 6. Ring cutout inside bearing area (gap between bearing inner race and plug)
            translate([0, 0, flange_total_thickness + plug_length - ring_cutout_depth]) {
                difference() {
                    cylinder(h = ring_cutout_depth + 1, d = ring_cutout_outer_diameter, center = false); // Adding 1mm to cut cylinder height to make rendering look cleaner while editing.
                    cylinder(h = ring_cutout_depth + 1, d = ring_cutout_inner_diameter, center = false); // Adding 1mm to cut cylinder height to make rendering look cleaner while editing.
                }
            }
        }
        
        if (place_bearing_at_holder_exterior) {
            // 6b. Ring cutout for bottom bearing area (gap between bearing inner race and flange)
            translate([0, 0, bearing_tube_height - 1]) { // Adding 1mm to cut cylinder height to make rendering look cleaner while editing.
                difference() {
                    cylinder(h = ring_cutout_depth + 1, d = ring_cutout_outer_diameter, center = false); // Adding 1mm to cut cylinder height to make rendering look cleaner while editing.
                    cylinder(h = ring_cutout_depth + 1, d = ring_cutout_inner_diameter, center = false); // Adding 1mm to cut cylinder height to make rendering look cleaner while editing.
                }
            }
        }
        
        // 7. Drain holes around the flange
        // These holes are positioned at the plug diameter and go through both flange and plug
        for (i = [0:drain_hole_count-1]) {
            angle = i * 360 / drain_hole_count;
            rotate([0, 0, angle]) {
                translate([drain_hole_circle_radius, 0, -1]) {
                    cylinder(h = total_length + 2, d = drain_hole_diameter, center = false);
                }
            }
        }
        
        // 8. Screw holes through bearing holder walls
        translate([0, 0, flange_total_thickness + plug_length + bearing_tube_height / 2]) {
            rotate([0, 90, 0]) {
                cylinder(h = bearing_tube_outer_diameter + 2, d = bearing_tube_screw_hole_diameter, center = true);
            }
        }
    }
}

if (build_pool_filter_holder) {
    //--- Render the parts
    // Original filter holder with gear
    filter_holder();
}

if (build_connecting_gear) {
    // Larger gear (2.25x size) positioned next to the filter holder
    // For proper meshing, both gears must have the same module (mod)
    //connecting_gear_teeth = gear_num_teeth * 2.25;  // 90 teeth
    connecting_gear_teeth = gear_num_teeth;
    connecting_gear_pitch_diameter = gear_mod * connecting_gear_teeth;  // mod * teeth = pitch diameter
    translate([flange_diameter/2 + connecting_gear_pitch_diameter/2 + 15, 0, 0])
        simple_gear(gear_mod, connecting_gear_teeth, gear_thickness);
}

compound_small_num_teeth = 18;                  // Teeth on the bevel pinion (needs enough teeth so root radius >> tube radius)
compound_bevel_mate_teeth = gear_num_teeth;     // Teeth on the mating (larger) bevel gear
compound_small_mod = gear_mod;                  // Same module so teeth mesh properly

connecting_gear_teeth = gear_num_teeth;
connecting_gear_pitch_diameter = gear_mod * connecting_gear_teeth;

// Position: offset from the simple_gear by the sum of pitch radii + clearance
simple_gear_x = flange_diameter/2 + connecting_gear_pitch_diameter/2 + 15;
//compound_gear_x = simple_gear_x + connecting_gear_pitch_diameter/2 + connecting_gear_pitch_diameter/2 + 15;
compound_gear_x = connecting_gear_pitch_diameter/2 + connecting_gear_pitch_diameter/2 + 15;

if (build_compound_gear) {
    // Compound gear: spur gear on bottom + straight bevel gear on top for 90° direction change
    // The bevel pinion meshes with a larger mating bevel gear whose axis is perpendicular.
    // Positioned offset from the simple_gear along the X axis
    
    translate([compound_gear_x, 0, 0])
        compound_gear(gear_mod, connecting_gear_teeth, gear_thickness,
                      compound_small_num_teeth, compound_small_mod, compound_bevel_mate_teeth);
}

if (build_mating_bevel_gear) {
    // --- Calculate meshing position for the mating bevel gear ---
    // Pinion bevel parameters (must match compound_gear calculations)
    pinion_pitch_angle = atan2(compound_small_num_teeth, compound_bevel_mate_teeth);
    pinion_pitch_radius = compound_small_mod * compound_small_num_teeth / 2;
    pinion_root_radius = compound_small_mod * (compound_small_num_teeth - 2.5) / 2;
    pinion_cone_distance = pinion_pitch_radius / sin(pinion_pitch_angle);
    pinion_face_width = pinion_cone_distance * (1 - ((gear_rod_hole_diameter_snug + 12) / 2) / pinion_root_radius);
    pinion_height = pinion_face_width * cos(pinion_pitch_angle);
    
    // Mating gear pitch parameters
    mate_pitch_angle = atan2(compound_bevel_mate_teeth, compound_small_num_teeth);
    mate_pitch_radius = compound_small_mod * compound_bevel_mate_teeth / 2;
    
    // The bevel pinion sits at Z = gear_thickness on the compound gear.
    // Its big end is at the bottom (Z = gear_thickness), small end at top.
    // The pitch cone apex for both gears is at the same point.
    // Apex is at Z = gear_thickness + pinion_pitch_radius / tan(pinion_pitch_angle)
    //            = gear_thickness + pinion_cone_distance * cos(pinion_pitch_angle)
    apex_z = gear_thickness + pinion_cone_distance * cos(pinion_pitch_angle);
    
    // The mating gear's axis is perpendicular (along Y).
    // Its big end faces toward the compound gear, apex at the same point.
    // After rotate([90,0,0]) the gear's local Z axis becomes world -Y,
    // so the gear extends in the -Y direction from its origin.
    // We need to offset in +Y so the mating gear's apex coincides with
    // the pinion's apex. The mating gear's axial height from big-end to
    // apex is: mate_cone_distance * cos(mate_pitch_angle).
    mate_cone_distance = mate_pitch_radius / sin(mate_pitch_angle);
    mate_axial_height = mate_cone_distance * cos(mate_pitch_angle);
    
    // Add pitchoff correction: BOSL2 anchor=BOT includes the dedendum offset
    // from the pitch cone, so the gear origin is slightly below the pitch base.
    mate_pitchoff = (mate_pitch_radius - compound_small_mod * (compound_bevel_mate_teeth - 2.5) / 2) * sin(mate_pitch_angle);
    
    // Account for the flange added below the bevel gear (same as gear_thickness)
    mate_flange_height = gear_thickness / 1.5; // Match the flange height used in the mating bevel gear
    
    translate([compound_gear_x, mate_axial_height + mate_pitchoff + mate_flange_height, apex_z])
        rotate([90, 0, 0])  // Rotate so mating gear axis points along -Y
            mating_bevel_gear(compound_small_mod, compound_bevel_mate_teeth,
                                compound_small_num_teeth, pinion_face_width);
}