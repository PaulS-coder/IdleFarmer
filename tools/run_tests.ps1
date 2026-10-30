<#
.SYNOPSIS
  Headless import + GUT run for the idle_farmer project (M01 build plan P3).

.DESCRIPTION
  1. Imports the project headlessly (refreshes the global class cache).
  2. Runs GUT via addons/gut/gut_cmdln.gd using res://.gutconfig.json.
  3. Saves the import log, test log and JUnit XML under artifacts/M01/test_runs/<UTC stamp>/.
  4. Fails with exit code 5 when any script failed to load/parse (GUT skips such files and exits 0).
  5. Fails with exit code 6 when objects leak at exit (a RefCounted reference cycle).
  6. Fails with exit code 2 when zero tests ran (GUT itself exits 0 in that case).
  Otherwise returns GUT's exit code (0 = all passed, 1 = failures).
  Setup failures: 3 = Godot binary missing, 4 = import failed.

.PARAMETER Dir
  Optional res:// test directory overriding the config (forwarded as -gdir).

.PARAMETER Select
  Optional test script name filter (forwarded as -gselect).

.PARAMETER OutRoot
  Run output root. Defaults to artifacts/M01/test_runs.
#>
[CmdletBinding()]
param(
    [string]$Dir,
    [string]$Select,
    [string]$OutRoot
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$projectDir = Join-Path $repoRoot 'idle_farmer'
$godot = $env:GODOT_BIN
if (-not $godot) {
    $godot = 'C:\_\tools\godot\4.7.2-stable\Godot_v4.7.2-stable_win64_console.exe'
}
if (-not (Test-Path $godot)) {
    Write-Error "Godot console binary not found: $godot (set GODOT_BIN)"
    exit 3
}
if (-not $OutRoot) {
    $OutRoot = Join-Path $repoRoot 'artifacts\M01\test_runs'
}

$stamp = (Get-Date).ToUniversalTime().ToString('yyyyMMddTHHmmssZ')
$runDir = Join-Path $OutRoot $stamp
New-Item -ItemType Directory -Force -Path $runDir | Out-Null
$importLog = Join-Path $runDir 'import.log'
$testLog = Join-Path $runDir 'test.log'
$junit = Join-Path $runDir 'junit.xml'

# Runs Godot with raw stdout/stderr captured to UTF-8 files (Windows PowerShell 5.1
# redirection would re-encode as UTF-16 and wrap stderr lines as error records).
function Invoke-Godot([string[]]$Arguments, [string]$LogPath) {
    $quoted = $Arguments | ForEach-Object { if ($_ -match '\s') { '"' + $_ + '"' } else { $_ } }
    $errPath = "$LogPath.stderr"
    $proc = Start-Process -FilePath $godot -ArgumentList $quoted -NoNewWindow -PassThru `
        -RedirectStandardOutput $LogPath -RedirectStandardError $errPath
    $null = $proc.Handle  # cache the handle so ExitCode is available after exit
    $proc.WaitForExit()
    $code = $proc.ExitCode
    $stderr = Get-Content -Raw -Encoding UTF8 $errPath
    if ($stderr) { Add-Content -Encoding UTF8 -Path $LogPath -Value "`n--- stderr ---`n$stderr" }
    Remove-Item $errPath
    $ansi = [string][char]27 + '\[[0-9;]*m'
    $clean = (Get-Content -Raw -Encoding UTF8 $LogPath) -replace $ansi, ''
    Set-Content -Encoding UTF8 -Path $LogPath -Value $clean
    return $code
}

$importExit = Invoke-Godot @('--headless', '--path', $projectDir, '--import') $importLog
if ($importExit -ne 0) {
    Write-Host "Import failed (exit $importExit). See $importLog"
    exit 4
}

$gutArgs = @(
    '--headless', '--path', $projectDir,
    '-s', 'addons/gut/gut_cmdln.gd',
    '-gconfig=res://.gutconfig.json',
    "-gjunit_xml_file=$junit",
    '-gexit'
)
if ($Dir) { $gutArgs += "-gdir=$Dir" }
if ($Select) { $gutArgs += "-gselect=$Select" }

$gutExit = Invoke-Godot $gutArgs $testLog
Write-Host (Get-Content -Raw -Encoding UTF8 $testLog)

$testCount = 0
if (Test-Path $junit) {
    [xml]$report = Get-Content -Raw -Encoding UTF8 $junit
    $testCount = [int]$report.testsuites.tests
}

# GUT skips scripts that fail to parse ("Ignoring script ... does not extend GutTest")
# and still exits 0, so a broken test or core script could silently drop out of a green run.
$scriptErrorPattern = 'SCRIPT ERROR|Parse Error|Failed to load script|Ignoring script'
$scriptErrors = @(Select-String -Path $importLog, $testLog -Pattern $scriptErrorPattern)

# Leaked objects at exit indicate a reference cycle (RefCounted never freed); fail fast on them.
$leakPattern = 'instances were leaked at exit|resources still in use at exit'
$leaks = @(Select-String -Path $testLog -Pattern $leakPattern)

$verdict = $gutExit
if ($gutExit -eq 0 -and $leaks.Count -gt 0) {
    Write-Host 'LEAK GUARD: objects leaked at exit; failing the run.'
    $leaks | ForEach-Object { Write-Host "  $($_.Line.Trim())" }
    $verdict = 6
}
elseif ($gutExit -eq 0 -and $scriptErrors.Count -gt 0) {
    Write-Host 'SCRIPT-ERROR GUARD: script load/parse errors found; failing the run.'
    $scriptErrors | ForEach-Object { Write-Host "  $($_.Filename):$($_.LineNumber): $($_.Line.Trim())" }
    $verdict = 5
}
elseif ($gutExit -eq 0 -and $testCount -eq 0) {
    Write-Host 'ZERO-TEST GUARD: no tests ran; failing the run.'
    $verdict = 2
}

$summary = @(
    "godot=$godot",
    "project=$projectDir",
    "args=$($gutArgs -join ' ')",
    "gut_exit=$gutExit",
    "tests=$testCount",
    "verdict_exit=$verdict"
)
Set-Content -Encoding UTF8 -Path (Join-Path $runDir 'summary.txt') -Value $summary
Write-Host ($summary -join [Environment]::NewLine)
Write-Host "Run output: $runDir"
exit $verdict
