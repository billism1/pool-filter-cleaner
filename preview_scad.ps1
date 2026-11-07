# preview_scad.ps1
# Render quick PNG previews of a .scad file from several fixed camera angles.
# Meant for visual iteration (Claude Code skill: openscad-preview). Does NOT
# produce STLs; use render_*.ps1 for that.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File preview_scad.ps1 -Scad tube_clip\double_tube_clip.scad
#   ... -Views iso,top -OutDir C:\tmp\prev -Size 1200,900 -Defs 'wall=3','clearance=0.4'
param(
    [Parameter(Mandatory)] [string]   $Scad,
    [string[]] $Views  = @('iso', 'iso_back', 'top', 'front', 'side'),
    [string]   $OutDir = (Join-Path $env:TEMP 'scad_preview'),
    [int[]]    $Size   = @(1000, 800),
    [string[]] $Defs   = @(),          # name=value pairs, passed as -D
    [switch]   $Render                 # full CGAL/manifold render instead of fast preview
)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'render_common.ps1')

# rx,ry,rz camera rotations. OpenSCAD: rx=90 looks along +Y (front), rx=0 looks down.
$viewTable = @{
    iso      = '55,0,25'
    iso_back = '55,0,205'
    iso_under= '125,0,25'
    top      = '0,0,0'
    bottom   = '180,0,0'
    front    = '90,0,0'
    back     = '90,0,180'
    side     = '90,0,90'
}

# `powershell -File` passes 'a,b' as one string; split so lists work both ways.
$Views = @($Views | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$Size  = @($Size  | ForEach-Object { "$_" -split ',' } | Where-Object { $_ } | ForEach-Object { [int]$_ })

$scadPath = (Resolve-Path $Scad).Path
$name = [IO.Path]::GetFileNameWithoutExtension($scadPath) -replace '\s+', '_'
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir | Out-Null }

$ctx = Resolve-OpenScad
$defArgs = @()
foreach ($d in $Defs) { $defArgs += @('-D', $d) }

$fail = 0
foreach ($v in $Views) {
    if (-not $viewTable.ContainsKey($v)) {
        Write-Host "Unknown view '$v'. Valid: $($viewTable.Keys -join ', ')" -ForegroundColor Red
        $fail++; continue
    }
    $png = Join-Path $OutDir "${name}_$v.png"
    $args = $ctx.CommonArgs + $defArgs + @(
        '-o', $png,
        "--imgsize=$($Size[0]),$($Size[1])",
        "--camera=0,0,0,$($viewTable[$v]),0",
        '--autocenter', '--viewall', '--colorscheme=Tomorrow'
    )
    if ($Render) { $args += '--render' }
    $args += $scadPath

    $errFile = [IO.Path]::GetTempFileName()
    $proc = Start-Process -FilePath $ctx.Exe -ArgumentList $args `
        -NoNewWindow -Wait -PassThru -RedirectStandardError $errFile
    $err = Get-Content $errFile
    Remove-Item $errFile -ErrorAction SilentlyContinue

    if ($proc.ExitCode -eq 0 -and (Test-Path $png)) {
        Write-Host "OK  $png" -ForegroundColor Green
    } else {
        $fail++
        Write-Host "FAILED $v (exit $($proc.ExitCode))" -ForegroundColor Red
        $err | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    }
    # Surface ECHO/WARNING lines (useful for dimension checks).
    $err | Where-Object { $_ -match '^(ECHO|WARNING)' } | Select-Object -Unique |
        ForEach-Object { Write-Host "  $_" -ForegroundColor DarkCyan }
}
exit $fail
