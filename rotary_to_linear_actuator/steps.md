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

**File:** `rotary_to_linear_actuator/rotary_to_linear_actuator.scad`

The crank wheel connects to the 3/4" aluminum tube from the mating bevel gear and converts its rotation into crank motion via a pin offset from centre.

**What was built:**
- Disc wheel, **~182.4 mm diameter**, 12 mm thick
- Central hub (31.55 mm OD) bored for 19.55 mm tube, extending **only on the +Z (crank-pin) side** by 10 mm for 3D-print-friendliness (−Z face is flat = print bed)
- Two **M4 set-screw holes** (180° apart) on the +Z hub extension, for clamping the tube
- **Crank pin**: 8 mm diameter (sized for 608 2RS bearing bore) × 20 mm tall, at 76.2 mm radius from centre, with a 14 mm tapered fillet base
- **6 circular lightening holes** (35 mm diameter each) evenly spaced around the disc (same style as mating bevel gear drain holes)
- **Orientation:** tube bore runs along **Y axis** (parallel to the XY bottom plane / ground); wheel disc stands vertically in XZ plane; bottom rim sits on Z = 0

---

### Step 2 — Connecting Rod ✅ DONE

**File:** `rotary_to_linear_actuator/rotary_to_linear_actuator.scad` (same file as crank wheel)

The connecting rod links the crank pin on the wheel to the sleigh/carriage pivot, converting rotary crank motion into push-pull force.

**What was built:**
- **Socket-style design** for hub clearance: cylindrical socket bosses at each end extend downward (toward the wheel face), with an elevated flat bar connecting them on top. This keeps the rod body clear of the hub tube as the wheel rotates.
- **200 mm centre-to-centre** length (≈2.6× crank radius) — keeps slider motion close to sinusoidal with minimal side-loading
- **Big end (crank pin):** 608 2RS bearing press-fit pocket — 22.2 mm bore (bearing OD + 0.2 mm tolerance), ~30.2 mm boss OD (4 mm wall), through-bore for sliding onto the 8 mm crank pin with bearing
- **Small end (sleigh pivot):** identical 608 2RS bearing pocket — same 22.2 mm bore, ~30.2 mm boss OD. The sleigh’s pivot pin (8 mm) will pass through this bearing.
- **Socket height:** 10 mm (bearing width 7 mm + 1.5 mm shoulder each side)
- **Bar thickness:** 10 mm, hull-tapered between the two boss diameters
- **3D print orientation:** flat bar face (away-from-wheel side) on bed; sockets extend upward
- **608 2RS bearings at both ends** for low-friction pivoting — bearing inner race rides on the pin, outer race press-fits into the socket
- Assembly: rod is positioned on the crank pin at the correct swing angle for an inline slider-crank, with the socket bottom sitting 1 mm above the crank-pin fillet

---

### Step 3 — Guide Rails / Linear Track ⬜ NOT STARTED

Design the linear guide system that constrains the sleigh to move in a straight line.

**Requirements:**
- Must support the **6-inch (152.4 mm) stroke** plus some overtravel margin
- Consider using **two parallel round rails** (e.g. 8 mm steel rods) with printed rail mounts, or a **3D-printed slot/channel** with low friction (PTFE tape or lubricant)
- The rail axis should be **perpendicular to the crank wheel's rotation axis** (i.e. the sleigh moves along the X axis while the wheel spins in the XZ plane)
- Rail mounts need to be anchored to a **base plate or frame** that also supports the crank wheel's axle (the aluminum tube). This keeps everything aligned.
- Consider how the guide rail assembly attaches to the existing leg-base / rod infrastructure of the pool-filter-cleaner frame

---

### Step 4 — Sleigh / Carriage ⬜ NOT STARTED

Design the sleigh (slider) that rides on the guide rails and carries the nozzle.

**Requirements:**
- Linear bearings or bushings for the guide rails (e.g. LM8UU if using 8 mm rods, or printed sliding bushings)
- **Pivot attachment point** on one side for the connecting rod's small end (must allow the rod to swing as the crank rotates)
- **PVC pipe clamp/mount** on the other side — must securely hold the PVC spray pipe horizontal, parallel to the filter. The pipe has orifices drilled ~150 mm apart and a closed far end; the garden hose connects to the open near end.
- The orifices should face the filter (spraying radially into it)
- Consider how the garden hose connects to the PVC pipe on the moving sleigh — a flexible hose loop or coiled section is likely needed to accommodate the 6" travel without kinking
- Should be parametric: rail spacing, PVC pipe OD (for clamp sizing), pivot pin diameter

---

### Step 5 — Frame / Mounting Bracket ⬜ NOT STARTED

Design the structural frame that ties the actuator to the pool-filter-cleaner stand.

**Requirements:**
- Support the crank wheel's tube (the 3/4" aluminum tube is the axle, supported by the existing leg-base system on one end and this frame on the other)
- Mount the guide rails in proper alignment relative to the crank wheel
- May need a bearing or bushing for the tube between the mating bevel gear and the crank wheel hub, to support the span and prevent sag
- Must be rigid enough to resist the reaction forces from the nozzle spray (the spray pushes back on the sleigh, which pushes back through the con-rod into the wheel and frame)
- Consider using the existing `leg_base` model or a variant as the mounting point, since it already has 3/4" tube pockets

---

### Step 6 — Assembly & Validation ⬜ NOT STARTED

Create a combined assembly view and validate the design.

**Tasks:**
- Create an assembly `.scad` file that imports all actuator components positioned correctly relative to each other
- Verify clearances: con-rod doesn't collide with guide rails or frame at any crank angle
- Verify stroke: sleigh travels the full 152.4 mm
- Verify PVC pipe clearance: spray pipe and orifices clear the filter at both stroke extremes
- Animate the crank rotation (OpenSCAD `$t` variable) to visually confirm motion
- Update the project `README.md` to include the actuator parts in the gear-driven version BOM
- Export STLs for all actuator components

---

## Additional Notes for Copilot Agent

- All models are **OpenSCAD** (`.scad`) and use the **BOSL2** library for gears and other advanced geometry (`include <BOSL2/std.scad>`, `include <BOSL2/gears.scad>`)
- Use `$fn = 180` for final renders, `$fn = 60` for fast previews
- All dimensions are in **millimetres**
- The project convention is to use **set-screw holes** (M4 / 3.4 mm diameter, 85% of nominal for self-threading into plastic) to secure aluminum tubes in hubs
- Bearings used elsewhere: **S6904ZZ** (37 mm OD × 20 mm ID × 9 mm thick) — consider the same or similar for the crank pin and sleigh pivots if plain bushings prove too lossy
- The **spray element is a PVC pipe** (not the fan-out nozzle in `nozzle/`). The pipe is mounted horizontally on the sleigh, parallel to the filter, with orifices drilled ~150 mm (~6") apart and a closed far end. The garden hose connects to the open end. The sleigh moves the pipe back and forth by one orifice spacing (~6") so the jets sweep the entire filter length.
- The tube connecting the mating bevel gear to the crank wheel needs to be long enough to clear the filter cartridge and legs; typical filter length is ~3 ft (914 mm), so this tube may be 12–18 inches (300–450 mm)
- Water pressure is the **sole power source** — the mechanism must have low enough friction that the torque transmitted through the gear train from the spinning filter is sufficient to drive the actuator
