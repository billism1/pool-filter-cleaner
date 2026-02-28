# Copilot Instructions — Pool Filter Cleaner Project

## Project Overview

This is a **3D-printable pool filter cleaning system** designed in **OpenSCAD**. Water pressure alone powers the entire mechanism — no electricity or motors. The system spins a pool filter cartridge on bearings via water jets, and a gear train drives a reciprocating actuator that sweeps the spray pipe back and forth.

## Technology & Language

- **All 3D models are OpenSCAD** (`.scad` files). This is NOT JavaScript or C — it's a functional CSG modelling language.
- Some files use the **BOSL2** library (`include <BOSL2/std.scad>`, `include <BOSL2/gears.scad>`) for gears and advanced geometry. The actuator file currently does NOT use BOSL2.
- **Units:** all dimensions are in **millimetres**.
- **Facet count:** `$fn = 80` for normal work, `$fn = 60` for fast previews, `$fn = 180` for final renders / STL export.

## Project Structure

```
pool-filter-cleaner/
├── filter_holder/          # Filter holders (plain + gear-driven)
├── leg_base/               # Support leg bases (2-leg and 4-leg)
├── leg_foot/               # Adjustable feet for legs
├── nozzle/                 # Garden hose nozzle experiments (not used in gear version)
├── rotary_to_linear_actuator/
│   ├── rotary_to_linear_actuator.scad   # Main actuator file (all parts + assembly)
│   └── plan.md                          # Detailed design plan & progress tracker
├── STLs/                   # Exported STL files for printing
├── .mcp.json               # OpenSCAD MCP server configuration
└── README.md               # Project overview and BOM
```

## Key Design Rules

### 3D Printing Constraints
- **All parts are designed for FDM/FFF printing without supports.** Each module has a designated flat face that goes on the print bed (always documented as the `−Z face`).
- **No overhangs >45°** unless explicitly noted.
- When adding new geometry, always consider print orientation and whether supports would be needed.

### Bearing & Hardware Standards
| Component | Spec | Where Used |
|-----------|------|-----------|
| S6904ZZ bearing | 37 mm OD × 20 mm ID × 9 mm | Filter holders, frame bracket tube support |
| 608 2RS bearing | 22 mm OD × 8 mm bore × 7 mm | Crank pin, wrist pin (con-rod pivots) |
| LM8UU linear bearing | 15 mm OD × 8 mm bore × 24 mm | Carriage (4× on guide rods) |
| Aluminum tube | 19.05 mm OD (3/4″) | Drive shaft, filter support rod |
| Guide rods | 8 mm smooth steel | Carriage linear motion |
| Set screws | M4 (3.4 mm hole = 85% of nominal) | Hub clamping on tubes |

### Tolerances
- **Press-fit bearing pockets:** bearing OD + 0.2 mm clearance
- **Tube bore (snug + set screw):** tube OD + 0.5 mm
- **Tube bore (loose, bearing-aligned):** tube OD + 2.0 mm
- **Guide rod holes:** rod diameter + 0.3 mm

### Friction & Power Budget
Water pressure is the **sole power source**. Every bearing choice and clearance is designed to minimise friction. Do not introduce plain bushings or tight sliding fits — always use rolling-element bearings.

## OpenSCAD Coding Conventions

### Parameter Organisation
Parameters are grouped by component section at the top of the file with inline comments showing computed values. Derived values go in a `// Derived` section.

### Module Design Pattern
```openscad
module part_name() {
    difference() {
        union() {
            // Positive geometry (body, bosses, pins)
        }
        // Negative geometry (bores, pockets, holes)
    }
}
```

### Assembly Pattern
All parts are assembled inline at the bottom of the file. Each part shares a common transform prefix:
```openscad
translate([0, 0, wheel_diameter / 2])   // Lift wheel bottom to Z=0
    rotate([90, 0, 0])                  // Tube axis along Y
        // part-specific placement
            part_module();
```

### Render Toggles
Each component has a boolean toggle (`build_*` for printed parts, `show_*` for visual references) so individual parts can be shown/hidden.

### Echo Statements
Key dimensions are echoed for verification. When adding new parameters, add corresponding `echo()` statements in the echo block.

## Coordinate System

### After Assembly Transforms (world coordinates)
- **X axis:** slider/carriage travel direction (horizontal)
- **Y axis:** tube rotation axis (depth, away from viewer)
- **Z axis:** vertical (wheel bottom at Z=0, wheel centre at Z = wheel_diameter/2)

### In Module-Local Coordinates
- **Crank wheel:** Z = rotation axis; disc centred at origin
- **Frame bracket:** +Z face at z=0 (toward wheel); plate into −Z; walls into +Z
- **Carriage:** −Z face at z=0 (print bed); centred in XY

## When Modifying This Project

1. **Always read `plan.md`** in `rotary_to_linear_actuator/` before making changes to the actuator — it contains the full design rationale, current state, and TODO items.
2. **Check the echo output** after changes to verify dimensions haven't drifted.
3. **Test all 4 crank positions** (set `crank_position` to 0, 1, 2, 3) to verify clearances at extremes.
4. **Update `plan.md`** when completing TODO items or making design changes.
5. **Parameter changes** should be made in the parameter section at the top, not hardcoded in modules.
6. When creating new parts, follow the existing module pattern: `difference() { union() { ... } ... }` with the flat print-bed face at −Z.
