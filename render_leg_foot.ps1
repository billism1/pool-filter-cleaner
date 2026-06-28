# render_leg_foot.ps1
# Render leg_foot.scad (single variant).
#
# Usage:  powershell -ExecutionPolicy Bypass -File render_leg_foot.ps1
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'render_common.ps1')

$ctx    = Resolve-OpenScad
$root   = $PSScriptRoot
$outDir = Join-Path $root 'STLs'

$jobs = @(
    @{ Src = (Join-Path $root 'leg_foot\leg_foot.scad'); Out = 'leg_foot.stl'; Defs = @() }
)

exit (Invoke-ScadRenders -Jobs $jobs -Exe $ctx.Exe -CommonArgs $ctx.CommonArgs -OutDir $outDir)
