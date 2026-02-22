# Pool Filter Cleaner

A 3D-printable pool filter cleaning system designed to efficiently clean cylindrical pool filters by spraying them while they rotate. This system allows for thorough cleaning of pool filter cartridges without manual scrubbing.

**Attribution / Inspiration:** This horizontal pool filter cleaner was inspired by the vertical pool filter cleaner on MakerWorld: https://makerworld.com/en/models/1333859-pool-filter-washing-stand. I based some parts in this project on that design and used OpenSCAD to create all 3D models for the horizontal stand in this repository.

## Quick Reference

| Component | SCAD File | STL Location | Quantity Needed |
|-----------|-----------|--------------|-----------------|
| **Filter Holder (Core Set, Standard)** | `filter_holder/filter_holder.scad` | `STLs/filter_holder.stl` | 2 |
| **Leg Base (2-leg, Core Set)** | `leg_base/leg_base_2_legs.scad` | `STLs/leg_base_2_legs-through_hole.stl` and `STLs/leg_base_2_legs-closed_end.stl` | 2 |
| **Leg Base (4-leg, Alternative)** | `leg_base/leg_base_4_legs.scad` | `STLs/leg_base_4_legs.stl` | 2 (alternative setup) |
| **Leg Foot (Core Set)** | `leg_foot/leg_foot.scad` | `STLs/leg_foot.stl` | 2 |
| **Garden Hose Nozzle (Optional)** | `nozzle/nozzle/garden_hose_nozzle-5-prong-fan-out.scad` | `STLs/garden_hose_nozzle-5-prong-fan-out.stl` | 1 |

**Leg base STL note:** For `leg_base/leg_base_2_legs.scad`, the included exports are:
- `STLs/leg_base_2_legs-through_hole.stl` (`horizontal_through_hole_both_sides = true`)
- `STLs/leg_base_2_legs-closed_end.stl` (`horizontal_through_hole_both_sides = false`)

**Core solution note:** `filter_holder` + `leg_base` + `leg_foot` are an atomic set and are intended to be used together. The nozzle is optional/experimental; any effective high-force nozzle stream can be used.

**Additional Hardware Needed:**
- 2× S6904ZZ ball bearings (37mm × 20mm × 9mm)
- 1× Horizontal 3/4" aluminum rod (36-40" length)
- 4× Leg support 3/4" aluminum rods (24-36" length each)
- Optional: up to 6× M4 set screws (holes are already included in the models if you want to use them)

## Overview

This project provides a complete solution for cleaning cylindrical pool filters (typically 3 feet long × 9 inches diameter). The core system is a rotating support assembly (`filter_holder` + `leg_base` + `leg_foot`) that spins the filter during cleaning. The included nozzle model is optional and experimental.

### Key Features

- **Optional nozzle support** - Included nozzle is experimental; any strong, focused nozzle stream works
- **Rotating support system** - Allows filter to spin freely during cleaning
- **Modular aluminum rod construction** - Accommodates various filter lengths
- **Stable leg-base support design** - Provides secure support during operation
- **Standard garden hose compatibility** - 3/4" GHT threading

## Components & Design Files

### 1. Filter Holder

**File:** `filter_holder/filter_holder.scad`  
**STL Output:** `STLs/filter_holder.stl`  
**Additional variants in `STLs/`:** `filter_holder_double_bearing.stl`, `filter_holder_double_bearing_with_gear.stl`

**WIP note:** `filter_holder_double_bearing.stl` and `filter_holder_double_bearing_with_gear.stl` are work in progress and not recommended for active use at this time.

The filter holder attaches to the pool filter cartridge and provides the mounting point for the support rod. This component includes an integrated bearing holder for smooth rotation.

**Key Features:**
- Tapered plug (76.2mm diameter) that fits snugly into the 3" filter opening
- Large flange (140mm diameter) that sits outside the filter
- Six 1-inch (25.4mm) drainage holes evenly spaced around the flange
- Bearing holder tube extension for S6904ZZ bearing (37mm OD × 20mm ID × 9mm thick)
- 4mm thick walls around bearing holder
- Ring cutout inside bearing area for clearance (starts 0.633mm from rod hole, 2.5mm thick, 2mm deep)
- 3mm diameter screw hole through bearing holder walls for securing bearing
- Central 19.05mm (3/4") hole for aluminum support rod
- All dimensions in millimeters

**Bearing Specifications:**
- S6904ZZ Ball Bearing: Stainless steel, double shielded, deep groove
- Dimensions: 37mm OD × 20mm ID × 9mm thick
- Allows filter to spin freely on the stationary aluminum rod

**Important:** Print TWO of these holders - one for each end of the filter.

### 2. Leg Base / Support Stand

**Primary file:** `leg_base/leg_base_2_legs.scad`  
**Alternative file:** `leg_base/leg_base_4_legs.scad`  
**STL Outputs:** `STLs/leg_base_2_legs-through_hole.stl`, `STLs/leg_base_2_legs-closed_end.stl`, `STLs/leg_base_4_legs.stl`

A leg-base connector that forms the base of the rotating support system. Supports both 2-leg and 4-leg stand configurations.

**Specifications:**
- Designed for 3/4" (19.05mm) aluminum rods
- Horizontal tube (40mm length) for main filter rod
- Two leg tubes (47.85mm length each) angled at 45° downward
- Legs positioned 90° apart from each other
- 12° inward tilt on legs for bearing pressure toward filter
- 6mm wall thickness for structural strength
- Integrated bearing lip (2mm thick, 2mm extension) with curved flare
- Curved printing base for stable bed adhesion
- Set screw holes (4mm diameter) in all three tubes for rod retention
- Rod holes extend 35mm deep into leg tubes
- Requires BOSL2 library for advanced geometry operations

**2-leg export variants:**
- Export one STL with `horizontal_through_hole_both_sides = true`
- Export a second STL with `horizontal_through_hole_both_sides = false`

**4-leg vertical stand note:**
- `leg_base/leg_base_4_legs.scad` can also be used in a vertical stand setup similar to the referenced MakerWorld project: https://makerworld.com/en/models/1333859-pool-filter-washing-stand
- For best results in that vertical configuration, pair it with the MakerWorld project's bottom piece so a bearing contacts the top lip of the leg holder.

**Dependencies:**
- BOSL2 library (https://github.com/BelfrySCAD/BOSL2) - Advanced geometry and rounding functions

**Test/Development Files:**
- `leg_base/testing/base_test.scad` - Test variations of base geometry
- `leg_base/testing/curved_base.scad` - Development file for curved base design

**Important:** Print TWO of these bases - one for each end of the horizontal filter rod.

### 3. Leg Foot

**File:** `leg_foot/leg_foot.scad`  
**STL Output:** `STLs/leg_foot.stl`

Leg feet pair with the leg-base tubes and are part of the core support set.

**Important:** Print TWO leg feet and use them with the matching holder/base set.

### 4. Garden Hose Nozzle (Optional / Experimental)

#### Main Design File
**File:** `nozzle/nozzle/garden_hose_nozzle-5-prong-fan-out.scad`  
**STL Output:** `STLs/garden_hose_nozzle-5-prong-fan-out.stl`

This nozzle design is optional and experimental. You can use any nozzle that provides an adequately forceful stream for cleaning.

**Recommended print/process for watertightness:**
- Print the nozzle in ABS or ASA (recommended)
- Acetone vapor smooth both the inside and outside surfaces after printing
- This helps eliminate layer-line seepage; in ASA testing, small water beads/leaks through print lines stopped after vapor smoothing

**Specifications:**
- 3/4" female garden hose threading (GHT)
- 5 outlet nozzles with 1.72mm diameter openings
- Total outlet area: 11.69 mm²
- Hex grip ring for easy tightening (toggleable)
- Smooth hydrodynamic internal transitions for optimal water distribution
- Multi-stage hull transitions from cylinder to individual cone nozzles

**Dependencies:**
- `nozzle/nozzle/Threading.scad` - Library for generating 3/4" GHT female threads
- `nozzle/nozzle/Naca_sweep.scad` - Sweep and extrusion library for complex geometry

### Library Files

#### Threading.scad
**File:** `nozzle/nozzle/Threading.scad`

Comprehensive threading library by Rudolf Huttary (Berlin, 2016-2021) for generating various thread types in OpenSCAD.

**Capabilities:**
- Standard metric threads (ISO)
- ACME threads
- Multiple helix threads
- Left-hand and right-hand threads
- Customizable pitch, diameter, windings, and thread angle
- Used for generating 3/4" GHT (Garden Hose Thread) in nozzle designs

**Key Functions:**
- `threading()` - Creates a threaded rod or bolt
- `Threading()` - Creates a threaded nut or female thread

#### Naca_sweep.scad
**File:** `nozzle/nozzle/Naca_sweep.scad`

Sweep and extrusion library by Rudolf Huttary (2015-2020) for creating complex 3D shapes from 2D profiles.

**Capabilities:**
- Sweep 2D profiles along 3D paths
- Create smooth transitions between different cross-sections
- Skin multiple polygons together
- Matrix/vector transformations (translation, rotation, scaling)
- Path subdivision for smooth curves

**Key Functions:**
- `sweep()` - Main sweep/extrusion function
- `sweep_path()` - Sweep a shape along a path
- Affine transformations: `T()`, `R()`, `S()` for translate, rotate, scale

## Assembly Overview

The complete cleaning system consists of:

### Hardware Requirements
1. **Two 3D-printed filter holders** (`filter_holder/filter_holder.scad`)
   - Install one on each end of the filter cartridge
   
2. **Two 3D-printed leg bases** (`leg_base/leg_base_2_legs.scad`)
   - Position one at each end of the horizontal support rod

3. **Two 3D-printed leg feet** (`leg_foot/leg_foot.scad`)
   - Install on the ends of the inserted leg rods
   
4. **Optional 3D-printed garden hose nozzle** (`nozzle/nozzle/garden_hose_nozzle-5-prong-fan-out.scad`)
   - Optional experimental nozzle; any nozzle with an adequately forceful stream works
   
5. **Two S6904ZZ stainless steel ball bearings**
   - 37mm OD × 20mm ID × 9mm thick
   - One for each filter holder
   
6. **One horizontal 3/4" (19.05mm) aluminum rod**
   - Length varies based on filter size (typically 36-40" for standard filters)
   - Passes through bearing holders and leg bases
   
7. **Four 3/4" (19.05mm) aluminum rod legs**
   - Two legs per base (four total for both ends)
   - Length depends on desired working height (typically 24-36")
   
8. **Optional set screws** (M4 or #8-32)
   - Holes are already included in the printed models if you want to secure rods in filter holders and leg bases
   - Up to six screws total (one per tube connection)

### Assembly Steps

1. **Prepare filter holders:**
   - Press S6904ZZ bearings into the bearing holder tubes on each filter holder
   - Secure bearings with 3mm screws through side holes
   
2. **Mount filter holders to filter:**
   - Insert tapered plugs into both ends of the pool filter cartridge
   - The flanges should sit flat against the filter ends
   - Water drainage occurs through the six holes in each flange
   
3. **Install horizontal rod:**
   - Slide the horizontal 3/4" aluminum rod through both filter holders
   - The rod passes through the bearings, allowing the filter to rotate freely
   - Adjust rod position to center the filter
   
4. **Attach leg bases:**
   - Slide one leg base onto each end of the horizontal rod
   - Position them outside the filter holders
   - Optional: tighten set screws in the horizontal tubes to secure bases
   
5. **Install support legs:**
   - Insert two 3/4" aluminum rods into the angled leg sockets on each base
   - Adjust leg extension for desired working height
   - Optional: tighten set screws to secure legs
   
6. **Connect nozzle (optional):**
   - Attach the included 5-prong nozzle or any suitable high-force nozzle to your garden hose
   - Hand-tighten using the hex grip ring (if using the included model)
   
7. **Operation:**
   - Position the assembly on level ground
   - Turn on water supply
   - Manually rotate the filter or let water pressure cause rotation
   - The five concentrated jets clean the filter pleats thoroughly

The bearings allow the filter to spin freely on the stationary aluminum rod while water jets from the nozzle clean the exterior.

## 3D Printing Instructions

### General Settings
- **Material:** PETG or ABS recommended for outdoor durability and chemical resistance
  - PETG: Easier to print, good UV resistance, excellent layer adhesion
  - ABS: Higher temperature resistance, more rigid, requires heated enclosure
- **Infill:** 30-40% for structural components (leg bases, filter holders), 20-30% for nozzle
- **Layer Height:** 0.2mm standard, 0.15mm for higher detail
- **Print Speed:** 40-60mm/s for best quality
- **Supports:** Minimal - most designs optimized for support-free printing

### Component-Specific Notes

#### Filter Holder
- **Orientation:** Print with flange side down (largest flat surface on build plate)
- **Supports:** None required - bearing holder and drain holes designed to print without supports
- **Post-Processing:** Clean any stringing from drain holes and bearing holder

#### Leg Base
- **Orientation:** Print with curved base on build plate (already optimized for this orientation)
- **Supports:** None required - design includes integrated printing base that gets cut off
- **Post-Processing:** May need to drill set screw holes to final size depending on printer precision

#### Garden Hose Nozzle
- **Orientation:** Print with threaded end down (flat surface on build plate)
- **Supports:** Minimal supports may be needed for underside of hex grip ring
- **Thread Quality:** Ensure $fn is set to 180 or higher for smooth threads
- **Material Recommendation:** ABS or ASA for best water sealing performance
- **Post-Processing:** Use acetone vapor smoothing on both inside and outside surfaces to reduce/close layer-line seepage, then test thread fit with garden hose

### Quality Tips
1. **First Layer:** Critical for all parts - ensure proper bed leveling and adhesion
2. **Thread Testing:** Print a small thread test piece before committing to full nozzle print
3. **Bearing Fit:** Filter holder bearing pocket should be snug - may need light sanding for perfect fit
4. **Rod Holes:** Should allow smooth sliding of 3/4" aluminum rod - sand lightly if too tight
5. **Layer Adhesion:** Important for water-tight performance of nozzle - avoid drafts and temperature fluctuations

## Usage & Operation

### Setup
1. **Assemble the base structure** with aluminum rods and 3D-printed leg bases
2. **Install bearings** into filter holders and secure with set screws
3. **Mount filter holders** on both ends of the pool filter cartridge
4. **Thread horizontal rod** through filter holders and bearings
5. **Attach leg bases** to rod ends (optional set screws can be used via the built-in holes)
6. **Insert support legs** into angled sockets (optional set screws can be used via the built-in holes)
7. **Level the assembly** on flat ground, adjust leg heights if needed

### Cleaning Operation
1. **Connect nozzle** (included optional model or any suitable high-force nozzle) to garden hose with good water pressure (30-50 PSI recommended)
2. **Position nozzle** 6-12 inches from filter surface
3. **Turn on water** - the five jets will spray concentrated streams across the filter
4. **Rotate the filter** manually or allow water pressure to spin it on the bearings
5. **Move nozzle** along the length of the filter for complete coverage
6. **Continue until clean** - typically 2-5 minutes per filter depending on debris level

### Maintenance
- **After each use:** Rinse nozzle to prevent buildup
- **Weekly (if using set screws):** Check set screws and tighten if needed
- **Monthly:** Inspect bearings for smooth rotation, clean if necessary
- **Annually:** Check 3D-printed parts for wear or UV damage

### Safety Notes
- Always use on level ground to prevent tipping
- If using set screws, ensure they are tight before adding water pressure
- Do not exceed 80 PSI water pressure to avoid damaging components
- Keep electrical equipment away from water spray area

## Design Software & Dependencies

### OpenSCAD
All components are designed in **OpenSCAD** (parametric 3D CAD modeler), allowing for easy customization and adjustments for different filter sizes or rod diameters.

**Download:** https://openscad.org/

**Recommended Version:** OpenSCAD 2021.01 or newer

### Required Libraries

#### BOSL2 (for leg base SCAD files)
**Repository:** https://github.com/BelfrySCAD/BOSL2  
**Purpose:** Advanced geometric operations, rounding, and shape manipulation  
**Installation:** 
1. Download or clone the BOSL2 repository
2. Place in OpenSCAD's library path or in the project directory
3. The leg base files use `include <BOSL2/std.scad>`

#### Threading.scad (included)
**Location:** `nozzle/nozzle/Threading.scad`  
**Purpose:** Generate GHT and other thread types  
**Author:** Rudolf Huttary, Berlin (2016-2021)  
**Note:** Already included in project, no separate installation needed

#### Naca_sweep.scad (included)
**Location:** `nozzle/nozzle/Naca_sweep.scad`  
**Purpose:** Sweep and extrusion operations for complex geometry  
**Author:** Rudolf Huttary, Berlin (2015-2020)  
**Note:** Already included in project, no separate installation needed

### Rendering Settings

For quick previews during development:
```openscad
$fn = 60;  // Lower resolution, faster rendering
```

For final STL export:
```openscad
$fn = 180;  // Higher resolution, smoother curves
```

Each file has its `$fn` parameter clearly marked at the top for easy adjustment.

## Project Status

### Completed Components ✅
- **Garden hose nozzle** - Optional experimental add-on
  - 5-prong fan-out configuration optimized for filter cleaning
  - GHT threading with hex grip for easy installation
   - Any adequately forceful nozzle stream can be used instead
  
- **Filter holder** - Complete design with bearing integration
  - Tapered plug fits standard 3" pool filter openings
  - Integrated S6904ZZ bearing holder with retention screw
  - Drainage holes for water flow
  - Ring cutout for proper bearing clearance
  
- **Leg base / Support stand** - Fully designed and ready for printing
   - 2-leg and 4-leg connector variants available
  - Curved printing base for stability
  - Bearing lip for smooth rotation interface
  - Set screw holes for secure rod retention

### Documentation 📋
- ✅ Component specifications documented
- ✅ File organization and purposes documented
- ✅ Assembly instructions provided
- ✅ Hardware requirements listed
- ✅ Printing parameters specified
- 🚧 Photos/renders of assembled system - Pending
- 🚧 Video demonstration - Pending

### Future Enhancements 💡
- Extended reach nozzle variants for larger filters
- Motorized rotation option
- Alternative bearing holder designs for different bearing sizes
- Adjustable height leg bases
- Integrated tool holder for maintenance accessories

## License

This project is open-source. Feel free to modify and improve the designs for your own use.
