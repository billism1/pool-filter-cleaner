# render_leg_base_4_legs.ps1
# Render leg_base_4_legs.scad: one STL per permutation of
# horizontal_through_hole_both_sides.
#
# Usage:  powershell -ExecutionPolicy Bypass -File render_leg_base_4_legs.ps1
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'render_common.ps1')

$ctx    = Resolve-OpenScad
$root   = $PSScriptRoot
$outDir = Join-Path $root 'STLs'
$scad   = Join-Path $root 'leg_base\leg_base_4_legs.scad'

$jobs = @()
foreach ($both in @('true', 'false')) {
    $jobs += @{
        Src  = $scad
        Out  = "leg_base_4_legs_both_sides-$both.stl"
        Defs = @('-D', "horizontal_through_hole_both_sides=$both")
    }
}

exit (Invoke-ScadRenders -Jobs $jobs -Exe $ctx.Exe -CommonArgs $ctx.CommonArgs -OutDir $outDir)
