// Pool Filter Cleaner - Base Holder
// Holds 3/4" aluminum rod horizontally (for filter cylinder)
// Plus two 3/4" aluminum rod legs angled down at 45 degrees, 90 degrees apart
// Creates a stable tripod support structure (use 2 of these bases, one at each end)

include <BOSL2/std.scad>
// https://github.com/BelfrySCAD/BOSL2

$fn = 180;  // Reduce to 60 for faster preview, increase to 180+ to for final render

// Horizontal hole configuration
horizontal_through_hole_both_sides = true;  // If true, rod hole goes through both sides; if false, only extends in positive X direction

// Rod specifications
rod_diameter = 19.05;        // 3/4" aluminum rod = 19.05mm
rod_clearance = 0.5;         // Clearance for easy insertion
rod_hole_diameter = rod_diameter + rod_clearance;

// Tube dimensions
tube_wall_thickness = 6;     // Thick walls for strength
tube_inner_diameter = rod_hole_diameter;
tube_outer_diameter = tube_inner_diameter + (tube_wall_thickness * 2);

// Length dimensions
horizontal_tube_length = 40;  // Length of horizontal tube section
leg_tube_length = 47.85;         // Length of each leg tube section
leg_hole_depth = 35;          // How deep leg holes go (stops well before center)

// Leg angle
leg_angle = 45;  // Degrees down from horizontal
inward_tilt_angle = 12;  // Slight inward tilt toward filter for bearing pressure

// Bearing lip dimensions
bearing_lip_extension = 2;   // How far the lip extends inward (mm)
bearing_lip_thickness = 2;   // Thickness of the bearing lip wall (mm)
bearing_lip_od = tube_inner_diameter + (bearing_lip_thickness * 2);  // Outer diameter matches tube inner diameter
bearing_lip_id = bearing_lip_od - (bearing_lip_thickness * 2);  // Inner diameter for rod clearance
bearing_lip_flare_length = 1; // Length of the curved flare section
bearing_lip_flare_amount = 1; // How much it flares outward (mm added to radius)

// Printing base configuration
printing_base_cutoff = -18;     // Where to cut (negative X) - adjusts how much is flat
printing_base_offset = -10;     // Additional offset to move curved base left/right (negative = left)

// Curved printing base dimensions
printing_base_radius = 45;      // Radius of the bottom of curved base
printing_base_neck_radius = (tube_outer_diameter / 2); // Radius of neck - matches horizontal tube
printing_base_height = 9;      // Height of the flat base part
printing_base_taper_height = 15; // Vertical distance of the concave curve
printing_base_neck_height = 6;  // Height of the straight top section
printing_base_round_radius = 4; // Radius for rounding edges of curved base
printing_base_sweep_angle = 145; // Degrees of base footprint to keep (trim full circle to reduce waste)
printing_base_sweep_rotation = 198; // Rotational alignment of sweep so footprint supports both leg tubes
printing_base_total_height = printing_base_height + printing_base_taper_height + printing_base_neck_height; // Total height of the curved base

// Set screw dimensions
set_screw_diameter = 3.4;                                // Diameter of set screw holes. 3.4mm (85% of 4mm) for M4 screws, which are common and provide good holding strength.
set_screw_depth = tube_outer_diameter / 2 + 2;           // Depth of screw hole (goes halfway through + a bit)
set_screw_position = leg_tube_length - 10;               // Distance from leg origin (near the open end)
horizontal_screw_position = horizontal_tube_length - 10; // Position for horizontal tube screw (far from legs)

module rod_tube(length) {
    // Simple tube to hold aluminum rod - extends in positive Z direction only
    difference() {
        cylinder(d = tube_outer_diameter, h = length, center = false);
        cylinder(d = tube_inner_diameter, h = length + 1, center = false);
    }
}

// Central hub removed - using curved base instead

module curved_bearing_lip() {
    // Bearing lip with curved flare at the base
    // Curves at pipe connection, flat ring at bearing contact surface
    
    lip_r = bearing_lip_od / 2;         // Radius of the bearing contact surface
    max_flare_r = tube_outer_diameter / 2 - 0.5; // Maximum flare (just under pipe outer)
    
    // Define the 2D profile path
    profile_path = [
        [0, 0],  // Center at pipe connection
        [lip_r + bearing_lip_flare_amount, 0],  // Start with flared radius at pipe
        
        // Curved flare section - contracts inward as it extends out
        for (t = [0.1 : 0.1 : 0.9]) 
            let(
                z = t * bearing_lip_flare_length,
                // Concave curve inward - stays wider longer then contracts
                r = lip_r + bearing_lip_flare_amount * pow(1-t, 2)
            ) [r, z],
        
        [lip_r, bearing_lip_flare_length],  // End of flare at normal lip radius
        [lip_r, bearing_lip_flare_length + bearing_lip_extension],  // Straight section (flat ring for bearing)
        [0, bearing_lip_flare_length + bearing_lip_extension]  // Back to center at bearing contact
    ];
    
    // Create the 3D shape
    rotate_sweep(profile_path, angle=360);
}

module curved_printing_base() {
    // Curved base geometry from curved-base.scad
    // Uses parameters defined at top of file
    
    // Define the 2D profile path - includes center points for solid top/bottom
    profile_path = [
        [0, 0],                              // Center bottom (must be x=0)
        [printing_base_radius, 0],           // Bottom outer edge
        [printing_base_radius, printing_base_height], // Top edge of base
        
        // Concave Transition (The Scoop)
        for (t = [0.1 : 0.1 : 0.9]) 
            let(
                z = printing_base_height + t * printing_base_taper_height,
                r = printing_base_neck_radius + (printing_base_radius - printing_base_neck_radius) * pow(1-t, 2)
            ) [r, z],
            
        [printing_base_neck_radius, printing_base_height + printing_base_taper_height], // Start of straight neck
        [printing_base_neck_radius, printing_base_height + printing_base_taper_height + printing_base_neck_height], // Top outer edge
        [0, printing_base_height + printing_base_taper_height + printing_base_neck_height] // Center top (must be x=0)
    ];
    
    // Round the corners and spin it
    // Set radius=0 at center points (top and bottom) to remove dimples
    // Set radius=0 at bottom outer edge for sharp corner
    // Set radius=0 at top outer edge for sharp 90-degree corner
    // Path has 15 points: [0]=center bottom, [1]=bottom outer, [2-12]=profile, [13]=top outer, [14]=center top
    radii = [for (i = [0:14]) 
        (i == 0 || i == 1 || i == 13 || i == 14) ? 0 : printing_base_round_radius]; // Sharp corners at bottom and top
    
    rounded_profile = round_corners(profile_path, radius=radii);
    rotate([0, 0, printing_base_sweep_rotation])
        rotate_sweep(rounded_profile, angle=printing_base_sweep_angle);
}

module main_tube_to_base_bottom() {
    // Continuation of the main tube wall down to the curved base bottom
    drop_height = printing_base_radius - (tube_outer_diameter / 2);
    support_length = tube_outer_diameter;
    support_x = (printing_base_cutoff + printing_base_offset);

    difference() {
        // Outer skin: same axis as horizontal tube (X-axis)
        hull() {
            rotate([0, 90, 0])
                translate([0, 0, support_x])
                cylinder(d = tube_outer_diameter, h = support_length, center = false);
        }

        // Inner bore continuation
        hull() {
            rotate([0, 90, 0])
                translate([0, 0, support_x + tube_wall_thickness])
                cylinder(d = tube_inner_diameter, h = support_length + 0.2, center = false);
        }
    }
}

module filter_base() {
    difference() {
        union() {
            // Horizontal tube for main filter rod (extends in positive X direction only)
            rotate([0, 90, 0])
                rod_tube(horizontal_tube_length);

            // Add another tube for the portion of the rod that extends into the curved base (extends in negative X direction).
            // This allows a quick and dirty/easy way to apply a "difference" to cut the rod hole through the curved base without affecting the horizontal tube.
            rotate([0, 90, 0])
                translate([0, 0, -printing_base_total_height])
                if (horizontal_through_hole_both_sides)
                    rod_tube(printing_base_total_height);
                else
                    cylinder(d = tube_outer_diameter, h = printing_base_total_height, center = false);

            // Continue main tube structure down to the bottom of the printing base
            main_tube_to_base_bottom();
            
            // Bearing lip with curved flare extending into horizontal tube
            rotate([0, 90, 0])
                translate([0, 0, horizontal_tube_length])
                curved_bearing_lip();
            
            // Leg 1: Angled down at 45 degrees with slight inward tilt toward filter
            rotate([90 + leg_angle, inward_tilt_angle, 0])
                rod_tube(leg_tube_length);
            
            // Leg 2: Angled down at 45 degrees, 90 degrees from Leg 1, with slight inward tilt toward filter
            rotate([0, -(90 - leg_angle), 90 - inward_tilt_angle])
                rod_tube(leg_tube_length);
            
            // Reinforcement fillets at tube junctions
            // Fillet for horizontal tube - Leg 1 junction
            hull() {
                rotate([0, 90, 0])
                    cylinder(d = tube_outer_diameter * 0.9, h = 0.1, center = false);
                rotate([90 + leg_angle, inward_tilt_angle, 0])
                    cylinder(d = tube_outer_diameter * 0.9, h = 0.1, center = false);
            }
            
            // Fillet for horizontal tube - Leg 2 junction
            hull() {
                rotate([0, 90, 0])
                    cylinder(d = tube_outer_diameter * 0.9, h = 0.1, center = false);
                rotate([0, -(90 - leg_angle), 90 - inward_tilt_angle])
                    cylinder(d = tube_outer_diameter * 0.9, h = 0.1, center = false);
            }
            
            // Fillet for Leg 1 - Leg 2 junction
            hull() {
                rotate([90 + leg_angle, inward_tilt_angle, 0])
                    cylinder(d = tube_outer_diameter * 0.9, h = 0.1, center = false);
                rotate([0, -(90 - leg_angle), 90 - inward_tilt_angle])
                    cylinder(d = tube_outer_diameter * 0.9, h = 0.1, center = false);
            }
        }
        
        // Cut through holes for aluminum rods
        
        // Bearing lip hole - cuts through entire lip including flare
        rotate([0, 90, 0])
            translate([0, 0, horizontal_tube_length - 0.1])
            cylinder(d = bearing_lip_id, h = bearing_lip_extension + bearing_lip_flare_length + 1, center = false);

        // Horizontal rod hole - either through both sides, or only in positive X direction
        rotate([0, 90, 0])
            if (horizontal_through_hole_both_sides)
                translate([0, 0, -(printing_base_height + printing_base_taper_height + printing_base_neck_height + 5)])
                cylinder(d = tube_inner_diameter, h = horizontal_tube_length + printing_base_height + printing_base_taper_height + printing_base_neck_height + 20, center = false);
            else
                translate([0, 0, -0.1])
                cylinder(d = tube_inner_diameter, h = horizontal_tube_length + 0.2, center = false);
        
        // Leg 1 hole - stops well before center with flat end
        rotate([90 + leg_angle, inward_tilt_angle, 0])
            translate([0, 0, leg_tube_length - leg_hole_depth + 5])
            cylinder(d = tube_inner_diameter, h = leg_hole_depth + 1, center = false);
        
        // Leg 2 hole - stops well before center with flat end
        rotate([0, -(90 - leg_angle), 90 - inward_tilt_angle])
            translate([0, 0, leg_tube_length - leg_hole_depth + 5])
            cylinder(d = tube_inner_diameter, h = leg_hole_depth + 1, center = false);
        
        // Set screw holes for legs - perpendicular to print bed, from one side only
        // Leg 1 set screw hole - drilled from the side opposite the base
        rotate([90 + leg_angle, inward_tilt_angle, 0])
            translate([0, 0, set_screw_position])
            rotate([0, 90, 0])
            cylinder(d = set_screw_diameter, h = set_screw_depth, center = false);
        
        // Leg 2 set screw hole - drilled from the side opposite the base
        rotate([0, -(90 - leg_angle), 90 - inward_tilt_angle])
            translate([0, 0, set_screw_position])
            rotate([90, 0, 0])
            cylinder(d = set_screw_diameter, h = set_screw_depth, center = false);
        
        // Horizontal tube set screw hole - drilled from side (top when in use with legs down)
        translate([horizontal_screw_position, 0, 0])
            rotate([-90, 0, 0])
            cylinder(d = set_screw_diameter, h = set_screw_depth, center = false);
        
        // Flat printing base cutout, but preserve the main-tube downward continuation
        difference() {
            translate([printing_base_cutoff - 55, 0, 0])
                cube([100, 200, 200], center = true);
            main_tube_to_base_bottom();
        }
    }
    
    // Add curved printing base with hole through it
    difference() {
        // Rotate 90 degrees and position at the back of the filter holder
        translate([printing_base_cutoff + printing_base_offset, 0, 0])
            rotate([0, 90, 0])
            curved_printing_base();
        
        // Cut horizontal rod hole through the curved base only when through-hole is enabled
        if (horizontal_through_hole_both_sides)
            rotate([0, 90, 0])
                translate([0, 0, -(printing_base_height + printing_base_taper_height + printing_base_neck_height + 5)])
                cylinder(d = tube_inner_diameter, h = printing_base_height + printing_base_taper_height + printing_base_neck_height + 20, center = false);
        else
            rotate([0, 90, 0])
                cylinder(d = tube_inner_diameter, h = printing_base_height + printing_base_taper_height + printing_base_neck_height, center = false);
        
        // Cut clearance for leg 1 pipe through the base neck
        rotate([90 + leg_angle, inward_tilt_angle, 0])
            cylinder(d = tube_outer_diameter, h = 50, center = false);
        
        // Cut clearance for leg 2 pipe through the base neck
        rotate([0, -(90 - leg_angle), 90 - inward_tilt_angle])
            cylinder(d = tube_outer_diameter, h = 50, center = false);
    }
}

// Render the base
filter_base();

// Display specifications
echo("=== Filter Base Specifications ===");
echo(str("Rod diameter: ", rod_diameter, " mm (3/4 inch)"));
echo(str("Rod hole diameter: ", rod_hole_diameter, " mm"));
echo(str("Tube outer diameter: ", tube_outer_diameter, " mm"));
echo(str("Leg angle from horizontal: ", leg_angle, " degrees"));
echo(str("Legs are 90 degrees apart from each other"));
echo("Print TWO of these bases - one for each end of the filter rod");
