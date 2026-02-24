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
build_connecting_gear = true; // Whether to build the gear that meshes with the flange gear
build_compound_gear = true; // Whether to build the compound gear (same size gear + smaller gear for ratio change)

place_bearing_at_holder_interior = false;
place_bearing_at_holder_exterior = true;

place_bearing_at_simple_gear_base = true;   // Whether to place a bearing pocket at the base of the simple gear
place_bearing_at_compound_gear_base = true; // Whether to place a bearing pocket at the base of the compound gear

// Plug that fits inside the filter
plug_major_diameter = 76.2; // Tapers from this diameter (76.2 mm == 3.0 inches)
plug_minor_diameter = 76.2; // To this diameter for a snug fit (76.2 mm == 3.0 inches)
plug_length = 16; // How far it goes into the filter

// Flange that stays outside the filter
flange_diameter = 105;
flange_thickness = 10;

// Central hole for the support rod
rod_diameter = 19.05;   // (19.05 mm == 0.75 inches)
rod_clearance = 2.55;   // Small clearance so bearing inner diameter contacts rod, not this holder assembly
rod_hole_diameter = rod_diameter + rod_clearance;
total_length = plug_length + flange_thickness; // Total length of the piece

// Rod specifications for simple gear
gear_rod_clearance = 0.5;         // Clearance for easy insertion
gear_rod_hole_diameter = rod_diameter + gear_rod_clearance;

// Drain holes around the flange
drain_hole_diameter = 17;
drain_hole_count = 7; // Number of holes around the flange
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
ring_cutout_inner_diameter = rod_hole_diameter + 2 * ring_cutout_gap_from_rod_hole; // Inner diameter of ring cutout
ring_cutout_outer_diameter = ring_cutout_inner_diameter + 2 * ring_cutout_radial_thickness; // Outer diameter of ring cutout

// Gear teeth parameters (using BOSL2 involute gears)
gear_num_teeth = 40;          // Number of teeth around the flange
gear_mod = 2.8;               // Gear module (controls tooth size) - mod = pitch_diameter / teeth
gear_pressure_angle = 20;     // Standard pressure angle for involute gears
gear_thickness = 10; // Thickness of the gear teeth (same as flange thickness for a flush fit)
gear_clearance = 0.2;         // Clearance for gear meshing
// Calculated: pitch_diameter = mod * teeth = 2.8 * 40 = 112mm

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
    tube_outer_diameter = gear_rod_hole_diameter + (6 * 2);  // Outer diameter of tube // TODO: Parameterize wall thickness
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
            cylinder(h = thickness + tube_height + 2, d = gear_rod_hole_diameter, center = false);
        
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

// Module to create a compound gear: same-size gear on top with a smaller gear
// around the shaft below for driving another gear at a different ratio.
module compound_gear(mod, num_teeth, thickness, small_num_teeth, small_mod, small_thickness) {
    // Parameters for the rod holding tube
    tube_outer_diameter = gear_rod_hole_diameter + (6 * 2);  // Outer diameter of tube
    tube_height = 30;          // Height of the tube
    set_screw_depth = tube_outer_diameter / 2 + 2; // Depth of screw hole
    
    // Material saving parameters - create hollow center with spokes
    //hub_diameter = small_mod * (small_num_teeth + 2) + 2;  // Extends to the outer diameter of the small gear teeth
    hub_diameter = bearing_outer_diameter + thickness * 1.2;
    
    gear_pitch_diameter = (mod * num_teeth) - 5;  // Calculated pitch diameter of the gear
    spoke_width = 10;  // Width of spokes connecting hub to gear teeth
    num_spokes = 6;   // Number of spokes for support
    
    // Small gear parameters
    small_pitch_diameter = small_mod * small_num_teeth;
    
    difference() {
        union() {
            // Main gear (same as simple_gear) using BOSL2
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
            
            // Smaller gear around the shaft, positioned below the main gear
            translate([0, 0, thickness])
                spur_gear(
                    mod=small_mod,
                    teeth=small_num_teeth,
                    thickness=small_thickness,
                    pressure_angle=gear_pressure_angle,
                    clearance=gear_clearance,
                    backlash=0.1,
                    shaft_diam=0,
                    anchor=BOT
                );
            
            // Rod holding tube extending from center above the small gear
            translate([0, 0, thickness + small_thickness])
                cylinder(h = tube_height, d = tube_outer_diameter, center = false);
        }
        
        // Remove material between hub and main gear teeth (leaving spokes)
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
            cylinder(h = thickness + small_thickness + tube_height + 2, d = gear_rod_hole_diameter, center = false);
        
        // Set screw hole 1 (at 0 degrees) - in the tube section
        translate([0, 0, thickness + small_thickness + tube_height / 2]) {
            rotate([0, 90, 0]) {
                cylinder(h = set_screw_depth, d = bearing_tube_screw_hole_diameter, center = false);
            }
        }
        
        // Set screw hole 2 (at 180 degrees) - in the tube section
        translate([0, 0, thickness + small_thickness + tube_height / 2]) {
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

// Module to create the part
module filter_holder() {
    // Use difference() to create the central hole by subtracting a cylinder
    difference() {
        // Main body of the piece
        union() {
            // 1. The outer flange (a flat disc)
            cylinder(h = flange_thickness, d = flange_diameter, center = false);
            
            // 1b. Involute gear teeth on the exterior edge (using BOSL2)
            gear_teeth_ring(gear_mod, gear_num_teeth, gear_thickness, flange_diameter);

            // 2. The tapered plug that goes into the filter
            // It's positioned on top of the flange
            translate([0, 0, flange_thickness]) {
                cylinder(h = plug_length, d1 = plug_minor_diameter, d2 = plug_major_diameter, center = false);
            }
            
            if (place_bearing_at_holder_interior) {
                // 3. Bearing holder tube extension at the end of the plug
                translate([0, 0, flange_thickness + plug_length]) {
                    cylinder(h = bearing_tube_height, d = bearing_tube_outer_diameter, center = false);
                }
            }
        }

        // 4. The central hole for the rod
        // This cylinder is slightly taller to ensure a clean cut through the entire piece
        // It's translated down slightly to start before the main body begins
        translate([0, 0, -1]) {
            cylinder(h = flange_thickness + plug_length + 2, d = rod_hole_diameter, center = false);
        }
        
        if (place_bearing_at_holder_interior) {
            // 5. Bearing pocket at the top of the extension tube (open at top for bearing insertion)
            translate([0, 0, flange_thickness + plug_length]) {
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
            translate([0, 0, flange_thickness + plug_length - ring_cutout_depth]) {
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
        translate([0, 0, flange_thickness + plug_length + bearing_tube_height / 2]) {
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

if (build_compound_gear) {
    // Compound gear: same-size main gear + smaller gear on shaft for ratio change
    // Positioned offset from the simple_gear along the X axis
    compound_small_num_teeth = 14;        // Fewer teeth for speed increase ratio
    compound_small_mod = gear_mod;         // Same module so it can mesh with standard gears
    compound_small_thickness = gear_thickness + 3; // Same thickness as main gear
    
    connecting_gear_teeth = gear_num_teeth;
    connecting_gear_pitch_diameter = gear_mod * connecting_gear_teeth;
    compound_small_pitch_diameter = compound_small_mod * compound_small_num_teeth;
    
    // Position: offset from the simple_gear by the sum of pitch radii + clearance
    simple_gear_x = flange_diameter/2 + connecting_gear_pitch_diameter/2 + 15;
    compound_gear_x = simple_gear_x + connecting_gear_pitch_diameter/2 + connecting_gear_pitch_diameter/2 + 15;
    
    translate([compound_gear_x, 0, 0])
        compound_gear(gear_mod, connecting_gear_teeth, gear_thickness,
                      compound_small_num_teeth, compound_small_mod, compound_small_thickness);
}
