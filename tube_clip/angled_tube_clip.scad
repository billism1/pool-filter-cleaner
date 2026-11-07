// Angled Tube Clip Coupler
//
// Two back-to-back C-clip cradles that hold two tubes or pipes
// together at any angle (default 90°, perpendicular). The tubes
// cross without touching, offset by a configurable gap.
//
// Printability ("split tilt"):
//   Instead of standing one C upright and laying the other on its
//   side (which turns the second bore into an unsupported ceiling),
//   each C leans ±joint_angle/2 from vertical and the part is cut
//   flat top and bottom. Bores, outer walls and lip caps are all
//   cylinders tilted by at most 45°, so worst-case overhang is
//   joint_angle/2 (folded to ≤ 45° for angles above 90°).
//   At joint_angle = 0 (and edge_round_r = 0) this is the same shape as
//   double_tube_clip.scad.
//   The top and bottom edges of the Cs are smoothly rounded
//   (edge_round_r); see the Edge rounding parameters for what is rounded
//   and why.
//
// 3D Printing:
//   • −Z face (flat base) on the print bed.
//   • No supports required.
//   • Layer lines cross the C ring at up to 45° near the back, so the
//     snap is somewhat weaker than the parallel clip. Use 3+ perimeters.
//
// Tubes snap in from the outside along ±X (the spacing axis), which is
// perpendicular to both tubes.

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
clip_length            = 15;         // Print height along Z (mm). Grip along each tube = clip_length / cos(tilt)
clip_back_overlap      = 2;          // Back overlap of the parallel clip; only used for the tube_gap default (mm)

// ── Angle and spacing ───────────────────────────────────────
// Angle between the two tubes, 0 <= joint_angle < 180.
//   0  = parallel (same as double_tube_clip.scad when edge_round_r = 0)
//   90 = perpendicular (default)
//   A and 180-A are mirror images (opposite crossing hand): pick the
//   one that matches which tube should pass over the other.
joint_angle  = 90;

// Surface-to-surface gap between the two bores (mm). The default
// matches the spacing of double_tube_clip.scad.
tube_gap     = 2 * wall - clip_back_overlap;

// Smallest allowed gap. At tube_gap >= wall, neither C's wall can reach
// into the other tube's space or block its snap-in path.
min_tube_gap = wall;

add_spine    = true;         // Add hub block joining the two C backs

// ── Edge rounding ───────────────────────────────────────────
// Smoothly rounds the C edges left by the flat top and bottom cuts (mm).
// 0 = sharp.
//   Top:    every C edge gets a quarter-circle fillet of this radius.
//   Bottom: only the knife-thin acute edges (where a leaning wall meets
//           the bed at a shallow angle) are rounded, with an arc that
//           starts vertical at the bed. The other bottom edges stay
//           square: rounding them would create an overhang right at the bed.
edge_round_r     = 1.2;
edge_round_steps = 16;       // Rings per rounded zone. More = smoother

// ============================================================
// Derived
// ============================================================

bore_d              = tube_od + clip_clearance;
outer_d             = bore_d + 2 * wall;
mid_r               = (bore_d + outer_d) / 4;      // Midline radius of wall arc
spacing             = bore_d + tube_gap;           // Centre-to-centre distance along X
spine_width         = (outer_d - clip_back_overlap) / 2; // Hub extent along Y, same as parallel clip
gap_angle           = 360 - clip_wrap_angle;       // Base opening angle (degrees)
clip_opening_extra  = bore_d * clip_opening_extra_pct;
// Effective gap angle accounting for extra opening width
effective_gap_angle = 2 * asin(sin(gap_angle / 2) + clip_opening_extra_pct);
opening_width       = bore_d * sin(effective_gap_angle / 2);

// Tilt of each C from vertical. Angles above 90° fold to the mirror
// configuration so |tilt| <= 45° while keeping the crossing hand.
tilt                = (joint_angle <= 90) ? joint_angle / 2 : (joint_angle - 180) / 2;
max_overhang        = abs(tilt);
grip_length         = clip_length / cos(tilt);     // Axial grip along each tube at its centreline

// Edge rounding. Capped at a third of the print height, at 40% of the wall
// so the top of a wall keeps a flat strip, and below the tightest curve of
// the outline (the lip cap, radius wall/2 squeezed by cos(tilt)) so the
// inset outline can never fold over itself.
_top_r              = max(0, min(edge_round_r, clip_length / 3, wall * 0.4, 0.95 * wall / 2 * cos(tilt)));
_round_n            = max(1, round(edge_round_steps));
_bot_trim           = (_top_r > 0 && abs(tilt) >= 0.5);   // No acute bottom edges when nearly upright
_bot_h              = _bot_trim ? _top_r : 0;
// Bottom arc: vertical at the bed, tangent to the leaning wall at height _bot_h
_bot_R              = _bot_trim ? _bot_h / sin(abs(tilt)) : 0;
_bot_c              = _bot_trim ? _bot_R * (1 / cos(tilt) - 1) : 0; // Inset at the bed (walls facing ±Y)
// Hub vertical corner radius: larger than the top rounding so the rounded
// top corners stay smooth, but short of the hub's half-width (0 when sharp)
_hub_corner_r       = _top_r > 0 ? min(0.45 * tube_gap, 2 * _top_r) : 0;

_angle_valid        = (joint_angle >= 0 && joint_angle < 180);
_gap_valid          = (tube_gap >= min_tube_gap);
_all_valid          = _preset_valid && _angle_valid && _gap_valid;

// ============================================================
// 2D Profile
// ============================================================

// Number of segments OpenSCAD would use for a circle of radius r
function _frags(r) = $fn > 0 ? max($fn, 3) : ceil(max(min(360 / $fa, r * 2 * PI / $fs), 5));

// C outline as a closed point path, opening at +X, counter-clockwise.
// Same shape as c_profile() in double_tube_clip.scad: a ring with a wedge
// cut out and semicircular caps on the lips.
function c_path() =
    let(
        g  = effective_gap_angle / 2,
        ro = outer_d / 2,
        ri = bore_d / 2,
        rc = wall / 2,
        na = max(8, ceil(_frags(ro) * (360 - 2 * g) / 360)), // Points per main arc
        nc = max(4, ceil(_frags(rc) / 2)),                   // Points per lip cap
        u1 = [cos(-g), sin(-g)],  v1 = [sin(g),  cos(g)],    // Radial / into-gap directions at −g
        u2 = [cos(g),  sin(g)],   v2 = [sin(g), -cos(g)]     // Radial / into-gap directions at +g
    )
    concat(
        // Outer arc, g → 360−g (each piece includes its start, not its end)
        [for (i = [0 : na - 1]) let(a = g + i * (360 - 2 * g) / na) ro * [cos(a), sin(a)]],
        // Lip cap at −g: outer → inner, bulging into the opening
        [for (i = [0 : nc - 1]) let(f = i * 180 / nc) mid_r * u1 + rc * (cos(f) * u1 + sin(f) * v1)],
        // Inner arc, 360−g → g
        [for (i = [0 : na - 1]) let(a = 360 - g - i * (360 - 2 * g) / na) ri * [cos(a), sin(a)]],
        // Lip cap at +g: inner → outer
        [for (i = [0 : nc - 1]) let(f = i * 180 / nc) mid_r * u2 + rc * (-cos(f) * u2 + sin(f) * v2)]
    );

// c_path() turned so the opening faces the given way (0 → +X, 180 → −X)
// and stretched by 1/cos(t) along Y: the horizontal cross-section of a C
// whose axis leans by t about X.
function c_path_section(t, opening_rot) =
    [for (p = c_path())
        let(q = [cos(opening_rot) * p.x - sin(opening_rot) * p.y,
                 sin(opening_rot) * p.x + cos(opening_rot) * p.y])
        [q.x, q.y / cos(t)]];

// Rounded rectangle outline, centred, w (X) by l (Y), corner radius rc,
// counter-clockwise. rc = 0 gives a plain rectangle.
function rounded_rect_path(w, l, rc) =
    rc <= 0
        ? [[w / 2, -l / 2], [w / 2, l / 2], [-w / 2, l / 2], [-w / 2, -l / 2]]
        : let(nq = max(2, ceil(_frags(rc) / 4)))
          [for (c = [[ w / 2 - rc, -l / 2 + rc, -90], [ w / 2 - rc, l / 2 - rc,   0],
                     [-w / 2 + rc,  l / 2 - rc,  90], [-w / 2 + rc, -l / 2 + rc, 180]])
              for (i = [0 : nq])
                  let(a = c[2] + 90 * i / nq)
                  [c[0] + rc * cos(a), c[1] + rc * sin(a)]];

// Outward unit normals of a counter-clockwise closed path, from neighbouring points
function path_normals(path) =
    let(n = len(path))
    [for (i = [0 : n - 1])
        let(d = path[(i + 1) % n] - path[(i + n - 1) % n])
        [d.y, -d.x] / norm(d)];

// ============================================================
// 3D Modules
// ============================================================

// Rings that make up a rounded solid, bottom to top: [height, inset all
// round, inset on trailing-facing edges only].
//   Bottom zone (trim_bottom): arc that starts vertical at the bed and
//                meets the leaning wall tangentially at _bot_h. Only edges
//                facing the trailing side (the side the section moves away
//                from going up) are knife-thin there, so only they are inset.
//   Top zone:    quarter-circle fillet, inset all round.
// Between the zones the solid is a straight (tilted) prism.
function _ring_specs(trim_bottom) = concat(
    trim_bottom
        ? [for (k = [0 : _round_n])
              let(f = abs(tilt) * k / _round_n, h = _bot_R * sin(f))
              [h, 0, max(0, _bot_c + _bot_R * (1 - cos(f)) - h * tan(abs(tilt)))]]
        : [[0, 0, 0]],
    _top_r > 0
        ? [for (k = [0 : _round_n])
              let(a = 90 * k / _round_n)
              [clip_length - _top_r + _top_r * sin(a), _top_r * (1 - cos(a)), 0]]
        : [[clip_length, 0, 0]]
);

// Point rings for a closed counter-clockwise outline P (the horizontal
// cross-section), centred at x and leaning by t about X. Each ring is P
// inset along its normals, then shifted along Y so the solid leans by t.
function loft_rings(P, x, t, trim_bottom) =
    let(
        N  = path_normals(P),
        dt = [0, sign(t)],                       // Trailing direction
        W  = [for (n = N) max(0, n * dt)]        // How much each edge faces the trailing side
    )
    [for (s = _ring_specs(trim_bottom))
        let(h = s[0], dy = -(h - clip_length / 2) * tan(t))
        [for (i = [0 : len(P) - 1])
            let(q = P[i] - N[i] * (s[1] + s[2] * W[i]))
            [x + q.x, q.y + dy, h]]];

// One C cradle centred at x, leaning by t about X (axis stays in a YZ
// plane). Same solid as extruding the C along the tilted axis and cutting
// it flat at z = 0 and clip_length, with the edges rounded.
module lofted_c(x, t, opening_rot) {
    rounded_loft(loft_rings(c_path_section(t, opening_rot), x, t, _bot_trim));
}

// Hub joining the C backs, bore surface to bore surface: a rounded
// rectangle with the same smooth top rounding as the Cs, square at the bed.
// Every hub point is >= bore_d/2 from both tube axes.
module lofted_hub() {
    rounded_loft(loft_rings(rounded_rect_path(tube_gap, spine_width, _hub_corner_r), 0, 0, false));
}

// A single smooth polyhedron through a list of equal-length point rings
module rounded_loft(rings) {
    m = len(rings);
    n = len(rings[0]);
    polyhedron(
        points = [for (r = rings) each r],
        faces  = concat(
            // Bed face (ring order is clockwise seen from below)
            [[for (i = [0 : n - 1]) i]],
            // Side walls, two triangles per quad between neighbouring rings
            [for (j = [0 : m - 2], i = [0 : n - 1], tri = [0, 1])
                let(a = j * n + i, b = (j + 1) * n + i,
                    c = (j + 1) * n + (i + 1) % n, d = j * n + (i + 1) % n)
                tri == 0 ? [a, b, c] : [a, c, d]],
            // Top face (reversed so it is clockwise seen from above)
            [[for (i = [n - 1 : -1 : 0]) (m - 1) * n + i]]
        ),
        convexity = 10);
}

module angled_clip() {
    union() {
        // Left C — opening faces −X
        lofted_c(-spacing / 2, -tilt, 180);

        // Right C — opening faces +X
        lofted_c(spacing / 2, tilt, 0);

        if (add_spine)
            lofted_hub();
    }
}

// ============================================================
// 3D Part
// ============================================================

if (_all_valid)
    angled_clip();

// ============================================================
// Echo — verify computed dimensions
// ============================================================

if (!_preset_valid)
    echo(str("ERROR: tube_preset=", tube_preset, " is invalid. Must be 0..", _preset_count - 1, ". Nothing will be rendered."));
if (!_angle_valid)
    echo(str("ERROR: joint_angle=", joint_angle, " is invalid. Must be 0 <= joint_angle < 180. Nothing will be rendered."));
if (!_gap_valid)
    echo(str("ERROR: tube_gap=", tube_gap, " mm is below min_tube_gap=", min_tube_gap, " mm (one wall). Nothing will be rendered."));
echo(str("Angled Tube Clip Coupler:"));
echo(str("  Preset:         ", _preset_valid ? _preset_names[tube_preset] : "INVALID", " (tube_preset=", tube_preset, ")"));
echo(str("  Tube OD:        ", tube_od, " mm"));
echo(str("  Clip clearance: ", clip_clearance, " mm"));
echo(str("  Bore diameter:  ", bore_d, " mm"));
echo(str("  Outer diameter: ", outer_d, " mm"));
echo(str("  Joint angle:    ", joint_angle, "°"));
echo(str("  Tilt per C:     ±", abs(tilt), "° from vertical"));
echo(str("  Max overhang:   ", max_overhang, "° from vertical"));
echo(str("  Tube gap:       ", tube_gap, " mm (min ", min_tube_gap, " mm)"));
echo(str("  Centre spacing: ", spacing, " mm"));
echo(str("  Print height:   ", clip_length, " mm"));
echo(str("  Grip length:    ", grip_length, " mm (along each tube)"));
echo(str("  Base gap angle: ", gap_angle, "°"));
echo(str("  Extra opening:  ", clip_opening_extra, " mm (", clip_opening_extra_pct * 100, "%)"));
echo(str("  Effective gap:  ", effective_gap_angle, "°"));
echo(str("  Opening width:  ", opening_width, " mm (at bore)"));
echo(str("  Spine:          ", add_spine ? "yes" : "no", " (", tube_gap, " x ", spine_width, " mm, corner r=", _hub_corner_r, " mm, rounded top)"));
echo(str("  Lip rounding:   ", wall / 2, " mm (wall/2)"));
echo(str("  Edge rounding:  top r=", _top_r, " mm; bottom ",
         _bot_trim ? str("acute edges, arc R=", _bot_R, " mm, ", _bot_c, " mm inset at bed")
                   : "none (no acute edges)",
         "; ", _round_n, " rings per zone"));
