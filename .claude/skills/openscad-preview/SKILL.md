---
name: openscad-preview
description: Render OpenSCAD (.scad) files to PNG from several fixed angles and visually check the result. Use after any change to .scad geometry, or when asked to iterate on / verify a design.
---

# OpenSCAD visual iteration loop

Use `preview_scad.ps1` (repo root). It reuses `Resolve-OpenScad` from `render_common.ps1`, so it picks the same OpenSCAD build as the STL scripts.

## Steps

1. **Render previews** (fast preview mode, PNG only, nothing written into the repo):

   ```powershell
   powershell -ExecutionPolicy Bypass -File preview_scad.ps1 -Scad <path\to\file.scad> -OutDir <scratchpad dir>
   ```

   - Pass `-OutDir` as the session scratchpad. Default is `%TEMP%\scad_preview`.
   - `-Views` picks angles: `iso, iso_back, iso_under, top, bottom, front, back, side`. Default: `iso, iso_back, top, front, side`. Use fewer for quick checks.
   - `-Defs 'name=value',...` overrides SCAD parameters (`-D`) without editing the file.
   - `-Size 1200,900` changes resolution. `-Render` forces a full render (slower; only when preview mode misleads, e.g. boolean artifacts).
   - Output files: `<outdir>\<scadname>_<view>.png`. ECHO/WARNING lines from OpenSCAD are printed.

2. **Look at every PNG** with the Read tool. Do not judge from one angle. Compare against the stated requirements and list concrete mismatches (missing feature, wrong proportion, floating or intersecting parts, wall too thin).

3. **Check numbers, not just pixels.** Images hide small errors. Add `echo("name", value);` for key dimensions (inner diameter, wall, clearance, overall size) and confirm them against the spec in the ECHO output.

4. **Edit the .scad, re-render, repeat.** Stop when the design matches or after ~5 rounds; then report what is left.

5. **Internal features** (bores, clearances, snaps): single views hide them. Temporarily wrap the model in a `difference()` with a large cube to cut a cross-section, render, then remove the cut. Or use `-Defs` with a section toggle if the file has one.

## Notes

- Parameters in these files are tuned for 3D-print tolerances. Don't change clearances or wall thickness unless asked.
- This does not produce STLs. For final STLs use the `render_*.ps1` scripts. This machine's CPU is flagged unreliable for heavy compute (see memory), so do not trust fresh local STL exports without a dimension check.
- Do not commit preview PNGs.
