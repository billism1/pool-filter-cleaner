# render_leg_base_2_legs_top_insert.ps1
# Render leg_base_2_legs_top_insert.scad (single variant).
#
# Usage:  powershell -ExecutionPolicy Bypass -File render_leg_base_2_legs_top_insert.ps1
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'render_common.ps1')

$ctx    = Resolve-OpenScad
$root   = $PSScriptRoot
$outDir = Join-Path $root 'STLs'

$jobs = @(
    @{ Src = (Join-Path $root 'leg_base\leg_base_2_legs_top_insert.scad');
       Out = 'leg_base_2_legs_top_insert.stl'; Defs = @() }
)

exit (Invoke-ScadRenders -Jobs $jobs -Exe $ctx.Exe -CommonArgs $ctx.CommonArgs -OutDir $outDir)
