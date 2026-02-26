// Pool Filter Cleaner - Filter Holder
// This OpenSCAD script generates a part to hold a pool filter on a 0.75" diameter aluminum rod for easy cleaning.

// Key Dimensions:
// Pool filter inner hole diameter: 76.2 mm (3 inches)
// Support rod diameter: 19.05 mm (0.75 inch)

// Parameters

$fn = 180; // Number of facets for smoothness. Use 180+ for final renders, but 60 is good for quick previews.

//--- Part Dimensions (in mm)

// Plug that fits inside the filter
plug_major_diameter = 76.2; // Tapers from this diameter (76.2 mm == 3.0 inches)
plug_minor_diameter = 76.2; // To this diameter for a snug fit (76.2 mm == 3.0 inches)
plug_length = 16; // How far it goes into the filter

// Flange that stays outside the filter
flange_diameter = 135;
flange_thickness = 6;

// Central hole for the support rod
rod_diameter = 19.05;   // (19.05 mm == 0.75 inches)
rod_clearance = 2.55;   // Small clearance so bearing inner diameter contacts rod, not this holder assembly
rod_hole_diameter = rod_diameter + rod_clearance;
total_length = plug_length + flange_thickness; // Total length of the piece

// Drain holes around the flange
drain_hole_diameter = 20; // 1 inch holes
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
ring_cutout_inner_diameter = rod_hole_diameter + 2 * ring_cutout_gap_from_rod_hole; // Inner diameter of ring cutout
ring_cutout_outer_diameter = ring_cutout_inner_diameter + 2 * ring_cutout_radial_thickness; // Outer diameter of ring cutout

// Module to create the part
module filter_holder() {
    // Use difference() to create the central hole by subtracting a cylinder
    difference() {
        // Main body of the piece
        union() {
            // 1. The outer flange (a flat disc)
            cylinder(h = flange_thickness, d = flange_diameter, center = false);

            // 2. The tapered plug that goes into the filter
            // It's positioned on top of the flange
            translate([0, 0, flange_thickness]) {
                cylinder(h = plug_length, d1 = plug_minor_diameter, d2 = plug_major_diameter, center = false);
            }
            
            // 3. Bearing holder tube extension at the end of the plug
            translate([0, 0, flange_thickness + plug_length]) {
                cylinder(h = bearing_tube_height, d = bearing_tube_outer_diameter, center = false);
            }
        }

        // 4. The central hole for the rod
        // This cylinder is slightly taller to ensure a clean cut through the entire piece
        // It's translated down slightly to start before the main body begins
        translate([0, 0, -1]) {
            cylinder(h = flange_thickness + plug_length + bearing_tube_height + 2, d = rod_hole_diameter, center = false);
        }
        
        // 5. Bearing pocket at the top of the extension tube (open at top for bearing insertion)
        translate([0, 0, flange_thickness + plug_length]) {
            cylinder(h = bearing_tube_height + 0.1, d = bearing_outer_diameter, center = false);
        }
        
        // 5b. Bottom bearing pocket - recessed into bottom of flange, flush with bottom surface
        // Pocket goes UP into the flange from the bottom
        translate([0, 0, -0.1]) {
            cylinder(h = bearing_tube_height + 0.1, d = bearing_outer_diameter, center = false);
        }
        
        // 6. Ring cutout inside bearing area (gap between bearing inner race and plug)
        translate([0, 0, flange_thickness + plug_length - ring_cutout_depth]) {
            difference() {
                cylinder(h = ring_cutout_depth + 1, d = ring_cutout_outer_diameter, center = false); // Adding 1mm to cut cylinder height to make rendering look cleaner while editing.
                cylinder(h = ring_cutout_depth + 1, d = ring_cutout_inner_diameter, center = false); // Adding 1mm to cut cylinder height to make rendering look cleaner while editing.
            }
        }
        
        // 6b. Ring cutout for bottom bearing area (gap between bearing inner race and flange)
        translate([0, 0, bearing_tube_height - 1]) { // Adding 1mm to cut cylinder height to make rendering look cleaner while editing.
            difference() {
                cylinder(h = ring_cutout_depth + 1, d = ring_cutout_outer_diameter, center = false); // Adding 1mm to cut cylinder height to make rendering look cleaner while editing.
                cylinder(h = ring_cutout_depth + 1, d = ring_cutout_inner_diameter, center = false); // Adding 1mm to cut cylinder height to make rendering look cleaner while editing.
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

//--- Render the part
filter_holder();
