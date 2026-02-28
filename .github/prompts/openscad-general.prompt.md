# OpenSCAD General Prompt

> Use this prompt for any OpenSCAD work in this project.

## Language Notes

OpenSCAD is a **functional CSG modelling language**, not a general-purpose programming language.

Key differences from typical languages:
- **No mutable variables** — all values are computed at parse time
- **No loops with side effects** — use `for()` as a geometric generator, not a control flow loop
- **Modules produce geometry**, not return values
- **`difference()`, `union()`, `intersection()`** are the core boolean CSG operations
- **`hull()`** creates the convex hull of its children — commonly used for fillets and smooth transitions
- **`translate()`, `rotate()`, `scale()`** are transforms applied to children
- **`$fn`** controls facet count (smoothness of curves)

## Common Patterns

### Bearing pocket
```openscad
// Press-fit pocket: bore = bearing_OD + clearance
translate([0, 0, -bearing_width])
    cylinder(h = bearing_width + 0.1, d = bearing_od + clearance);
```

### Pin with fillet base
```openscad
translate([x, y, base_z]) {
    cylinder(h = fillet_h, d1 = fillet_dia, d2 = pin_dia);  // Tapered base
    cylinder(h = pin_height + fillet_h, d = pin_dia);         // Straight shaft
}
```

### Stepped bore (bearing + shoulder)
```openscad
// Full bearing OD for press-fit, then narrower shoulder hole
translate([0, 0, -1])
    cylinder(h = bearing_width + 1, d = bearing_od + clearance);
translate([0, 0, bearing_width])
    cylinder(h = remaining_height + 1, d = shoulder_hole_d);
```

### Rounded rectangle (cube with round XY edges)
```openscad
module rounded_rect(size, r) {
    hull() {
        for (x = [r, size.x - r], y = [r, size.y - r])
            translate([x, y, 0])
                cylinder(r = r, h = size.z);
    }
}
```

## Tolerances for 3D Printing

| Fit Type | Tolerance | Example |
|----------|-----------|---------|
| Press-fit (bearing) | +0.2 mm on OD | `bearing_od + 0.2` |
| Snug (tube + set screw) | +0.5 mm | `tube_od + 0.5` |
| Loose (bearing-aligned) | +2.0 mm | `tube_od + 2.0` |
| Rod through-hole | +0.3 mm | `rod_dia + 0.3` |
| Self-threading screw | 85% of nominal | `M4 → 3.4 mm hole` |
