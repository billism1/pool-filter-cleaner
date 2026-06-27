# render_garden_hose_nozzle.ps1
# Render garden_hose_nozzle-5-prong-fan-out.scad (single variant).
#
# Usage:  powershell -ExecutionPolicy Bypass -File render_garden_hose_nozzle.ps1
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'render_common.ps1')

$ctx    = Resolve-OpenScad
$root   = $PSScriptRoot
$outDir = Join-Path $root 'STLs'

$jobs = @(
    @{ Src = (Join-Path $root 'nozzle\nozzle\garden_hose_nozzle-5-prong-fan-out.scad');
       Out = 'garden_hose_nozzle-5-prong-fan-out.stl'; Defs = @() }
)

exit (Invoke-ScadRenders -Jobs $jobs -Exe $ctx.Exe -CommonArgs $ctx.CommonArgs -OutDir $outDir)
