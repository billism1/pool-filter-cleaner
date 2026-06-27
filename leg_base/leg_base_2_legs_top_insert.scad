// Pool Filter Cleaner - Base Holder (Top-Insert Cradle Variant)
// Open-top cradle holds 3/4" aluminum rod horizontally (for filter cylinder)
// Rod is laid in from above (+Y direction) rather than inserted end-first
// Plus two 3/4" aluminum rod legs angled down at 45 degrees, 90 degrees apart
// Creates a stable tripod support structure (use 2 of these bases, one at each end)

include <BOSL2/std.scad>
// https://github.com/BelfrySCAD/BOSL2

$fn = 180;  // Reduce to 60 for faster preview, increase to 180+ to for final render

printing_base_trim_enabled = true; // If true, use partial sweep to save material; if false, keep base fully round

// Rod specifications
rod_diameter = 19.05;        // 3/4" aluminum rod = 19.05mm
rod_clearance = 0.5;         // Clearance for easy insertion
rod_hole_diameter = rod_diameter + rod_clearance;

// Tube dimensions
tube_wall_thickness = 6;     // Thick walls for strength
tube_inner_diameter = rod_hole_diameter;
tube_outer_diameter = tube_inner_diameter + (tube_wall_thickness * 2);

// Length dimensions
horizontal_tube_length = 40;  // Length of horizontal cradle section
leg_tube_length = 47.85;         // Length of each leg tube section
leg_hole_depth = 35;          // How deep leg holes go (stops well before center)
cradle_wall_extension = 30;   // Height of cradle walls above tube centerline (mm) for top-insert rod loading
cradle_flare_height = 10;     // Height of the flared/rounded section at the top of cradle walls (mm)
cradle_flare_amount = 5;      // How far each wall flares outward at the top (mm)
cradle_snap_protrusion = 1;   // How far snap-fit ridges protrude inward from each wall (mm) to retain the rod

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
printing_base_sweep_angle = 299; // Arc from left cradle wall, through bottom (-Y), to right cradle wall
printing_base_sweep_rotation = 120.5; // Rotational start angle so arc avoids the cradle opening (+Y side)
printing_base_end_round_radius = 8; // Radius for rounding the angular ends of the partial sweep (set to 0 to disable; uses minkowski)
printing_base_total_height = printing_base_height + printing_base_taper_height + printing_base_neck_height; // Total height of the curved base

// Set screw dimensions
set_screw_diameter = 3.4;                                // Diameter of set screw holes. 3.4mm (85% of 4mm) for M4 screws, which are common and provide good holding strength.
set_screw_depth = tube_outer_diameter / 2 + 2;           // Depth of screw hole (goes halfway through + a bit)
set_screw_position = leg_tube_length - 10;               // Distance from leg origin (near the open end)
cradle_set_screw_enabled = true;                             // Whether to include cradle set screw holes
cradle_set_screw_position = horizontal_tube_length / 1.5;  // X position of cradle set screws (2/3 along cradle length)

module rod_tube(length) {
    // Simple tube to hold aluminum rod - extends in positive Z direction only
    difference() {
        cylinder(d = tube_outer_diameter, h = length, center = false);
        cylinder(d = tube_inner_diameter, h = length + 1, center = false);
    }
}

module rod_cradle(length) {
    // Open-top cradle for aluminum rod - U-shaped cross-section
    // Bottom semicircle holds the rod, walls extend upward for top-insert loading
    // Walls have rounded flared tops to guide the rod into the cradle
    // Oriented along +Z axis (same as rod_tube), to be rotated into place
    
    // Straight wall section (without flare height)
    straight_height = cradle_wall_extension - cradle_flare_height;
    
    // Main cradle body with straight walls
    linear_extrude(height = length) {
        difference() {
            union() {
                // Bottom semicircle (outer wall) - Y <= 0 half
                intersection() {
                    circle(d = tube_outer_diameter);
                    translate([0, -tube_outer_diameter / 2])
                        square([tube_outer_diameter, tube_outer_diameter], center = true);
                }
                // Left wall extending upward (straight portion)
                translate([-(tube_outer_diameter / 2), 0])
                    square([tube_wall_thickness, straight_height]);
                // Right wall extending upward (straight portion)
                translate([(tube_inner_diameter / 2), 0])
                    square([tube_wall_thickness, straight_height]);
            }
            // Inner bore - bottom semicircle only
            intersection() {
                circle(d = tube_inner_diameter);
                translate([0, -tube_outer_diameter / 2])
                    square([tube_outer_diameter, tube_outer_diameter], center = true);
            }
        }
    }    
    
    // Flared tops with rounded edges
    // Hull between bottom rectangle (wall width) and outer cylinder (rounded tip)
    // Flares outward only — inner face stays straight, outer face widens
    
    flare_top_r = tube_wall_thickness / 4;  // Small radius for smooth tapered tip
    
    // Left wall flare (flares outward in -X direction)
    hull() {
        // Bottom of flare: matches straight wall
        translate([-(tube_outer_diameter / 2), straight_height, 0])
            cube([tube_wall_thickness, 0.01, length]);
        // Top of flare: single rounded cylinder at outer edge
        translate([-(tube_outer_diameter / 2) - cradle_flare_amount + flare_top_r, straight_height + cradle_flare_height, 0])
            cylinder(r = flare_top_r, h = length);
    }
    
    // Right wall flare (flares outward in +X direction)
    hull() {
        // Bottom of flare: matches straight wall
        translate([(tube_inner_diameter / 2), straight_height, 0])
            cube([tube_wall_thickness, 0.01, length]);
        // Top of flare: single rounded cylinder at outer edge
        translate([(tube_outer_diameter / 2) + cradle_flare_amount - flare_top_r, straight_height + cradle_flare_height, 0])
            cylinder(r = flare_top_r, h = length);
    }
}

module curved_bearing_lip() {
    // Bearing lip with curved flare at the base
    // Curves at cradle connection, flat ring at bearing contact surface
    
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
    if (printing_base_trim_enabled) {
        if (printing_base_end_round_radius > 0) {
            // Round the angular "mouth" ends of the partial sweep.
            // Uses intersection of a full 360° sweep with an annular sector whose
            // outer corners are rounded via offset (fast 2D operation).
            // The sector has a small inner arc (not a sharp center point) so the
            // negative offset doesn't erode the center.
            // Sector outer radius must match the base's actual outer radius so the
            // offset-based corner rounding occurs right at the visible edge.
            _sector_r = printing_base_radius;
            _inner_r = printing_base_end_round_radius + 1; // survives the negative offset
            _sector_steps = 72;
            _inner_steps = 12;
            _step = printing_base_sweep_angle / _sector_steps;
            _inner_step = printing_base_sweep_angle / _inner_steps;
            _sector_pts = concat(
                // Inner arc (reverse direction to close polygon correctly)
                [for (i = [0:_inner_steps])
                    let(a = printing_base_sweep_rotation + printing_base_sweep_angle - i * _inner_step)
                    [_inner_r * cos(a), _inner_r * sin(a)]],
                // Outer arc
                [for (i = [0:_sector_steps])
                    let(a = printing_base_sweep_rotation + i * _step)
                    [_sector_r * cos(a), _sector_r * sin(a)]]
            );
            intersection() {
                rotate_sweep(rounded_profile, angle=360);
                linear_extrude(height = printing_base_total_height + 1)
                    offset(r = printing_base_end_round_radius)
                    offset(r = -printing_base_end_round_radius)
                    polygon(_sector_pts);
            }
        } else {
            rotate([0, 0, printing_base_sweep_rotation])
                rotate_sweep(rounded_profile, angle=printing_base_sweep_angle);
        }
    } else
        rotate_sweep(rounded_profile, angle=360);
}

module main_tube_to_base_bottom() {
    // Continuation of the cradle wall down to the curved base bottom
    drop_height = printing_base_radius - (tube_outer_diameter / 2);
    support_length = tube_outer_diameter;
    support_x = (printing_base_cutoff + printing_base_offset);

    difference() {
        // Outer skin: same axis as horizontal cradle (X-axis)
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
            // Horizontal cradle for main filter rod (extends in positive X direction only)
            // Open-top U-shape allows rod to be laid in from above (+Y)
            rotate([0, 90, 0])
                rod_cradle(horizontal_tube_length);

            // Structural cradle extending into the curved base (negative X direction).
            // Uses rod_cradle so walls extend all the way to the print bed surface.
            rotate([0, 90, 0])
                translate([0, 0, -printing_base_total_height])
                rod_cradle(printing_base_total_height);

            // Continue main tube structure down to the bottom of the printing base
            main_tube_to_base_bottom();
            
            // Bearing lip with curved flare at the end of the horizontal cradle
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
            // Fillet for horizontal cradle - Leg 1 junction
            hull() {
                rotate([0, 90, 0])
                    cylinder(d = tube_outer_diameter * 0.9, h = 0.1, center = false);
                rotate([90 + leg_angle, inward_tilt_angle, 0])
                    cylinder(d = tube_outer_diameter * 0.9, h = 0.1, center = false);
            }
            
            // Fillet for horizontal cradle - Leg 2 junction
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
        
        // Negative geometry: bores, channels, and screw holes
        
        // Bearing lip hole - cuts through entire lip including flare
        rotate([0, 90, 0])
            translate([0, 0, horizontal_tube_length - 0.1])
            cylinder(d = bearing_lip_id, h = bearing_lip_extension + bearing_lip_flare_length + 1, center = false);

        // Horizontal bore cleanup - clears fillet/structural remnants from inside the cradle
        rotate([0, 90, 0])
            translate([0, 0, -(printing_base_total_height + 1)])
            cylinder(d = tube_inner_diameter, h = horizontal_tube_length + printing_base_total_height + 2, center = false);

        // Cradle channel cut - opens the +Y (functional top) of all horizontal geometry
        // Cuts through horizontal tube, bearing lip, base bridge, base neck, and fillets
        // Only extends up to the straight wall height - the flared section above is self-opening
        translate([printing_base_cutoff + printing_base_offset - 1, 0, -rod_hole_diameter / 2])
            cube([
                horizontal_tube_length + bearing_lip_flare_length + bearing_lip_extension - (printing_base_cutoff + printing_base_offset) + 2,
                cradle_wall_extension - cradle_flare_height,
                rod_hole_diameter
            ]);
        
        // Flare-zone channel cut - wider gap matching the flared wall profile
        // Tapers from rod_hole_diameter at the straight/flare boundary to full flared width at top
        hull() {
            // Bottom of flare zone: rod_hole_diameter wide
            translate([printing_base_cutoff + printing_base_offset - 1, cradle_wall_extension - cradle_flare_height, -rod_hole_diameter / 2])
                cube([
                    horizontal_tube_length + bearing_lip_flare_length + bearing_lip_extension - (printing_base_cutoff + printing_base_offset) + 2,
                    0.01,
                    rod_hole_diameter
                ]);
            // Top of flare zone: wider by 2 * cradle_flare_amount
            translate([printing_base_cutoff + printing_base_offset - 1, cradle_wall_extension, -(rod_hole_diameter / 2 + cradle_flare_amount)])
                cube([
                    horizontal_tube_length + bearing_lip_flare_length + bearing_lip_extension - (printing_base_cutoff + printing_base_offset) + 2,
                    0.01,
                    rod_hole_diameter + cradle_flare_amount * 2
                ]);
        }
        
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
        
        // Cradle set screw holes - horizontal along Z axis, at tube centerline (Y=0)
        if (cradle_set_screw_enabled) {
            // Left wall: drills inward from -Z side
            translate([cradle_set_screw_position, 0, -(tube_outer_diameter / 2 + 1)])
                cylinder(d = set_screw_diameter, h = set_screw_depth, center = false);
            // Right wall: drills inward from +Z side
            translate([cradle_set_screw_position, 0, (tube_outer_diameter / 2 + 1)])
                rotate([180, 0, 0])
                cylinder(d = set_screw_diameter, h = set_screw_depth, center = false);
        }
        
        // Flat printing base cutout, but preserve the main-tube downward continuation
        // and the cradle walls extending to the print bed surface
        difference() {
            translate([printing_base_cutoff - 55, 0, 0])
                cube([100, 200, 200], center = true);
            main_tube_to_base_bottom();
            // Preserve cradle walls through the cutoff region (including flare + rounded top)
            // Left wall with outward-only flare
            hull() {
                translate([printing_base_cutoff + printing_base_offset, 0, -(tube_outer_diameter / 2)])
                    cube([-(printing_base_cutoff + printing_base_offset), cradle_wall_extension - cradle_flare_height, tube_wall_thickness]);
                translate([printing_base_cutoff + printing_base_offset, cradle_wall_extension, -(tube_outer_diameter / 2) - cradle_flare_amount + tube_wall_thickness / 4])
                    rotate([0, 90, 0])
                    cylinder(r = tube_wall_thickness / 4, h = -(printing_base_cutoff + printing_base_offset));
            }
            // Right wall with outward-only flare
            hull() {
                translate([printing_base_cutoff + printing_base_offset, 0, (tube_inner_diameter / 2)])
                    cube([-(printing_base_cutoff + printing_base_offset), cradle_wall_extension - cradle_flare_height, tube_wall_thickness]);
                translate([printing_base_cutoff + printing_base_offset, cradle_wall_extension, (tube_outer_diameter / 2) + cradle_flare_amount - tube_wall_thickness / 4])
                    rotate([0, 90, 0])
                    cylinder(r = tube_wall_thickness / 4, h = -(printing_base_cutoff + printing_base_offset));
            }
        }
    }
    
    // Add curved printing base with hole through it
    difference() {
        // Rotate 90 degrees and position at the back of the filter holder
        translate([printing_base_cutoff + printing_base_offset, 0, 0])
            rotate([0, 90, 0])
            curved_printing_base();
        
        // Cradle channel cut through curved base - opens the +Y top for rod access
        translate([printing_base_cutoff + printing_base_offset - 1, 0, -rod_hole_diameter / 2])
            cube([
                printing_base_total_height + 2,
                cradle_wall_extension + tube_outer_diameter,
                rod_hole_diameter
            ]);
        
        // Bore through curved base neck - clears solid core so rod can rest in cradle
        rotate([0, 90, 0])
            translate([0, 0, -(printing_base_total_height + 1)])
            cylinder(d = tube_inner_diameter, h = printing_base_total_height + 2, center = false);
        
        // Cut clearance for leg 1 pipe through the base neck
        rotate([90 + leg_angle, inward_tilt_angle, 0])
            cylinder(d = tube_outer_diameter, h = 50, center = false);
        
        // Cut clearance for leg 2 pipe through the base neck
        rotate([0, -(90 - leg_angle), 90 - inward_tilt_angle])
            cylinder(d = tube_outer_diameter, h = 50, center = false);
    }
}

// Final render: subtract a full-length bore cylinder to clear any
// internal remnants from inside the cradle (fillets, structural overlaps, etc.)
// Then union snap-fit retention ridges on top (must be added last to survive all cuts)
union() {
    difference() {
        filter_base();
        
        // Full-length negative cylinder along the horizontal cradle axis
        rotate([0, 90, 0])
            translate([0, 0, -(printing_base_total_height + 10)])
            cylinder(d = tube_inner_diameter, h = horizontal_tube_length + printing_base_total_height + 20, center = false);
    }
    
    // Snap-fit retention ridges — positioned near the top of the tube to secure it
    // Protrude inward from each wall to prevent the rod from lifting out once seated
    // Added after all difference operations so they don't get carved away
    // Spans from print bed cutoff to end of horizontal cradle
    // Cradle set screw holes are subtracted here so they cut through the ridges too
    difference() {
        union() {
            // Left wall snap ridge — shifted into wall so only ~1/4 of cross-section protrudes into channel
            rotate([0, 90, 0])
                translate([-(tube_inner_diameter / 2 + cradle_snap_protrusion / 2), rod_diameter / 11, printing_base_cutoff + printing_base_offset])
                cylinder(r = cradle_snap_protrusion, h = horizontal_tube_length - (printing_base_cutoff + printing_base_offset));
            // Right wall snap ridge — shifted into wall so only ~1/4 of cross-section protrudes into channel
            rotate([0, 90, 0])
                translate([(tube_inner_diameter / 2 + cradle_snap_protrusion / 2), rod_diameter / 11, printing_base_cutoff + printing_base_offset])
                cylinder(r = cradle_snap_protrusion, h = horizontal_tube_length - (printing_base_cutoff + printing_base_offset));
        }
        // Cradle set screw holes — same geometry as in filter_base() to cut through snap ridges
        if (cradle_set_screw_enabled) {
            // Left wall: drills inward from -Z side
            translate([cradle_set_screw_position, 0, -(tube_outer_diameter / 2 + 1)])
                cylinder(d = set_screw_diameter, h = set_screw_depth, center = false);
            // Right wall: drills inward from +Z side
            translate([cradle_set_screw_position, 0, (tube_outer_diameter / 2 + 1)])
                rotate([180, 0, 0])
                cylinder(d = set_screw_diameter, h = set_screw_depth, center = false);
        }
    }
}

// Display specifications
echo("=== Filter Base Specifications (Top-Insert Cradle) ===");
echo(str("Rod diameter: ", rod_diameter, " mm (3/4 inch)"));
echo(str("Rod hole diameter: ", rod_hole_diameter, " mm"));
echo(str("Tube outer diameter: ", tube_outer_diameter, " mm"));
echo(str("Cradle wall extension: ", cradle_wall_extension, " mm above centerline"));
echo(str("Cradle opening gap: ", rod_hole_diameter, " mm"));
echo(str("Cradle set screw position: ", cradle_set_screw_position, " mm along X"));
echo(str("Leg angle from horizontal: ", leg_angle, " degrees"));
echo(str("Legs are 90 degrees apart from each other"));
echo("Print TWO of these bases - one for each end of the filter rod");
