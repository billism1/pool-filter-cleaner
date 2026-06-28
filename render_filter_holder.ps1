# render_filter_holder.ps1
# Render filter_holder.scad: one STL per permutation of the two bearing flags
# place_bearing_at_holder_interior and place_bearing_at_holder_exterior.
#
# Usage:  powershell -ExecutionPolicy Bypass -File render_filter_holder.ps1
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'render_common.ps1')

$ctx    = Resolve-OpenScad
$root   = $PSScriptRoot
$outDir = Join-Path $root 'STLs'
$scad   = Join-Path $root 'filter_holder\filter_holder.scad'

$jobs = @()
foreach ($interior in @('true', 'false')) {
    foreach ($exterior in @('true', 'false')) {
        $jobs += @{
            Src  = $scad
            Out  = "filter_holder_interior-$interior`_exterior-$exterior.stl"
            Defs = @('-D', "place_bearing_at_holder_interior=$interior",
                     '-D', "place_bearing_at_holder_exterior=$exterior")
        }
    }
}

exit (Invoke-ScadRenders -Jobs $jobs -Exe $ctx.Exe -CommonArgs $ctx.CommonArgs -OutDir $outDir)
