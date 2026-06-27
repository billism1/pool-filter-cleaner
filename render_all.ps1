# render_all.ps1
# Render selected .scad files to STLs in the STLs\ folder.
# Some files render multiple variants by overriding parameters with -D.
# Existing STLs of the same name are overwritten.
#
# Usage:  powershell -ExecutionPolicy Bypass -File render_all.ps1

$ErrorActionPreference = 'Stop'

$root   = Split-Path -Parent $MyInvocation.MyCommand.Definition
$outDir = Join-Path $root 'STLs'

# Locate the OpenSCAD executable. Prefer the Nightly build when present:
# it is newer and ships the more robust 'manifold' geometry backend.
$candidates = @(
    'C:\Program Files\OpenSCAD (Nightly)\openscad.exe',
    'C:\Program Files\OpenSCAD\openscad.exe'
)
$openscad = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $openscad) {
    $openscad = (Get-Command openscad -ErrorAction SilentlyContinue).Source
}
if (-not $openscad) {
    Write-Error 'OpenSCAD executable not found. Install it or add it to PATH.'
}

# Detect optional capabilities by probing --help, rather than parsing the
# version string. Args supported here are applied to every render below.
#   --backend=manifold : 2023.06+; far more robust for BOSL2 rounding ops
#                        (the curved_printing_base in the leg_base files).
#                        Absent on old builds (e.g. 2021.01) -> omitted.
#
# Capture help text via Start-Process to temp files. Old OpenSCAD prints its
# banner to stderr; piping `& openscad --help 2>&1` would wrap that as a
# NativeCommandError which, under $ErrorActionPreference='Stop', aborts the
# whole script. Redirecting to files sidesteps PowerShell's error wrapping.
$helpOut = [System.IO.Path]::GetTempFileName()
$helpErr = [System.IO.Path]::GetTempFileName()
Start-Process -FilePath $openscad -ArgumentList @('--help') `
    -NoNewWindow -Wait -RedirectStandardOutput $helpOut -RedirectStandardError $helpErr | Out-Null
$helpText = (Get-Content $helpOut -Raw -ErrorAction SilentlyContinue) +
            (Get-Content $helpErr -Raw -ErrorAction SilentlyContinue)
Remove-Item $helpOut, $helpErr -ErrorAction SilentlyContinue

$commonArgs = @()
if ($helpText -match '(?m)^\s*--backend\b') {
    $commonArgs += '--backend=manifold'
    Write-Host "OpenSCAD: $openscad  (manifold backend enabled)" -ForegroundColor Cyan
} else {
    Write-Host "OpenSCAD: $openscad  (legacy build; no --backend support)" -ForegroundColor Yellow
}

# Ensure the output folder exists.
if (-not (Test-Path $outDir)) {
    New-Item -ItemType Directory -Path $outDir | Out-Null
}

# Build the render jobs.
# Src is relative to $root. Defs are -D overrides. Out is the STL file name.
$jobs = @()

# filter_holder.scad: one STL per permutation of the two bearing-placement flags.
foreach ($interior in @('true', 'false')) {
    foreach ($exterior in @('true', 'false')) {
        $jobs += @{
            Src  = 'filter_holder\filter_holder.scad'
            Out  = "filter_holder_interior-$interior`_exterior-$exterior.stl"
            Defs = @('-D', "place_bearing_at_holder_interior=$interior",
                     '-D', "place_bearing_at_holder_exterior=$exterior")
        }
    }
}

# leg_foot.scad: single variant.
$jobs += @{ Src = 'leg_foot\leg_foot.scad'; Out = 'leg_foot.stl'; Defs = @() }

# leg_base_2_legs_top_insert.scad: single variant.
$jobs += @{ Src = 'leg_base\leg_base_2_legs_top_insert.scad'; Out = 'leg_base_2_legs_top_insert.stl'; Defs = @() }

# leg_base_2_legs.scad: one STL per permutation of horizontal_through_hole_both_sides.
foreach ($both in @('true', 'false')) {
    $jobs += @{
        Src  = 'leg_base\leg_base_2_legs.scad'
        Out  = "leg_base_2_legs_both_sides-$both.stl"
        Defs = @('-D', "horizontal_through_hole_both_sides=$both")
    }
}

# leg_base_4_legs.scad: one STL per permutation of horizontal_through_hole_both_sides.
foreach ($both in @('true', 'false')) {
    $jobs += @{
        Src  = 'leg_base\leg_base_4_legs.scad'
        Out  = "leg_base_4_legs_both_sides-$both.stl"
        Defs = @('-D', "horizontal_through_hole_both_sides=$both")
    }
}

$failed = 0
foreach ($job in $jobs) {
    $src = Join-Path $root $job.Src
    $stl = Join-Path $outDir $job.Out
    Write-Host "Rendering $($job.Src) -> STLs\$($job.Out)"

    $errFile = [System.IO.Path]::GetTempFileName()
    $proc = Start-Process -FilePath $openscad `
        -ArgumentList ($commonArgs + $job.Defs + @('-o', $stl, $src)) `
        -NoNewWindow -Wait -PassThru -RedirectStandardError $errFile

    if ($proc.ExitCode -ne 0) {
        $failed++
        Write-Host "  FAILED (exit $($proc.ExitCode))" -ForegroundColor Red
        Get-Content $errFile | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    } else {
        Write-Host "  OK" -ForegroundColor Green
    }
    Remove-Item $errFile -ErrorAction SilentlyContinue
}

Write-Host ''
if ($failed -gt 0) {
    Write-Host "$failed of $($jobs.Count) render(s) failed." -ForegroundColor Red
    exit 1
} else {
    Write-Host "All $($jobs.Count) render(s) written to STLs\." -ForegroundColor Green
}
