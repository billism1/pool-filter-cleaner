$fn = 180;  // Reduce to 60 for faster preview, increase to 180+ to for final render

round_val = 3;

// Shape dimension parameters
base_radius = 30;      // Radius of the base
base_height = 8;      // Height of the base section
taper_end_height = 10; // Height where taper ends
neck_radius = 25;      // Radius of the neck/top section
total_height = 15;     // Total height of the shape

rotate_extrude() {
    // Offset rounds all corners of the 2D shape
    offset(r = round_val) 
    offset(delta = -round_val)
    polygon(points=[
        [0, 0], 
        [base_radius, 0], 
        [base_radius, base_height], 
        [neck_radius, taper_end_height], 
        [neck_radius, total_height], 
        [0, total_height]
    ]);
}