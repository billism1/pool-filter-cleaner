# OpenSCAD Design Prompt — Rotary-to-Linear Actuator

> Use this prompt when modifying `rotary_to_linear_actuator/rotary_to_linear_actuator.scad`.

## Context

You are modifying a crank-slider mechanism for a pool filter cleaner. The mechanism converts rotary motion (from a water-pressure-driven gear train) into a 6-inch (152.4 mm) linear reciprocating stroke. All parts are for FDM 3D printing without supports.

## Current Components (all in one file)

| Module | Purpose | Print Orientation |
|--------|---------|-------------------|
| `crank_wheel_body()` | ~182 mm wheel on 3/4" tube, crank pin at 76.2 mm radius | Disc flat (−Z on bed) |
| `connecting_rod()` | 240 mm socket-style rod with 608 bearings at both ends | Flat bar face on bed |
| `frame_bracket()` | Stationary plate with S6904ZZ bearing + 2 guide rail walls | Plate flat (−Z on bed) |
| `carriage()` | Sleigh with 4× LM8UU pockets + wrist pin | Body flat (−Z on bed) |
| `spacer_ring()` | 24 mm ring between wheel and frame bearing | Ring face on bed |
| `rounded_rect()` | Helper: cube with rounded XY edges | — |

## Rules for Editing

1. **Parameters at the top** — never hardcode dimensions in modules.
2. **Derived values in the `// Derived` section** — computed from parameters.
3. **Echo every key dimension** — add `echo()` in the echo block for new params.
4. **Assembly transforms — every placed part uses:**
   ```openscad
   translate([0, 0, wheel_diameter / 2])
       rotate([90, 0, 0])
           // part-specific translation
               module_call();
   ```
5. **No supports** — keep overhangs ≤45°; put the flat face at −Z.
6. **Bearings not bushings** — use rolling-element bearings everywhere.
7. **Test all 4 positions** — `crank_position` = 0, 1, 2, 3 must all clear.

## Key Relationships

- Frame plate extends asymmetrically: Y from −96.2 to +35 mm (frame-local), but guide walls span −35 to +35 mm (symmetric `frame_width = 70`).
- Guide rods are at `guide_rod_z_offset = 12 mm` above the frame +Z face.
- Carriage aligns its rod pockets to the guide rods via `carriage_z_local`.
- The connecting rod swing angle (`con_rod_swing`) is computed from crank geometry and keeps the small end on the X axis.

## Remaining TODO Items

- [ ] PVC pipe clamp geometry on carriage (params already defined: `pvc_pipe_od`, `pvc_clamp_clearance`, `pvc_clamp_wall`)
- [ ] Animate crank rotation using OpenSCAD `$t` variable
- [ ] Verify PVC pipe clearance at both stroke extremes
- [ ] Export STLs for all actuator components
- [ ] Update project README.md with actuator BOM
