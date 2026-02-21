// Garden Hose Nozzle with 5 Outlets
// FEMALE threading to accept standard 3/4" garden hose MALE end
// Total outlet cross-sectional area: ~11.69 mm²
// Each outlet diameter: ~1.72 mm (area ~2.328 mm² each)
//
// Uses Threading.scad library by Parkinbot (Rudolf Huttary)
// Required files in same directory:
//   - Threading.scad
//   - Naca_sweep.scad

use <Threading.scad>

$fn = 180;  // Reduce to 60 for faster preview, increase to 180+ to for final render

// === GHT SPECIFICATIONS ===
// Garden Hose Thread (GHT) for FEMALE fitting
// Standard 3/4" GHT: 1.0625" (26.99mm) OD, 11.5 TPI, 60° thread angle

ght_male_od = 26.99;              // mm - outer diameter of male thread we accept
ght_pitch = 25.4 / 11.5;          // mm - thread pitch (2.209mm)
ght_thread_angle = 60;            // degrees - standard thread angle
ght_windings = 6;                 // number of thread turns

// Female fitting dimensions  
female_outer_diameter = 38;       // mm - outer wall of the female fitting
female_thread_od = ght_male_od + 0.8;  // mm - add clearance for male thread

// Inlet section
inlet_bore_diameter = 19;         // mm - inner bore after threads

// Transition section
transition_length = 25;           // mm - length of the fanning transition

// Outlet nozzles
outlet_diameter = 1.72;           // mm - each outlet (~2.328 mm² area)
num_outlets = 5;
nozzle_length = 40;               // mm - length of each cone nozzle
nozzle_base_diameter = 8;         // mm - diameter at base of each nozzle
outlet_spacing = 12;              // mm - center-to-center spacing of outlets

// Calculated value for cone positions
total_width = (num_outlets - 1) * outlet_spacing;


// === MODULES ===

// Female inlet section with internal GHT threads using Threading library
// Threading starts immediately at the inlet opening
module female_inlet_section() {
    thread_height = ght_pitch * (ght_windings + 0.5);
    
    union() {
        // Threaded section using Threading() module - starts at z=0
        Threading(
            D = female_outer_diameter,
            d = female_thread_od,
            pitch = ght_pitch,
            windings = ght_windings,
            angle = ght_thread_angle,
            edges = 64
        );
        
        // Hex grip ring around the threaded section for hand tightening
        difference() {
            cylinder(d = female_outer_diameter + 8, h = 10, $fn = 6);
            translate([0, 0, -0.1])
            cylinder(d = female_outer_diameter - 0.1, h = 10.2);
        }
        
        // Collar/transition at top of threaded section
        translate([0, 0, thread_height])
        difference() {
            cylinder(d1 = female_outer_diameter, d2 = female_outer_diameter - 4, h = 5);
            translate([0, 0, -0.1])
            cylinder(d = inlet_bore_diameter + 2, h = 5.2);
        }
    }
}

// Single cone nozzle with tapered bore (solid - bore cut separately)
module cone_nozzle_solid(base_d, tip_d, length) {
    cylinder(d1 = base_d, d2 = tip_d + 1.5, h = length);
}

// Transition body that fans out from single inlet to 5 outlets
module transition_body() {
    hull() {
        // Inlet end (circular, matches female fitting)
        cylinder(d = female_outer_diameter - 4, h = 0.1);
        
        // Outlet end (elongated to cover all nozzle bases horizontally)
        translate([0, 0, transition_length - 0.1])
        for (i = [0 : num_outlets - 1]) {
            x_pos = -total_width/2 + i * outlet_spacing;
            translate([x_pos, 0, 0])
            cylinder(d = nozzle_base_diameter, h = 0.1);
        }
    }
}

// All internal water passages - from inlet through to nozzle tips
module internal_passages() {
    // Main inlet chamber (connects to threaded section)
    cylinder(d = inlet_bore_diameter, h = 10);
    
    // Distribution chamber (widens to feed all outlets)
    hull() {
        translate([0, 0, 6])
        cylinder(d = inlet_bore_diameter - 2, h = 0.1);
        
        translate([0, 0, 14])
        scale([1.8, 0.5, 1])
        cylinder(d = inlet_bore_diameter, h = 0.1);
    }
    
    // Individual channels fanning out to each nozzle AND the nozzle bores
    for (i = [0 : num_outlets - 1]) {
        x_pos = -total_width/2 + i * outlet_spacing;
        
        // Channel from distribution to nozzle base
        hull() {
            // Start from distribution area
            translate([0, 0, 12])
            cylinder(d = 6, h = 0.1);
            
            // End at the nozzle base center
            translate([x_pos, 0, transition_length])
            cylinder(d = nozzle_base_diameter - 2, h = 0.1);
        }
        
        // Tapered bore through each nozzle cone - extends past the tip
        translate([x_pos, 0, transition_length - 0.5])
        cylinder(d1 = nozzle_base_diameter - 2, d2 = outlet_diameter, h = nozzle_length + 2);
    }
}

// Complete nozzle assembly
module garden_hose_nozzle() {
    thread_height = ght_pitch * (ght_windings + 0.5);
    base_height = thread_height + 5;  // threads + collar
    
    union() {
        // Female inlet section with internal GHT threads
        female_inlet_section();
        
        // Transition section with nozzles - all as one difference operation
        translate([0, 0, base_height])
        difference() {
            union() {
                // Transition body
                transition_body();
                
                // Five solid cone nozzles arranged horizontally
                translate([0, 0, transition_length])
                for (i = [0 : num_outlets - 1]) {
                    x_pos = -total_width/2 + i * outlet_spacing;
                    translate([x_pos, 0, 0])
                    cone_nozzle_solid(nozzle_base_diameter, outlet_diameter, nozzle_length);
                }
            }
            
            // Cut out all internal water passages
            translate([0, 0, -1])
            internal_passages();
        }
    }
}

// === RENDER ===

garden_hose_nozzle();

// === DEBUG / CROSS SECTION ===
// Uncomment to see cross-section view:
/*
difference() {
    garden_hose_nozzle();
    translate([0, -50, -1])
    cube([100, 100, 200]);
}
*/

// Uncomment to see just the threaded section:
// female_inlet_section();

// === SPECIFICATIONS ===
echo("=== NOZZLE SPECIFICATIONS ===");
echo(str("Thread type: FEMALE (internal) GHT"));
echo(str("Thread diameter: ", female_thread_od, " mm"));
echo(str("Accepts male OD: ", ght_male_od, " mm (3/4\" GHT)"));
echo(str("Thread pitch: ", ght_pitch, " mm (11.5 TPI)"));
echo(str("Thread windings: ", ght_windings));
echo(str("Number of outlets: ", num_outlets));
echo(str("Outlet diameter: ", outlet_diameter, " mm"));
echo(str("Each outlet area: ", PI * pow(outlet_diameter/2, 2), " mm²"));
echo(str("Total outlet area: ", num_outlets * PI * pow(outlet_diameter/2, 2), " mm²"));
echo(str("Fan width: ", (num_outlets - 1) * outlet_spacing, " mm"));
