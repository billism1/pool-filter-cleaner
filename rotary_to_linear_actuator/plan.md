# Rotary-to-Linear Actuator — Design Plan

> **All parts in this project are designed for 3D printing (FDM/FFF).** Print orientations are chosen to avoid supports where possible — see individual part notes for recommended print orientation.

## Broader Goal

This actuator is part of the **gear-driven pool filter cleaner** system. The full system works as follows:

1. A cylindrical pool filter cartridge (~3 ft long × 9 in diameter) is held **horizontally** on a 3/4" aluminum rod by two filter holders with S6904ZZ bearings, supported by leg bases and leg feet.
2. A **PVC spray pipe** (with a closed end) is mounted horizontally, parallel to the filter. It has **orifices drilled into it ~150 mm (~6") apart**. A garden hose feeds water into the open end of the pipe, and the orifices produce focused spray jets that hit the filter and **rotate it** on the bearings.
3. On the gear-driven end, a **spur gear ring** on one filter holder meshes with a **compound gear** (spur + straight bevel). The bevel pinion drives a **mating bevel gear** that changes axis 90°.
4. A 3/4" aluminum tube is secured (via set screw) through the centre of the mating bevel gear. As the filter spins, it drives this tube in rotation.
5. The **other end** of that same tube connects to a **rotary-to-linear actuator** (crank-slider mechanism). The actuator converts the tube's rotation into a **6-inch (152.4 mm) back-and-forth linear stroke**.
6. A **sleigh/carriage** rides on the actuator and carries the **PVC spray pipe**. The actuator sweeps the pipe back and forth by ~6 inches (one orifice spacing). Because the orifices are spaced ~6" apart and the stroke is also ~6", every point along the filter's length is reached by at least one orifice during a full stroke cycle, giving **complete coverage** of the entire filter.

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

The connecting rod links the crank pin on the wheel to the sleigh/carriage pivot, converting rotary crank motion into push-pull force.

**What was built:**
- **Socket-style design** for hub clearance: cylindrical socket bosses at each end extend downward (toward the wheel face), with an elevated flat bar connecting them on top. This keeps the rod body clear of the hub tube as the wheel rotates.
- **240 mm centre-to-centre** length (≈3.1× crank radius) — keeps slider motion close to sinusoidal with minimal side-loading
- **Big end (crank pin):** 608 2RS bearing press-fit pocket — 22.2 mm bore (bearing OD + 0.2 mm tolerance), ~30.2 mm boss OD (4 mm wall)
- **Small end (carriage pivot):** identical 608 2RS bearing pocket — same 22.2 mm bore, ~30.2 mm boss OD. The carriage's wrist pin (8 mm) passes through this bearing.
- **Stepped bores** at both ends: bearing pocket at full OD from the open end (z=0 to bearing width), then a 16 mm shoulder hole that clears the inner race but seats the outer race. Prevents the bearing from sliding through.
- **Socket height:** 10 mm (bearing width 7 mm + 3 mm)
- **Bar thickness:** 10 mm; **bar width:** 25 mm (narrower than the ~30.2 mm socket ODs for a sleeker profile)
- **3D print orientation:** flat bar face (away-from-wheel side) on bed; sockets extend upward
- **608 2RS bearings at both ends** for low-friction pivoting — bearing inner race rides on the pin, outer race press-fits into the socket
- **Triangular gusset wedges** on the inside face of each socket (big-end toward small-end, small-end toward big-end). Gusset base penetrates into the socket cylinder so there's no visible seam. Parameters: `con_rod_gusset_length` = 10 mm, `con_rod_gusset_width` = 10 mm.
- Assembly: rod is positioned on the crank pin at the correct swing angle for an inline slider-crank, with the socket bottom sitting 1 mm above the crank-pin fillet
- A **4-state `crank_position` parameter** (0 = Top, 1 = Right, 2 = Bottom, 3 = Left) rotates the wheel and repositions the connecting rod so it stays attached to the crank pin at each position. This is used for **visual inspection** at each extreme crank angle to verify clearances, stroke limits, and rod alignment before printing.

---

### Step 3 — Frame / Mounting Bracket (with integrated guide rails) ✅ DONE

**File:** `rotary_to_linear_actuator/rotary_to_linear_nozzle_actuator.scad` (same file, `frame_bracket()` module)

The frame bracket is a stationary plate on the −Z side of the wheel that houses a bearing for the tube and provides guide-rod support walls for the sleigh.

**What was built:**
- **Main plate:** Trapezoidal — 250 mm wide at bottom (X), narrowing to 70 mm (`2 × frame_light_hole_diameter`) at top, × 12 mm thick, with 10 mm rounded corners. Uniform thickness throughout.
- **Plate Y span:** extends from `frame_plate_y_min` (5 mm below wheel bottom) to `frame_plate_y_max` (5 mm above wheel top). Bottom edge is full width (250 mm); top edge is narrower (70 mm) to save material where less support is needed.
- **Trapezoidal shape** implemented via `hull()` of four corner cylinders; `frame_half_width_at_y()` function provides linear interpolation for lightening-hole boundary checks
- **Guide walls** remain at `frame_width` = 70 mm Y extent (centred on tube axis), independent of the wider plate
- **S6904ZZ bearing pocket** recessed from the +Z face at the tube centre, with ring cutout below (same technique as `filter_holder.scad`) to prevent the rotating inner race from rubbing
- **Tube through-hole** with 2 mm clearance (bearing provides alignment)
- **Two guide-rod support walls** (10 mm thick × 23 mm tall) at x = 100 and x = 380, each with two 8.3 mm holes for 8 mm smooth steel rods at 50 mm Y spacing
- **Guide rod centre** at 12 mm above frame +Z face
- **Wall 1 (near wheel):** Rounded top edges in the XZ plane (perpendicular to frame); straight bottom edge where it meets the frame surface. No vertical Y-corner rounding.
- **Wall 2 (far end):** Same XZ-rounded top edges. Far edge (at frame edge) additionally has vertical Y-corner rounding to match the frame's rounded corners, achieved via `intersection()` of the XZ-rounded shape with a Y-corner-rounded shape.
- **Triangular gussets** on the inside face of each wall (wall 1 toward +X, wall 2 toward −X), penetrating into the wall body to avoid visible seams. `frame_gusset_length` = 20 mm, `frame_gusset_width` = 10 mm.
- Frame sits with a 2 mm air gap below the wheel's −Z face
- Main plate uses trapezoidal `hull()` with `frame_edge_radius` = 10 mm rounded corners; `frame_top_width` parameter controls top width
- **3D print orientation:** −Z face (flat) on bed; walls print upward, no supports needed
- **Render toggle:** `build_frame_bracket` boolean

---

### Step 4 — Sleigh / Carriage ✅ DONE

**File:** `rotary_to_linear_actuator/rotary_to_linear_nozzle_actuator.scad` (same file, `carriage()` module)

The carriage rides on the two 8 mm guide rods via LM8UU linear bearings and connects to the connecting rod's small end via a wrist pin.

**What was built:**
- **Main body** with rounded vertical edges (`frame_edge_radius` = 3 mm), sized to enclose four LM8UU bearings
- **Body dimensions:** ~76 × 73 × 23 mm (length × width × height), derived from bearing spacing, rod spacing, and wall thickness
- **4 × LM8UU linear bearing pockets** (15.2 mm bore × 24 mm long) — 2 per guide rod, spaced 40 mm apart in X. Each pocket extends to the nearest carriage X face for bearing insertion from outside.
- **Guide rod through-channels** (8.3 mm) running full length of body
- **Wrist pin** on +Z face: 8 mm diameter × 20 mm tall (matches crank pin dimensions), with 14 mm tapered fillet base, centred in XY. Connects to con-rod small-end 608 bearing.
- **Con-rod socket clearance recess:** ~34.2 mm diameter × 3 mm deep circular pocket at the wrist-pin location on the +Z face, so the con-rod small-end socket can nest without colliding with the carriage body
- **Wall thickness:** 4 mm around bearing pockets
- **3D print orientation:** −Z face (flat) on bed; wrist pin extends upward, no supports needed
- **Render toggle:** `build_carriage` boolean
- **PVC pipe clamp:** parameters defined (`pvc_pipe_od` = 26.7 mm, `pvc_clamp_clearance` = 0.5 mm, `pvc_clamp_wall` = 4 mm) but clamp geometry not yet implemented

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

### Step 6 — Visual References ✅ DONE

**File:** `rotary_to_linear_actuator/rotary_to_linear_nozzle_actuator.scad` (assembly section)

Non-printed reference geometry rendered to aid visual inspection of the assembly.

**What was built:**
- **Aluminum tube** (DimGray): hollow cylinder (19.05 mm OD, 1.65 mm wall = standard 3/4″ tube), extending from the hub top through the wheel, spacer ring, and frame bearing, then 150 mm beyond the frame. Rotates with `crank_angle`. Toggle: `show_aluminum_tube`.
- **Guide rods** (Silver): two 8 mm solid cylinders spanning between the guide walls (wall-to-wall). Toggle: `show_guide_rods`.

---

### Step 7 — Assembly & Validation 🔶 PARTIALLY DONE

All components are assembled **inline** in the same `.scad` file (no separate assembly file). The 4-state `crank_position` parameter allows visual inspection at each extreme.

**Completed:**
- All parts positioned correctly relative to each other in a single assembly section
- Crank wheel, connecting rod, spacer ring, frame bracket, and carriage all placed with proper transforms
- Visual references (aluminum tube, guide rods) rendered for context
- 4-state `crank_position` for manual clearance/stroke checks (Top / Right / Bottom / Left)

**Still TODO:**
- Animate the crank rotation (OpenSCAD `$t` variable) for continuous motion verification
- PVC pipe clamp geometry on carriage
- Verify PVC pipe clearance at both stroke extremes
- Export STLs for all actuator components
- Update the project `README.md` with actuator parts BOM

---

## Additional Notes for Copilot Agent

- All models are **OpenSCAD** (`.scad`) and use the **BOSL2** library for gears and other advanced geometry (`include <BOSL2/std.scad>`, `include <BOSL2/gears.scad>`) in the filter holder files. The actuator file does **not** currently use BOSL2.
- Use `$fn = 80` for normal work (current setting), `$fn = 180` for final renders, `$fn = 60` for fast previews
- All dimensions are in **millimetres**
- The project convention is to use **set-screw holes** (M4 / 3.4 mm diameter, 85% of nominal for self-threading into plastic) to secure aluminum tubes in hubs
- Bearings used: **S6904ZZ** (37 mm OD × 20 mm ID × 9 mm thick) for tube support in frame and filter holders; **608 2RS** (22 mm OD × 8 mm bore × 7 mm width) for crank pin and wrist pin pivots; **LM8UU** (15 mm OD × 8 mm bore × 24 mm long) for carriage linear motion on guide rods
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
- **Carriage:** −Z face at z=0 (print bed); guide rods at z = `carriage_rod_z`
- **Spacer ring:** −Z face at z=0 (print bed)

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
