# Horizontal Spinning Pool Filter Cleaning Stand

Cleaning a pool cartridge filter is slow going by hand. This stand holds the filter horizontally on a single rod and lets it spin freely on bearings, so you just point a hose nozzle at it and let the water do the work. The filter spins up fast, the spray drives down into the pleats, and the centrifugal force from the spinning helps fling debris out of the filter. A typical filter cleans up in a few minutes.

I designed and modeled every part myself in OpenSCAD, working from measurements I took of my own filters and equipment. It is sized for standard cylindrical cartridge filters (roughly 3 ft long by 9 in diameter, with about a 3 in center opening).

Every part is fully parametric, so it can be customized extensively. Filter diameter, plug size, rod diameter, bearing pocket, leg length and angle, drainage holes, and more are all driven by variables in the source. Full source files, all the print variants, and the build docs are on GitHub: https://github.com/billism1/pool-filter-cleaner

## How it works

The filter lies on its side, supported at both ends. A printed filter holder presses into each end of the cartridge, and a sealed ball bearing seats in each holder. A single aluminum rod runs straight through both holders and bearings, and the rod is held fixed by two leg bases on the ground. When you spray the filter it spins freely on the bearings while the rod stays still.

One leg base is a closed cradle and the other is an open-top cradle, so you can load the whole filter and rod assembly by laying it into the stand from above instead of threading it in end first. Everything is press fit. Set screw holes are built in if you ever want them, but most builds do not need them.

## What you print

This is the set I print and use:

- 2x filter holder (`filter_holder_interior-false_exterior-true.stl`), one pressed into each end of the filter
- 1x closed-end leg base (`leg_base_2_legs_both_sides-false.stl`)
- 1x open-top cradle leg base (`leg_base_2_legs_top_insert.stl`)
- 4x leg foot (`leg_foot.stl`), one capping each leg rod
- Optional: 1x garden hose nozzle (`garden_hose_nozzle-5-prong-fan-out.stl`)

A pre-arranged `pool-filter-cleaner.3mf` with all of these laid out across plates is included, so you can drop it straight into your slicer.

## What you supply (hardware)

- 2x S6904ZZ ball bearings (37 mm OD x 20 mm ID x 9 mm)
- 1x 3/4 in (19.05 mm) aluminum rod for the main filter axle, about 36 to 40 in long
- 4x 3/4 in (19.05 mm) aluminum rods for the legs, about 24 to 36 in each (set your working height)
- Optional: up to 6x M4 set screws
- A garden hose with a forceful nozzle. The included 5 jet nozzle is optional; any nozzle with a strong, focused stream works.

## Print settings

- Material: PETG or ABS for outdoor durability and chemical resistance
- Layer height: 0.2 mm
- Infill: 30 to 40 percent for the holders and bases
- Supports: not needed. Print the filter holders flange side down and the leg bases on their curved base.

## Optional spray nozzle

I include an optional garden hose compatible spray nozzle (3/4 in GHT) with five fanned out jets aimed at the filter. It is a nice extra, but any nozzle with a strong, focused stream works just as well.

Print the nozzle in ASA or ABS and acetone vapor smooth the inside and outside surfaces. Without smoothing, small droplets of water slowly seep right through the print lines in the material. The vapor smoothing closes those layer lines and stops the seepage.

## Assembly

1. Press a bearing into each filter holder.
2. Press a filter holder into each end of the cartridge.
3. Slide the aluminum rod through both holders and bearings.
4. Set the rod into the two leg bases, dropping one end into the open-top cradle.
5. Push a leg rod into each leg socket and cap each with a leg foot. Level it on the ground.
6. Connect your hose nozzle, turn on the water, and spray along the filter while it spins. Roughly 2 to 5 minutes per filter depending on how dirty it is.

## Notes

- Keep water pressure reasonable (do not exceed about 80 PSI) to protect the printed parts.
- This is an independent, personal, non commercial project. Source files are in OpenSCAD if you want to remix or resize.

## Credits

Designed and modeled by me in OpenSCAD from my own measurements. The optional nozzle uses the Threading and Naca_sweep OpenSCAD libraries by Rudolf Huttary (Berlin). The leg bases use the BOSL2 library.
