param(
    [Parameter(Mandatory = $true)][string]$EngineDir,
    [Parameter(Mandatory = $true)][string]$NpmCmd,
    [Parameter(Mandatory = $true)][string]$CacheDir,
    [Parameter(Mandatory = $true)][string]$LogFile
)

$ErrorActionPreference = 'Stop'

New-Item -ItemType Directory -Force -Path $EngineDir | Out-Null
New-Item -ItemType Directory -Force -Path $CacheDir | Out-Null
$logParent = Split-Path -Parent $LogFile
if ($logParent) {
    New-Item -ItemType Directory -Force -Path $logParent | Out-Null
}

"[$(Get-Date -Format s)] Starting npm install @gitlawb/openclaude@latest" | Set-Content -Path $LogFile -Encoding UTF8
"EngineDir=$EngineDir" | Add-Content -Path $LogFile -Encoding UTF8
"CacheDir=$CacheDir" | Add-Content -Path $LogFile -Encoding UTF8
"NpmCmd=$NpmCmd" | Add-Content -Path $LogFile -Encoding UTF8

$psi = [System.Diagnostics.ProcessStartInfo]::new()
$psi.FileName = "$env:ComSpec"
$psi.WorkingDirectory = $EngineDir
$npmArgs = 'install @gitlawb/openclaude@latest --no-audit --no-fund --loglevel=warn --no-bin-links --cache "' + $CacheDir + '"'
$cmdLine = '""' + $NpmCmd + '" ' + $npmArgs + ' >> "' + $LogFile + '" 2>&1"'
$psi.Arguments = '/d /s /c ' + $cmdLine
$psi.UseShellExecute = $false
$psi.RedirectStandardOutput = $false
$psi.RedirectStandardError = $false
$psi.CreateNoWindow = $true
$process = [System.Diagnostics.Process]::new()
$process.StartInfo = $psi

[void]$process.Start()

$started = Get-Date
$lastSize = 0
while (-not $process.HasExited) {
    Start-Sleep -Seconds 10
    $elapsed = [int]((Get-Date) - $started).TotalSeconds
    $size = 0
    if (Test-Path $LogFile) {
        $size = (Get-Item $LogFile).Length
    }
    $activity = if ($size -gt $lastSize) { 'log updated' } else { 'waiting for npm output' }
    $lastSize = $size
    Write-Host ("    Still installing OpenClaude Engine... {0}s elapsed ({1}). Log: {2}" -f $elapsed, $activity, $LogFile)
}

$process.WaitForExit()
"[$(Get-Date -Format s)] npm exited with code $($process.ExitCode)" | Add-Content -Path $LogFile -Encoding UTF8
exit $process.ExitCode
