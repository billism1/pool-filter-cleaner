# render_common.ps1
# Shared helpers for the render_*.ps1 scripts. Not meant to run on its own.
# Dot-source it from a sibling script:
#   . (Join-Path $PSScriptRoot 'render_common.ps1')

function Resolve-OpenScad {
    # Locate the OpenSCAD executable. Prefer the Nightly build when present:
    # it is newer and ships the more robust 'manifold' geometry backend.
    # Probes --help for --backend support and returns a hashtable:
    #   @{ Exe = <path>; CommonArgs = @(...) }
    # CommonArgs gets '--backend=manifold' on capable builds, else stays empty.
    $candidates = @(
        'C:\Program Files\OpenSCAD (Nightly)\openscad.exe',
        'C:\Program Files\OpenSCAD\openscad.exe'
    )
    $exe = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
    if (-not $exe) { $exe = (Get-Command openscad -ErrorAction SilentlyContinue).Source }
    if (-not $exe) { Write-Error 'OpenSCAD executable not found. Install it or add it to PATH.' }

    # Capture help via Start-Process to temp files. Old OpenSCAD prints its
    # banner to stderr; `& openscad --help 2>&1` would wrap that as a
    # NativeCommandError which, under $ErrorActionPreference='Stop', aborts the
    # script. Redirecting to files sidesteps PowerShell's error wrapping.
    $helpOut = [System.IO.Path]::GetTempFileName()
    $helpErr = [System.IO.Path]::GetTempFileName()
    Start-Process -FilePath $exe -ArgumentList @('--help') `
        -NoNewWindow -Wait -RedirectStandardOutput $helpOut -RedirectStandardError $helpErr | Out-Null
    $helpText = (Get-Content $helpOut -Raw -ErrorAction SilentlyContinue) +
                (Get-Content $helpErr -Raw -ErrorAction SilentlyContinue)
    Remove-Item $helpOut, $helpErr -ErrorAction SilentlyContinue

    $commonArgs = @()
    if ($helpText -match '(?m)^\s*--backend\b') {
        $commonArgs += '--backend=manifold'
        Write-Host "OpenSCAD: $exe  (manifold backend enabled)" -ForegroundColor Cyan
    } else {
        Write-Host "OpenSCAD: $exe  (legacy build; no --backend support)" -ForegroundColor Yellow
    }
    return @{ Exe = $exe; CommonArgs = $commonArgs }
}

function Invoke-ScadRenders {
    # Render a list of jobs to STL. Each job is a hashtable:
    #   @{ Src = <full path to .scad>; Out = <stl file name>; Defs = @('-D','x=y') }
    # Returns the number of failed renders (0 = all OK).
    # MaxAttempts retries on failure. The legacy (2021.01) build crashes
    # intermittently in BOSL2's curved-base rounding (native access violations);
    # a re-run usually succeeds. Deterministic errors still fail after retries.
    param(
        [Parameter(Mandatory)] [array]  $Jobs,
        [Parameter(Mandatory)] [string] $Exe,
        [array]  $CommonArgs = @(),
        [Parameter(Mandatory)] [string] $OutDir,
        [int]    $MaxAttempts = 3
    )
    if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir | Out-Null }

    $failed = 0
    foreach ($job in $Jobs) {
        $stl = Join-Path $OutDir $job.Out
        Write-Host "Rendering $(Split-Path $job.Src -Leaf) -> STLs\$($job.Out)"

        $exit    = $null
        $lastErr = @()
        for ($attempt = 1; $attempt -le $MaxAttempts; $attempt++) {
            $errFile = [System.IO.Path]::GetTempFileName()
            $proc = Start-Process -FilePath $Exe `
                -ArgumentList ($CommonArgs + $job.Defs + @('-o', $stl, $job.Src)) `
                -NoNewWindow -Wait -PassThru -RedirectStandardError $errFile
            $exit    = $proc.ExitCode
            $lastErr = Get-Content $errFile
            Remove-Item $errFile -ErrorAction SilentlyContinue

            if ($exit -eq 0) { break }
            if ($attempt -lt $MaxAttempts) {
                Write-Host "  retry $attempt/$($MaxAttempts - 1) (exit $exit)" -ForegroundColor DarkYellow
            }
        }

        if ($exit -ne 0) {
            $failed++
            Write-Host "  FAILED (exit $exit after $MaxAttempts attempt(s))" -ForegroundColor Red
            $lastErr | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
        } else {
            Write-Host "  OK" -ForegroundColor Green
        }
    }
    return $failed
}
