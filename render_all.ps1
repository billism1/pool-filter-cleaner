# render_all.ps1
# Run every render_*.ps1 in this folder (one per .scad part), writing STLs to
# the STLs\ folder. Each child script is also runnable on its own.
#
# Usage:  powershell -ExecutionPolicy Bypass -File render_all.ps1
$ErrorActionPreference = 'Stop'

$root = $PSScriptRoot

# Discover the per-part scripts. Exclude this orchestrator and the shared helper.
$scripts = Get-ChildItem -Path $root -Filter 'render_*.ps1' |
    Where-Object { $_.Name -notin @('render_all.ps1', 'render_common.ps1') } |
    Sort-Object Name

if ($scripts.Count -eq 0) {
    Write-Warning "No render_*.ps1 part scripts found in $root"
    return
}

$failed = 0
foreach ($s in $scripts) {
    Write-Host ''
    Write-Host "=== $($s.Name) ===" -ForegroundColor Magenta
    & $s.FullName
    if ($LASTEXITCODE -ne 0) { $failed += $LASTEXITCODE }
}

Write-Host ''
if ($failed -gt 0) {
    Write-Host "$failed render(s) failed across $($scripts.Count) script(s)." -ForegroundColor Red
    exit 1
} else {
    Write-Host "All renders across $($scripts.Count) script(s) written to STLs\." -ForegroundColor Green
}
