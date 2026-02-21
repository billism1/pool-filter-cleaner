// GHCP
// Garden Hose Nozzle - 5 Prong Fan-Out Design
// 3/4" Female Garden Hose Threading
// Total outlet area: 11.69 mm²
// 5 outlets @ 2.338 mm² each (diameter ~1.72mm)

use <Threading.scad>

// Parameters
$fn = 180;  // Reduce to 60 for faster preview, increase to 180+ to for final render

// Garden hose threading specs (3/4" GHT)
ght_pitch = 25.4 / 11.5; // 11.5 TPI = 2.209mm pitch
ght_male_od = 26.99;     // Outer diameter of male thread (standard 3/4" GHT)
ght_diameter = ght_male_od + 0.8; // Female thread diameter (add clearance)
ght_windings = 6;        // Number of thread windings
thread_angle = 60;       // Thread angle
female_outer_diameter = 38; // Outer wall of female fitting

// Nozzle dimensions
inlet_id = 19;           // Inner diameter of inlet
inlet_length = 10;       // Length of threaded section
chamber_length = 20;     // Transition chamber length
chamber_od = 35;         // Outer diameter of chamber

// Outlet specifications
outlet_diameter = 1.72;  // Target diameter for ~2.328 mm² area
outlet_length = 40;      // Length of each cone nozzle
outlet_spacing = 12;     // Spacing between outlet centers
num_outlets = 5;
transition_height = 20;  // Height of smooth transition section

// Wall thickness
wall_thickness = 3;

// Hex grip ring option
add_hex_grip = true;  // Set to false to disable hex grip ring

module main_body() {
    thread_height = (ght_windings + 0.5) * ght_pitch;
    
    difference() {
        union() {
            // Threaded inlet section
            translate([0, 0, 0])
                Threading(
                    D = female_outer_diameter, 
                    pitch = ght_pitch, 
                    d = ght_diameter, 
                    windings = ght_windings, 
                    angle = thread_angle, 
                    left = false,
                    center = false
                );
            
            // Hex grip ring around the threaded section for wrench tightening (optional)
            if (add_hex_grip) {
                difference() {
                    union() {
                        // Main hex grip body
                        translate([0, 0, 3])
                        cylinder(d = female_outer_diameter + 8, h = 8.5, $fn = 6);
                        
                        // Curved fillet transition at bottom for printability (no support needed)
                        hull() {
                            // Bottom of hex
                            translate([0, 0, 3])
                            cylinder(d = female_outer_diameter + 8, h = 0.1, $fn = 6);
                            
                            // Blend to body below
                            translate([0, 0, 0])
                            // cylinder(d = female_outer_diameter + 2, h = 0.1);
                            cylinder(d = female_outer_diameter, h = 0.1);
                        }
                        
                        // Curved fillet transition at top for printability (no support needed)
                        hull() {
                            // Top of hex
                            translate([0, 0, 11.5])
                            cylinder(d = female_outer_diameter + 8, h = 0.1, $fn = 6);
                            
                            // Blend to body above
                            translate([0, 0, 14.5])
                            // cylinder(d = female_outer_diameter + 2, h = 0.1);
                            cylinder(d = female_outer_diameter, h = 0.1);
                        }
                    }
                    translate([0, 0, -0.1])
                    cylinder(d = female_outer_diameter - 0.1, h = 15);
                }
            }
            
            // Transition chamber (expands from inlet) - starts after threading
            translate([0, 0, thread_height])
                cylinder(d1 = female_outer_diameter, 
                        d2 = chamber_od, 
                        h = inlet_length + chamber_length);
            
            // Smooth hydrodynamic transition from cylinder to cones using multi-stage hull
            // Stage 1: Transition from cylinder to elongated shape
            hull() {
                translate([0, 0, thread_height + inlet_length + chamber_length - 0.1])
                    cylinder(d = chamber_od, h = 0.1);
                
                translate([0, 0, thread_height + inlet_length + chamber_length + transition_height * 0.2])
                    scale([1.15, 1, 1])
                    sphere(d = chamber_od * 0.98, $fn = 48);
            }
            
            // Stage 2: Further elongation with rounded shape
            hull() {
                translate([0, 0, thread_height + inlet_length + chamber_length + transition_height * 0.2])
                    scale([1.15, 1, 1])
                    sphere(d = chamber_od * 0.98, $fn = 48);
                
                translate([0, 0, thread_height + inlet_length + chamber_length + transition_height * 0.4])
                    scale([1.5, 1, 1])
                    sphere(d = chamber_od * 0.92, $fn = 48);
            }
            
            // Stage 3: More elongation
            hull() {
                translate([0, 0, thread_height + inlet_length + chamber_length + transition_height * 0.4])
                    scale([1.5, 1, 1])
                    sphere(d = chamber_od * 0.92, $fn = 48);
                
                translate([0, 0, thread_height + inlet_length + chamber_length + transition_height * 0.62])
                    scale([1.9, 1, 1])
                    sphere(d = chamber_od * 0.82, $fn = 48);
            }
            
            // Stage 4: Transition to individual cone bases with rounded elements
            hull() {
                translate([0, 0, thread_height + inlet_length + chamber_length + transition_height * 0.62])
                    scale([1.9, 1, 1])
                    sphere(d = chamber_od * 0.82, $fn = 48);
                
                // Individual rounded bases
                for (i = [0:num_outlets-1]) {
                    x_pos = (i - (num_outlets-1)/2) * outlet_spacing;
                    translate([x_pos, 0, thread_height + inlet_length + chamber_length + transition_height * 0.82])
                        sphere(d = 17, $fn = 40);
                }
            }
            
            // Stage 5: Final smooth transition to cone starting points
            hull() {
                for (i = [0:num_outlets-1]) {
                    x_pos = (i - (num_outlets-1)/2) * outlet_spacing;
                    translate([x_pos, 0, thread_height + inlet_length + chamber_length + transition_height * 0.82])
                        sphere(d = 17, $fn = 40);
                }
                
                for (i = [0:num_outlets-1]) {
                    x_pos = (i - (num_outlets-1)/2) * outlet_spacing;
                    translate([x_pos, 0, thread_height + inlet_length + chamber_length + transition_height])
                        sphere(d = 15, $fn = 40);
                }
            }
        }
        
        // Hollow out the inlet passage
        translate([0, 0, -0.1])
            cylinder(d = inlet_id, h = thread_height + inlet_length + chamber_length + 0.2);
        
        // Hollow out the transition to outlets with smooth expansion for better flow
        hull() {
            translate([0, 0, thread_height + inlet_length + chamber_length - 2])
                cylinder(d = inlet_id, h = 0.1);
            
            translate([0, 0, thread_height + inlet_length + chamber_length + transition_height * 0.35])
                scale([1.2, 1, 1])
                cylinder(d = inlet_id * 0.95, h = 0.1);
        }
        
        hull() {
            translate([0, 0, thread_height + inlet_length + chamber_length + transition_height * 0.35])
                scale([1.2, 1, 1])
                cylinder(d = inlet_id * 0.95, h = 0.1);
            
            translate([0, 0, thread_height + inlet_length + chamber_length + transition_height * 0.65])
                scale([1.6, 1, 1])
                cylinder(d = inlet_id * 0.75, h = 0.1);
        }
        
        hull() {
            translate([0, 0, thread_height + inlet_length + chamber_length + transition_height * 0.65])
                scale([1.6, 1, 1])
                cylinder(d = inlet_id * 0.75, h = 0.1);
            
            // Individual hollow sections leading to each cone
            for (i = [0:num_outlets-1]) {
                x_pos = (i - (num_outlets-1)/2) * outlet_spacing;
                translate([x_pos, 0, thread_height + inlet_length + chamber_length + transition_height - 2])
                    cylinder(d = 8, h = 0.1);
            }
        }
        
        // Cut explicit openings at each cone base to ensure water flow
        for (i = [0:num_outlets-1]) {
            x_pos = (i - (num_outlets-1)/2) * outlet_spacing;
            translate([x_pos, 0, thread_height + inlet_length + chamber_length + transition_height - 3])
                cylinder(d = 8, h = 5);
        }
        
        // Additional cutouts to remove sphere blockages at cone bases
        for (i = [0:num_outlets-1]) {
            x_pos = (i - (num_outlets-1)/2) * outlet_spacing;
            // Cut through the spheres at 82% height
            translate([x_pos, 0, thread_height + inlet_length + chamber_length + transition_height * 0.82])
                cylinder(d = 9, h = transition_height * 0.2, center = false);
            // Cut through the spheres at 100% height  
            translate([x_pos, 0, thread_height + inlet_length + chamber_length + transition_height])
                cylinder(d = 9, h = transition_height * 0.71, center = false);
        }
    }
}

module outlet_nozzle(position) {
    thread_height = (ght_windings + 0.5) * ght_pitch;
    x_pos = position * outlet_spacing;
    base_diameter = 8;  // Diameter at base of cone
    
    difference() {
        union() {
            // Main cone from base to outlet tip
            translate([x_pos, 0, thread_height + inlet_length + chamber_length + transition_height])
                cylinder(d1 = base_diameter + wall_thickness*2, 
                        d2 = outlet_diameter + wall_thickness*2, 
                        h = outlet_length);
        }
        
        // Hollow cone interior - extends down into transition to connect with flow path
        translate([x_pos, 0, thread_height + inlet_length + chamber_length + transition_height - 2.1])
            cylinder(d1 = 8, 
                    d2 = outlet_diameter, 
                    h = outlet_length + 2.3);
    }
}

module five_prong_nozzle() {
    union() {
        // Main body with inlet
        main_body();
        
        // Create 5 outlet nozzles fanned out horizontally
        for (i = [0:num_outlets-1]) {
            outlet_nozzle(i - (num_outlets-1)/2);
        }
    }
}

// Render the complete nozzle
five_prong_nozzle();

// Display cross-sectional area info
echo("=== Nozzle Specifications ===");
echo(str("Outlet diameter: ", outlet_diameter, " mm"));
echo(str("Area per outlet: ", PI * pow(outlet_diameter/2, 2), " mm²"));
echo(str("Total outlet area: ", 5 * PI * pow(outlet_diameter/2, 2), " mm²"));
echo(str("Number of outlets: ", num_outlets));
