// Pool Filter Cleaner - Leg Foot
// Attaches to the ends of the 3/4" aluminum rod legs from the leg_base
// Provides stable contact with the ground

include <BOSL2/std.scad>
// https://github.com/BelfrySCAD/BOSL2

$fn = 180;  // Reduce to 60 for faster preview, increase to 180+ for final render

// Rod specifications (must match leg_base.scad)
rod_diameter = 19.05;        // 3/4" aluminum rod = 19.05mm
rod_clearance = 0.5;         // Clearance for easy insertion
rod_hole_diameter = rod_diameter + rod_clearance;

// Tube dimensions (must match leg_base.scad)
tube_wall_thickness = 6;     // Thick walls for strength
tube_inner_diameter = rod_hole_diameter;
tube_outer_diameter = tube_inner_diameter + (tube_wall_thickness * 2);

// Leg foot dimensions
pipe_length = 50;            // Length of each pipe section (45mm as specified)
base_extension = 30;         // How far the base extends from the bottom (mm)
base_thickness = 11; // Thickness of the triangular base plate
base_round_radius = 3;       // Radius for rounding edges of base

// Set screw dimensions
set_screw_diameter = 3.4;    // Diameter of set screw holes. 3.4mm (85% of 4mm) for M4 screws, which are common and provide good holding strength.
set_screw_depth = tube_outer_diameter / 2 + 2; // Depth of screw hole (goes halfway through + a bit)
set_screw_position = pipe_length - 10; // Distance from pipe bottom (near the open end)

// Leg angle from leg_base.scad (for ground contact calculation)
leg_angle = 45;              // Degrees down from horizontal

module rod_tube_closed(length) {
    // Tube to hold aluminum rod with closed bottom end
    // Bottom has double wall thickness for extra strength
    difference() {
        // Outer cylinder
        cylinder(d = tube_outer_diameter, h = length, center = false);
        
        // Inner hole (doesn't go all the way through - stops at bottom with double thickness)
        translate([0, 0, tube_wall_thickness * 2])
            cylinder(d = tube_inner_diameter, h = length, center = false);
    }
}

module curved_base() {
    // Curved base that wraps from the pipe bottom, curves along ground, and back
    // Uses variable thickness - thicker near cylinder, thinner at tip
    
    pipe_radius = tube_outer_diameter / 2;
    
    // Create a 2D profile path that curves from pipe bottom, out to ground, and back
    profile_path = [
        // Start at pipe bottom on one side
        [-pipe_radius + 2, 2, 0],
        
        // Curve down and out
        for (t = [0.1 : 0.1 : 0.9]) 
            let(
                angle = t * 90,
                x = -pipe_radius * cos(angle) - base_extension * 0.83 * sin(angle),
                y = -pipe_radius * sin(angle) - base_extension * 0.5 * sin(angle),
                z = 0
            ) [x, y, z],
        
        // Bottom tip (furthest out point)
        [0, -base_extension, 0],
        
        // Curve back up on the other side
        for (t = [0.1 : 0.1 : 0.9]) 
            let(
                angle = 90 - t * 90,
                x = pipe_radius * cos(angle) + base_extension * 0.83 * sin(angle),
                y = -pipe_radius * sin(angle) - base_extension * 0.5 * sin(angle),
                z = 0
            ) [x, y, z],
        
        // End at pipe bottom on other side
        [pipe_radius - 2, 2, 0]
    ];
    
    // Create rounded profile
    rounded_profile = round_corners(
        [for (p = profile_path) [p[0], p[1]]], 
        radius=base_round_radius
    );
    
    translate([0, 5, base_thickness / 2])
    union() {
        // Tapered top section - scales down from full size to 0.3 to create curved transition into pipe
        translate([0, 0, 0])
            linear_extrude(height = base_thickness, center = false, scale = 0.2)
            polygon(rounded_profile);

        // Full thickness bottom section - provides consistent strength and ground contact
        // Combined with tapered section above to create varied top surface that curves into pipe
        translate([0, 0, -base_thickness])
            linear_extrude(height = base_thickness, center = false)
            polygon(rounded_profile);
    }
}

module leg_foot() {
    difference() {
        union() {
            rotate([-12, 0, 0])
            //translate([0, 0, -10])
            union() {
                // Pipe 1 - extends in positive Z direction
                rod_tube_closed(pipe_length);
                
                // Pipe 2 - extends in positive Z direction, positioned at 90 degrees
                rotate([0, 0, 90])
                    rod_tube_closed(pipe_length);
                
                // Reinforcement fillet at pipe junction
                hull() {
                    cylinder(d = tube_outer_diameter * 0.9, h = 0.1, center = false);
                    rotate([0, 0, 90])
                        cylinder(d = tube_outer_diameter * 0.9, h = 0.1, center = false);
                }
            }
            
            // Curved base extending from bottom of pipe to ground
            // Rotated to sit flat and extend toward ground
            translate([0, 0, base_thickness / 2])
            curved_base();
        }
        
        // Cut out base from inside pipes so it's not visible from pipe openings
        rotate([-12, 0, 0]) {
            // Cut from Pipe 1
            translate([0, 0, tube_wall_thickness * 2])
                cylinder(d = tube_inner_diameter, h = pipe_length, center = false);
            
            // Cut from Pipe 2
            rotate([0, 0, 90])
                translate([0, 0, tube_wall_thickness * 2])
                cylinder(d = tube_inner_diameter, h = pipe_length, center = false);
        }
        
        // Set screw hole
        rotate([-12, 0, 0]) {
            rotate([0, 0, 90])
                translate([0, 0, set_screw_position])
                rotate([0, 90, 0])
                cylinder(d = set_screw_diameter, h = set_screw_depth, center = false);
        }
        
        // Cut everything below Z=0 to create flat bottom surface
        translate([0, 0, -50])
            cube([200, 200, 100], center = true);
    }
}

// Render the leg foot
leg_foot();

// Display specifications
echo("=== Leg Foot Specifications ===");
echo(str("Rod diameter: ", rod_diameter, " mm (3/4 inch)"));
echo(str("Rod hole diameter: ", rod_hole_diameter, " mm"));
echo(str("Tube outer diameter: ", tube_outer_diameter, " mm"));
echo(str("Tube inner diameter: ", tube_inner_diameter, " mm"));
echo(str("Tube wall thickness: ", tube_wall_thickness, " mm"));
echo(str("Pipe length: ", pipe_length, " mm"));
echo(str("Base extension: ", base_extension, " mm"));
echo(str("Base thickness: ", base_thickness, " mm"));
echo(str("Leg angle: ", leg_angle, " degrees from horizontal"));
echo("Bottom ends are enclosed for ground contact");
echo("Curved base extends from bottom for stable ground contact");
