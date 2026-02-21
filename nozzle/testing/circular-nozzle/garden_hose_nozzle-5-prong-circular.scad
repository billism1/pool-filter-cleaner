// C
// 5-Outlet Garden Hose Nozzle
// Fits standard 3/4" Garden Hose Thread (GHT)
// Total outlet cross-sectional area: 11.69 mm²
// Per outlet: ~2.328 mm² (diameter ~1.72 mm)

$fn = 180;  // Reduce to 60 for faster preview, increase to 180+ to for final render

// ==========================================
// PARAMETERS
// ==========================================

// Garden Hose Thread (GHT) specifications for 3/4" hose
// Female fitting that screws onto male hose end
ght_major_diameter = 26.441;    // 1.0625" in mm - internal thread major diameter
ght_minor_diameter = 24.613;    // Thread minor diameter
ght_pitch = 2.309;              // 11 TPI = 2.309mm pitch
ght_thread_count = 4;           // Number of thread turns
ght_thread_depth = 0.914;       // Thread depth (approximate)

// Nozzle body dimensions
inlet_diameter = 18;            // Internal inlet diameter
body_length = 25;               // Length of main body section
transition_length = 20;         // Length of transition zone from inlet to outlets

// Outlet specifications (5 outlets)
num_outlets = 5;
outlet_diameter = 1.72;         // Diameter to achieve ~2.328 mm² per outlet
outlet_length = 30;             // Length of each outlet cone
outlet_base_diameter = 6;       // Base diameter where outlet meets body
outlet_spread_radius = 10;      // How far outlets spread from center
outlet_angle = 15;              // Angle of outlet cones from vertical (degrees)

// Thread fitting dimensions
thread_section_length = ght_pitch * ght_thread_count + 2;
fitting_wall_thickness = 3;
fitting_outer_diameter = ght_major_diameter + 2 * fitting_wall_thickness;

// ==========================================
// MODULES
// ==========================================

// Trapezoidal thread profile for GHT
module ght_thread_profile() {
    // Simplified trapezoidal thread cross-section
    thread_height = ght_thread_depth;
    thread_width_base = ght_pitch * 0.6;
    thread_width_top = ght_pitch * 0.4;
    
    polygon([
        [0, 0],
        [thread_height, (thread_width_base - thread_width_top) / 2],
        [thread_height, thread_width_base - (thread_width_base - thread_width_top) / 2],
        [0, thread_width_base]
    ]);
}

// Female GHT threading (internal threads to screw onto hose)
module female_ght_threads() {
    thread_start_radius = ght_major_diameter / 2;
    
    // Create helical thread
    for (i = [0 : $fn * ght_thread_count]) {
        angle = i * 360 / $fn;
        z_offset = i * ght_pitch / $fn;
        
        if (z_offset < ght_pitch * ght_thread_count) {
            rotate([0, 0, angle])
            translate([thread_start_radius - ght_thread_depth, 0, z_offset])
            rotate([90, 0, 0])
            linear_extrude(height = 0.5, center = true)
            ght_thread_profile();
        }
    }
}

// Alternative simpler thread representation
module simple_female_threads() {
    difference() {
        cylinder(d = ght_major_diameter, h = thread_section_length);
        
        // Thread grooves (simplified as helical cuts)
        for (i = [0 : ght_thread_count - 1]) {
            translate([0, 0, i * ght_pitch + 1])
            difference() {
                cylinder(d = ght_major_diameter + 1, h = ght_pitch * 0.5);
                cylinder(d = ght_major_diameter - ght_thread_depth * 2, h = ght_pitch * 0.5 + 0.1);
            }
        }
    }
}

// Threaded inlet section (female fitting to attach to hose)
module threaded_inlet() {
    difference() {
        // Outer shell
        cylinder(d = fitting_outer_diameter, h = thread_section_length);
        
        // Internal threading cavity
        translate([0, 0, -0.1])
        cylinder(d = ght_major_diameter, h = thread_section_length + 0.2);
        
        // Thread grooves (simplified representation)
        for (i = [0 : ght_thread_count]) {
            z_pos = 1.5 + i * ght_pitch;
            if (z_pos < thread_section_length - 1) {
                translate([0, 0, z_pos])
                difference() {
                    cylinder(d = ght_major_diameter + 0.2, h = ght_pitch * 0.6);
                    cylinder(d = ght_major_diameter - ght_thread_depth * 2, h = ght_pitch * 0.6 + 0.1);
                }
            }
        }
        
        // Lead-in chamfer
        translate([0, 0, -0.1])
        cylinder(d1 = ght_major_diameter + 4, d2 = ght_major_diameter, h = 2);
    }
    
    // Sealing surface / washer seat
    translate([0, 0, thread_section_length])
    difference() {
        cylinder(d = fitting_outer_diameter, h = 2);
        translate([0, 0, -0.1])
        cylinder(d = inlet_diameter, h = 2.2);
        // Chamfer for washer
        translate([0, 0, 1])
        cylinder(d1 = inlet_diameter, d2 = inlet_diameter + 2, h = 1.1);
    }
}

// Main body section
module nozzle_body() {
    body_outer_diameter = fitting_outer_diameter;
    
    translate([0, 0, thread_section_length + 2])
    difference() {
        // Outer body - tapers slightly
        cylinder(d1 = body_outer_diameter, d2 = body_outer_diameter - 4, h = body_length);
        
        // Internal cavity
        translate([0, 0, -0.1])
        cylinder(d1 = inlet_diameter, d2 = inlet_diameter + 4, h = body_length + 0.2);
    }
}

// Transition section from single inlet to multiple outlets
module transition_section() {
    start_z = thread_section_length + 2 + body_length;
    
    translate([0, 0, start_z])
    difference() {
        // Outer dome shape
        hull() {
            cylinder(d = fitting_outer_diameter - 4, h = 0.1);
            translate([0, 0, transition_length])
            cylinder(d = outlet_spread_radius * 2 + outlet_base_diameter + 4, h = 0.1);
        }
        
        // Internal cavity with channels leading to outlets
        translate([0, 0, -0.1])
        hull() {
            cylinder(d = inlet_diameter + 4, h = 0.1);
            translate([0, 0, transition_length - 5])
            for (i = [0 : num_outlets - 1]) {
                angle = i * 360 / num_outlets;
                rotate([0, 0, angle])
                translate([outlet_spread_radius, 0, 0])
                cylinder(d = outlet_base_diameter, h = 0.1);
            }
        }
    }
}

// Individual outlet cone
module outlet_cone() {
    // Cone that tapers from base diameter to outlet diameter
    difference() {
        // Outer cone
        cylinder(d1 = outlet_base_diameter + 3, d2 = outlet_diameter + 2, h = outlet_length);
        
        // Internal channel
        translate([0, 0, -0.1])
        cylinder(d1 = outlet_base_diameter, d2 = outlet_diameter, h = outlet_length + 0.2);
    }
}

// All outlet cones arranged in a pattern
module outlet_array() {
    start_z = thread_section_length + 2 + body_length + transition_length;
    
    translate([0, 0, start_z])
    for (i = [0 : num_outlets - 1]) {
        angle = i * 360 / num_outlets;
        rotate([0, 0, angle])
        translate([outlet_spread_radius, 0, 0])
        rotate([outlet_angle, 0, 0])
        outlet_cone();
    }
}

// Grip ridges on the body
module grip_ridges() {
    ridge_start = thread_section_length + 5;
    ridge_count = 12;
    ridge_height = 1.5;
    ridge_length = body_length - 6;
    
    for (i = [0 : ridge_count - 1]) {
        angle = i * 360 / ridge_count;
        rotate([0, 0, angle])
        translate([fitting_outer_diameter / 2 - 0.5, -1, ridge_start])
        cube([ridge_height, 2, ridge_length]);
    }
}

// ==========================================
// MAIN ASSEMBLY
// ==========================================

module complete_nozzle() {
    union() {
        // Threaded inlet for hose connection
        threaded_inlet();
        
        // Main body
        nozzle_body();
        
        // Transition from single inlet to multiple outlets
        transition_section();
        
        // Array of outlet cones
        outlet_array();
        
        // Grip ridges for handling
        grip_ridges();
    }
}

// Render the complete nozzle
complete_nozzle();

// ==========================================
// VERIFICATION INFO (commented out)
// ==========================================
/*
Cross-sectional area verification:
- Outlet diameter: 1.72 mm
- Area per outlet: π * (1.72/2)² = π * 0.86² = 2.324 mm²
- Total area (5 outlets): 2.324 * 5 = 11.62 mm² ≈ 11.69 mm² ✓

3/4" Garden Hose Thread (GHT) specs:
- Nominal size: 3/4"
- Threads per inch: 11.5 TPI (sometimes listed as 11 TPI)
- Major diameter: 1.0625" (26.99 mm)
- This is a female fitting designed to screw onto the male end of a garden hose
*/
