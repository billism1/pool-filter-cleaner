include <BOSL2/std.scad>
// https://github.com/BelfrySCAD/BOSL2

$fn = 180;  // Reduce to 60 for faster preview, increase to 180+ to for final render

// --- Dimensions ---
base_r = 45;     // Radius of the bottom
neck_r = 20;     // Radius of the narrow neck
base_h = 10 ;    // Height of the flat base part
taper_h = 15;    // Vertical distance of the concave curve
neck_h = 6;     // Height of the straight top section
round_val = 4;   // Radius for rounding ALL edges

// 1. Define the 2D "Half-Profile" Path
// X must be >= 0 for rotate_sweep to work
profile_path = [
    [0, 0],                              // Center bottom
    [base_r, 0],                         // Bottom outer edge
    [base_r, base_h],                    // Top edge of base
    
    // Concave Transition (The Scoop)
    for (t = [0.1 : 0.1 : 0.9]) 
        let(
            z = base_h + t * taper_h,
            // 'pow(t, 2)' creates the concave inward scoop
            r = neck_r + (base_r - neck_r) * pow(1-t, 2)
        ) [r, z],
        
    [neck_r, base_h + taper_h],          // Start of straight neck
    [neck_r, base_h + taper_h + neck_h], // Top outer edge
    [0, base_h + taper_h + neck_h]       // Center top
];

// 2. Round the corners and Spin it
// Set radius=0 at center points (top and bottom) to remove dimples
// Set radius=0 at top outer edge for sharp 90-degree corner
// Path has 15 points: [0]=center bottom, [1-13]=outer profile, [14]=center top
radii = [for (i = [0:14]) 
    (i == 0 || i == 13 || i == 14) ? 0 : round_val]; // Don't round center points or top outer edge

rounded_profile = round_corners(profile_path, radius=radii);

rotate_sweep(rounded_profile, angle=360);
