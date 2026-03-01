# Rotary-to-Linear Actuator — Design Plan

> **All parts in this project are designed for 3D printing (FDM/FFF).** Print orientations are chosen to avoid supports where possible — see individual part notes for recommended print orientation.

## Broader Goal

This actuator is part of the **gear-driven pool filter cleaner** system. The full system works as follows:

1. A cylindrical pool filter cartridge (~3 ft long × 9 in diameter) is held **horizontally** on a 3/4" aluminum rod by two filter holders with S6904ZZ bearings, supported by leg bases and leg feet.
2. A **PVC spray pipe** (with a closed end) is mounted horizontally, parallel to the filter. It has **orifices drilled into it ~150 mm (~6") apart**. A garden hose feeds water into the open end of the pipe, and the orifices produce focused spray jets that hit the filter and **rotate it** on the bearings.
3. On the gear-driven end, a **spur gear ring** on one filter holder meshes with a **compound gear** (spur + straight bevel). The bevel pinion drives a **mating bevel gear** that changes axis 90°.
4. A 3/4" aluminum tube is secured (via set screw) through the centre of the mating bevel gear. As the filter spins, it drives this tube in rotation.
5. The **other end** of that same tube connects to a **rotary-to-linear actuator** (crank-slider mechanism). The actuator converts the tube's rotation into a **6-inch (152.4 mm) back-and-forth linear stroke**.
6. A **carriage** rides on the actuator and carries the **PVC spray pipe**. The actuator sweeps the pipe back and forth by ~6 inches (one orifice spacing). Because the orifices are spaced ~6" apart and the stroke is also ~6", every point along the filter's length is reached by at least one orifice during a full stroke cycle, giving **complete coverage** of the entire filter.

The result: water pressure alone powers the entire system — spinning the filter *and* sweeping the spray pipe — no electricity or motor needed.

---

## Key Shared Dimensions (must stay in sync with `filter_holder_with_gear.scad`)

| Parameter | Value | Notes |
|---|---|---|
| Aluminum tube OD | 19.05 mm (3/4") | Standard tube used for all rods |
| Tube bore clearance | 0.5 mm | Snug fit, clamped by set screws |
| Tube bore diameter | 19.55 mm | `rod_diameter + rod_clearance` |
| Set-screw hole diameter | 3.4 mm | 85% of M4 nominal; self-threads into 3D print |
| Hub wall thickness | 6 mm | Around tube bore in gears and actuator wheel |
| Hub outer diameter | ~31.55 mm | `rod_hole_diameter + 2 × hub_wall_thickness` |
| Stroke length | 152.4 mm (6") | Full back-and-forth travel of sleigh |
| Crank radius | 76.2 mm (3") | `stroke / 2` |

---

## Design Steps

### Step 1 — Crank Wheel ✅ DONE

**File:** `rotary_to_linear_actuator/rotary_to_linear_nozzle_actuator.scad`

The crank wheel connects to the 3/4" aluminum tube from the mating bevel gear and converts its rotation into crank motion via a pin offset from centre.

**What was built:**
- Disc wheel, **~182.4 mm diameter**, 12 mm thick
- Central hub (31.55 mm OD) bored for 19.55 mm tube, extending **only on the +Z (crank-pin) side** by 10 mm for 3D-print-friendliness (−Z face is flat = print bed)
- Two **M4 set-screw holes** (180° apart) on the +Z hub extension, for clamping the tube
- **Crank pin hole**: 8 mm diameter blind hole, 8 mm deep from +Z face, at 76.2 mm radius from centre. Accepts a separate 8 mm steel pin (not 3D-printed). Leaves 4 mm solid material on the −Z (print-bed) side. A visual reference pin (`show_crank_pin`) renders the metal pin in silver.
- **6 circular lightening holes** (35 mm diameter each) evenly spaced around the disc (same style as mating bevel gear drain holes)
- **Orientation:** tube bore runs along **Y axis** (parallel to the XY bottom plane / ground); wheel disc stands vertically in XZ plane; bottom rim sits on Z = 0

---

### Step 2 — Connecting Rod ✅ DONE

**File:** `rotary_to_linear_actuator/rotary_to_linear_nozzle_actuator.scad` (same file as crank wheel)

The connecting rod links the crank pin on the wheel to the carriage pivot, converting rotary crank motion into push-pull force.

**What was built:**
- **Socket-style design** for hub clearance: cylindrical socket bosses at each end extend downward (toward the wheel face), with an elevated flat bar connecting them on top. This keeps the rod body clear of the hub tube as the wheel rotates.
- **240 mm centre-to-centre** length (≈3.1× crank radius) — keeps slider motion close to sinusoidal with minimal side-loading
- **Big end (crank pin):** 608 2RS bearing press-fit pocket — 22.2 mm bore (bearing OD + 0.2 mm tolerance), ~30.2 mm boss OD (4 mm wall)
- **Small end (carriage pivot):** identical 608 2RS bearing pocket — same 22.2 mm bore, ~30.2 mm boss OD. The carriage's wrist pin (8 mm) passes through this bearing.
- **Stepped bores** at both ends: bearing pocket at full OD from the open end (z=0 to bearing width), then a 16 mm shoulder hole that clears the inner race but seats the outer race. Prevents the bearing from sliding through.
- **Socket height:** 13 mm (bearing width 7 mm + 6 mm)
- **Bar thickness:** 8 mm; **bar width:** 25 mm (narrower than the ~30.2 mm socket ODs for a sleeker profile)
- **3D print orientation:** flat bar face (away-from-wheel side) on bed; sockets extend upward
- **608 2RS bearings at both ends** for low-friction pivoting — bearing inner race rides on the pin, outer race press-fits into the socket
- **Triangular gusset wedges** on the inside face of each socket (big-end toward small-end, small-end toward big-end). Gusset base penetrates into the socket cylinder so there's no visible seam. Parameters: `con_rod_gusset_length` = 10 mm, `con_rod_gusset_width` = 10 mm.
- Assembly: rod is positioned on the crank pin at the correct swing angle for an inline slider-crank, with the socket bottom sitting 1 mm above the crank-pin fillet
- A **4-state `crank_position` parameter** (0 = Top, 1 = Right, 2 = Bottom, 3 = Left) rotates the wheel and repositions the connecting rod so it stays attached to the crank pin at each position. This is used for **visual inspection** at each extreme crank angle to verify clearances, stroke limits, and rod alignment before printing.

---

### Step 3 — Frame / Mounting Bracket ✅ DONE

**File:** `rotary_to_linear_actuator/rotary_to_linear_nozzle_actuator.scad` (same file, `frame_bracket()` module)

The frame bracket is a stationary plate on the −Z side of the wheel that houses a bearing for the aluminum tube. This design has **no guide walls or guide rods** — the spray pipe is carried directly by the connecting rod's wrist pin.

**What was built:**
- **Main plate:** Trapezoidal — 250 mm wide at bottom (X), narrowing to 70 mm (`frame_top_width`) at top, × 12 mm thick, with 10 mm rounded corners. Uniform thickness throughout.
- **Plate Y span:** extends from `frame_plate_y_min` (20 mm below wheel bottom, = `-(wheel_diameter/2 + 20)`) to `frame_plate_y_max` (`wheel_diameter / 6`). Bottom edge is full width (250 mm); top edge is narrower (70 mm) to save material where less support is needed.
- **Trapezoidal shape** implemented via `hull()` of four corner cylinders; `frame_half_width_at_y()` function provides linear interpolation for lightening-hole boundary checks
- **S6904ZZ bearing pocket** recessed from the +Z face at the tube centre. Ring cutout below bearing is defined in parameters but currently **commented out** in the module.
- **Tube through-hole** with 6.5 mm clearance (`frame_tube_clearance`) — bearing provides alignment
- **Lightening holes:** staggered brick/hex grid pattern of 30 mm diameter holes. Holes that would encroach on the bearing pocket (with 5 mm margin) or extend beyond the trapezoidal plate boundary are automatically skipped.
- Frame sits with a 2 mm air gap below the wheel's −Z face
- Main plate uses trapezoidal `hull()` with `frame_edge_radius` = 10 mm rounded corners; `frame_top_width` parameter controls top width
- **3D print orientation:** −Z face (flat) on bed; no supports needed
- **Render toggle:** `build_frame_bracket` boolean

---

### Step 4 — Spray Pipe Carriage ❌ NOT YET BUILT

**File:** `rotary_to_linear_actuator/rotary_to_linear_nozzle_actuator.scad`

The spray pipe (3/4″ aluminum pipe) will be connected directly to the connecting rod's small-end wrist pin and will slide linearly. No guide-rod / LM20UU carriage is used.

**Status:** No carriage module exists in this file yet. A wrist pin visual reference (`show_wrist_pin`) renders at the small-end position to show where the spray pipe will attach. The design of the nozzle carriage / spray pipe clamp is still to be determined.

---

### Step 5 — Spacer Ring ✅ DONE

**File:** `rotary_to_linear_actuator/rotary_to_linear_nozzle_actuator.scad` (same file, `spacer_ring()` module)

A thin ring on the aluminum tube between the wheel's −Z face and the S6904ZZ bearing inner race in the frame bracket. Prevents the rotating wheel from rubbing against the stationary frame.

**What was built:**
- **Simple annulus:** 24 mm OD × 19.55 mm bore × 2 mm thick
- OD sized to contact **only the S6904ZZ inner race** (~25 mm OD), not the outer race or balls
- Bore is snug-fit on the aluminum tube (19.55 mm = tube OD + 0.5 mm clearance)
- Thickness equals the `frame_gap` (2 mm), filling the gap between wheel and bearing
- **No set screw** — held in place by snug fit on tube and being pressed between wheel and bearing inner race (may be epoxied to wheel)
- **3D print orientation:** flat (ring face on bed)
- **Render toggle:** `build_spacer_ring` boolean
- Rotates with the tube/wheel in the assembly

---

### Step 6 — Support Sleeve ✅ DONE

**File:** `rotary_to_linear_actuator/rotary_to_linear_nozzle_actuator.scad` (same file, `support_sleeve()` module)

A tapered tube on the aluminum tube between the frame bracket's −Z face and the bevel gear. Keeps the frame bracket and bevel gear apart at the correct spacing. Rotates with the tube/wheel.

**What was built:**
- **Tapered cylinder:** 43 mm long, bore = 19.55 mm (same as other hubs)
- **Bracket (near) end:** smaller OD (≈23.55 mm, 2 mm wall) — inserts into the frame tube hole and touches the S6904ZZ bearing face. Insertion depth = `frame_thickness − frame_bearing_width` (3 mm).
- **Far (bevel-gear) end:** larger OD (≈29.55 mm, 4 mm wall) — faces the bevel gear. This is the print-bed side (−Z face at z=0).
- **Two M4 set-screw holes** (180° apart, 3.4 mm diameter) at the thick far end for clamping onto the aluminum tube
- **3D print orientation:** far end (larger OD) flat on bed; tapers upward to bracket end
- **Render toggle:** `build_support_sleeve` boolean

---

### Step 7 — Visual References ✅ DONE

**File:** `rotary_to_linear_actuator/rotary_to_linear_nozzle_actuator.scad` (assembly section)

Non-printed reference geometry rendered to aid visual inspection of the assembly.

**What was built:**
- **Rotary aluminum tube** (DimGray): hollow cylinder (19.05 mm OD, 1.65 mm wall = standard 3/4″ tube), extending from the hub top through the wheel, spacer ring, and frame bearing. Rotates with `crank_angle`. Toggle: `show_rotary_aluminum_tube`.
- **Spray pipe carriage aluminum tube / spray pipe** (DimGray): 3/4″ aluminum tube (1219.2 mm / 4 ft long) running parallel to the connecting rod, offset in the −Z (frame) direction at `spray_tube_z_local = −110 mm`. Extends from X = −150 mm for the full spray pipe length. Stationary reference showing the spray pipe's swept path. Toggle: `show_spray_pipe_carriage_aluminum_tube`.
- **Crank pin** (Silver): 8 mm steel pin in the wheel's blind hole, with a flat edge for printability. Extends `crank_pin_height` (20 mm) above the +Z wheel face. Toggle: `show_crank_pin`.
- **Wrist pin** (Silver): 8 mm steel pin at the connecting rod's small end (at slider_x on the X axis). Shows where the spray pipe attachment will be. Toggle: `show_wrist_pin`.

---

### Frame Base Legs (separate file) ✅ DONE

**File:** `leg_base/actuator_frame_base_legs.scad`

Holds the frame bracket upright. **Print 2** — one for each end of the bottom of the frame bracket.

**What was built:**
- **Frame cradle:** U-shaped slot (8 mm walls, 12.15 mm slot width = `frame_thickness` + 0.15 mm clearance, 45 mm tall) that the frame bracket slides into. An M4 set screw in the cradle wall clamps the frame in place.
- **Two legs** angled 45° downward with a 12° inward tilt, 90° apart — same tripod-style leg design used by the filter holder bases. Each leg has a rod hole (19.55 mm bore, 35 mm deep) and an M4 set screw for clamping 3/4″ aluminum rod legs.
- **Curved printing base** with concave taper (BOSL2 `rotate_sweep`), trimmed to a 145° footprint for material saving while still supporting both legs.
- **Reinforcement fillets** at all tube junctions (horizontal-to-leg and leg-to-leg).
- Uses BOSL2 (`include <BOSL2/std.scad>`).

---

### Step 8 — Assembly & Validation 🔶 PARTIALLY DONE

All components are assembled **inline** in the same `.scad` file (no separate assembly file). The 4-state `crank_position` parameter allows visual inspection at each extreme.

**Completed:**
- Crank wheel, connecting rod, spacer ring, frame bracket, and support sleeve all placed with proper transforms
- Visual references (rotary aluminum tube, spray pipe, crank pin, wrist pin) rendered for context
- 4-state `crank_position` for manual clearance/stroke checks (Top / Right / Bottom / Left)
- Support sleeve positioned between frame bracket and bevel gear, rotating with tube

**Still TODO:**
- Design and build the spray pipe carriage / spray pipe clamp (Step 4)
- Animate the crank rotation (OpenSCAD `$t` variable) for continuous motion verification
- Un-comment and verify the ring cutout below the S6904ZZ bearing pocket in the frame bracket
- Verify spray pipe clearance at all crank positions
- Export STLs for all actuator components
- Update the project `README.md` with actuator parts BOM

---

## Additional Notes for Copilot Agent

- All models are **OpenSCAD** (`.scad`) and use the **BOSL2** library for gears and other advanced geometry (`include <BOSL2/std.scad>`, `include <BOSL2/gears.scad>`) in the filter holder files. The actuator file does **not** currently use BOSL2.
- Use `$fn = 60` for fast previews, `$fn = 80` for normal work, `$fn = 180` for final renders / STL export (current setting in file)
- All dimensions are in **millimetres**
- The project convention is to use **set-screw holes** (M4 / 3.4 mm diameter, 85% of nominal for self-threading into plastic) to secure aluminum tubes in hubs
- Bearings used: **S6904ZZ** (37 mm OD × 20 mm ID × 9 mm thick) for tube support in frame and filter holders; **608 2RS** (22 mm OD × 8 mm bore × 7 mm width) for crank pin and wrist pin pivots
- The **spray element is a PVC pipe** (not the fan-out nozzle in `nozzle/`). The pipe is mounted horizontally on the sleigh, parallel to the filter, with orifices drilled ~150 mm (~6") apart and a closed far end. The garden hose connects to the open end. The sleigh moves the pipe back and forth by one orifice spacing (~6") so the jets sweep the entire filter length.
- The tube connecting the mating bevel gear to the crank wheel needs to be long enough to clear the filter cartridge and legs; typical filter length is ~3 ft (914 mm), so this tube may be 12–18 inches (300–450 mm)
- Water pressure is the **sole power source** — the mechanism must have low enough friction that the torque transmitted through the gear train from the spinning filter is sufficient to drive the actuator

---

## Coordinate System Reference

Understanding the coordinate transforms is critical when modifying the assembly:

### Module-local coordinates (how parts are built)
- **Crank wheel:** rotation axis = Z; disc centred at origin; −Z face flat (print bed)
- **Connecting rod:** extends along +X; z=0 is socket bottom (bearing side)
- **Frame bracket:** +Z face at z=0 (faces wheel); plate extends into −Z; walls extend into +Z
- **Spacer ring:** −Z face at z=0 (print bed)
- **Support sleeve:** z=0 is far end (larger OD, print bed); z=`support_sleeve_length` is bracket end (smaller OD)

### Assembly transforms (module-local → world)
All parts share a common prefix transform:
```
translate([0, 0, wheel_diameter/2])   // Lift so wheel bottom sits on Z=0
    rotate([90, 0, 0])                // Local Z → world −Y (tube along Y axis)
```
This means:
- Module-local **X** → world **X** (slider axis, horizontal)
- Module-local **Y** → world **−Z** (used to be up, now points down after rotate)
- Module-local **Z** → world **−Y** (was rotation axis, now depth/along tube)
- Frame-local **Y** → world **Z** (vertical in world) after the transform
