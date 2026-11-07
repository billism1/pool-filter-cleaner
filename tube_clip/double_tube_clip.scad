// Dual Tube Clip Coupler (2D profile extrusion)
//
// Two back-to-back C-clip cradles that hold two parallel
// tubes or pipes together. Uses 2D profile extrusion for
// clean rounded lips on the C openings.
//
// 3D Printing:
//   • −Z face (flat base) on the print bed.
//   • No supports required.

$fn = 180;  // High facet count for smooth curves. Use 60 for fast previews.

// ============================================================
// Tube Preset Selection
// ============================================================

// Set tube_preset to use a predefined tube size, or 0 for custom.
//   0 = Custom (uses tube_od_custom and clip_clearance_custom below)
//   1 = PVC Schedule 40, 1/2″ (21.34 mm OD)
//   2 = PVC Schedule 40, 3/4″ (26.67 mm OD)
//   3 = PVC Schedule 40, 1″   (33.40 mm OD)
//   4 = Aluminum round tubing, 3/4″ (19.05 mm OD)
//   5 = PVC Schedule 40, 1.5″ (48.26 mm OD)
tube_preset = 4;

// ── Custom tube dimensions (used when tube_preset = 0) ──────
tube_od_custom        = 26.67;   // Outer diameter for custom tube (mm)
clip_clearance_custom = -0.3;    // Clearance for custom tube (mm). Negative = tight friction fit

// ── Preset lookup tables ────────────────────────────────────
_preset_ods        = [0, 21.34, 26.67, 33.40, 19.05, 48.26];
_preset_clearances = [0, -0.3,  -0.3,  -0.3,  -0.1,  -0.3];
_preset_names      = ["Custom", "PVC Sch40 1/2in", "PVC Sch40 3/4in", "PVC Sch40 1in", "Aluminum 3/4in", "PVC Sch40 1.5in"];
_preset_count      = len(_preset_ods);
_preset_valid      = (tube_preset >= 0 && tube_preset < _preset_count);

// ============================================================
// Parameters
// ============================================================

tube_od                = (tube_preset == 0) ? tube_od_custom        : _preset_ods[tube_preset];
clip_clearance         = (tube_preset == 0) ? clip_clearance_custom  : _preset_clearances[tube_preset];
wall                   = 4;          // C-shape wall thickness (mm)
clip_wrap_angle        = 260;        // Degrees of tube wrapped by each C (e.g. 260° = 100° gap)
clip_opening_extra_pct = 0.15;       // Extra opening width as fraction of bore_d (0.15 = 15%)
clip_length            = 15;         // Extrusion length along Z (mm)
clip_back_overlap      = 2;          // How much the clip backs overlap at centre (mm)
add_spine              = true;       // Add rectangular spine joining the two Cs
spine_height           = wall * 1.5; // Spine extent perpendicular to clip centres (mm)

// ============================================================
// Derived
// ============================================================

bore_d              = tube_od + clip_clearance;
outer_d             = bore_d + 2 * wall;
mid_r               = (bore_d + outer_d) / 4;    // Midline radius of wall arc
spacing             = outer_d - clip_back_overlap; // Centre-to-centre distance
gap_angle           = 360 - clip_wrap_angle;       // Base opening angle (degrees)
clip_opening_extra  = bore_d * clip_opening_extra_pct;
// Effective gap angle accounting for extra opening width
effective_gap_angle = 2 * asin(sin(gap_angle / 2) + clip_opening_extra_pct);
opening_width       = bore_d * sin(effective_gap_angle / 2);

// ============================================================
// 2D Modules
// ============================================================

// Single C-shape with rounded lips, gap centred at 0° (opening faces +X)
module c_profile() {
    union() {
        difference() {
            circle(d = outer_d);
            circle(d = bore_d);
            // Wedge cut centred at 0°
            rotate([0, 0, -effective_gap_angle / 2])
                square([outer_d, outer_d]);
            rotate([0, 0, effective_gap_angle / 2])
                mirror([0, 1, 0])
                    square([outer_d, outer_d]);
        }
        // Semicircular caps at each lip end
        for (a = [effective_gap_angle / 2, -effective_gap_angle / 2])
            rotate([0, 0, a])
                translate([mid_r, 0])
                    circle(d = wall);
    }
}

// Two Cs back-to-back: openings face away from each other
module double_clip_profile() {
    union() {
        // Left C — opening faces −X
        translate([-spacing / 2, 0])
            rotate([0, 0, 180])
                c_profile();

        // Right C — opening faces +X
        translate([spacing / 2, 0])
            c_profile();

        // Rectangular spine joining the two Cs at the back
        if (add_spine)
            square([spine_height, spacing / 2], center = true);
    }
}

// ============================================================
// 3D Part
// ============================================================

if (_preset_valid)
    linear_extrude(height = clip_length, convexity = 10)
        double_clip_profile();

// ============================================================
// Echo — verify computed dimensions
// ============================================================

if (!_preset_valid)
    echo(str("ERROR: tube_preset=", tube_preset, " is invalid. Must be 0..", _preset_count - 1, ". Nothing will be rendered."));
echo(str("Dual Tube Clip Coupler (2D profile):"));
echo(str("  Preset:         ", _preset_valid ? _preset_names[tube_preset] : "INVALID", " (tube_preset=", tube_preset, ")"));
echo(str("  Tube OD:        ", tube_od, " mm"));
echo(str("  Clip clearance: ", clip_clearance, " mm"));
echo(str("  Bore diameter:  ", bore_d, " mm"));
echo(str("  Outer diameter: ", outer_d, " mm"));
echo(str("  Clip length:    ", clip_length, " mm"));
echo(str("  Base gap angle: ", gap_angle, "°"));
echo(str("  Extra opening:  ", clip_opening_extra, " mm (", clip_opening_extra_pct * 100, "%)"));
echo(str("  Effective gap:  ", effective_gap_angle, "°"));
echo(str("  Opening width:  ", opening_width, " mm (at bore)"));
echo(str("  Centre spacing: ", spacing, " mm"));
echo(str("  Back overlap:   ", clip_back_overlap, " mm"));
echo(str("  Spine:          ", add_spine ? "yes" : "no", " (height=", spine_height, " mm)"));
echo(str("  Lip rounding:   ", wall / 2, " mm (wall/2)"));