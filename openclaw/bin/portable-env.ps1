param(
  [Parameter(Mandatory = $true)]
  [string]$Root,
  [string]$Platform = "windows-x64"
)

$Root = [System.IO.Path]::GetFullPath($Root)
$PackageRoot = Join-Path $Root "packages\$Platform"
$NpmPrefix = Join-Path $PackageRoot "npm-global"
$NpmCache = Join-Path $PackageRoot "npm-cache"
$NodeRoot = Join-Path $Root "runtime\$Platform"

$env:OPENCLAW_PORTABLE_ROOT = $Root
$env:OPENCLAW_PORTABLE_PLATFORM = $Platform
$env:OPENCLAW_HOME = Join-Path $Root "data\home"
$env:OPENCLAW_STATE_DIR = Join-Path $Root "data\openclaw"
$env:OPENCLAW_CONFIG_PATH = Join-Path $Root "data\config\openclaw.json"
$env:OPENCLAW_PORTABLE_WORKSPACE = Join-Path $Root "data\workspace"
$env:HOME = $env:OPENCLAW_HOME
$env:USERPROFILE = $env:OPENCLAW_HOME
$env:APPDATA = Join-Path $env:OPENCLAW_HOME "AppData\Roaming"
$env:LOCALAPPDATA = Join-Path $env:OPENCLAW_HOME "AppData\Local"
$env:XDG_CONFIG_HOME = Join-Path $env:OPENCLAW_HOME ".config"
$env:XDG_CACHE_HOME = Join-Path $env:OPENCLAW_HOME ".cache"
$env:XDG_STATE_HOME = Join-Path $env:OPENCLAW_HOME ".local\state"
$env:XDG_DATA_HOME = Join-Path $env:OPENCLAW_HOME ".local\share"
$env:TEMP = Join-Path $Root "data\temp"
$env:TMP = $env:TEMP
$env:npm_config_prefix = $NpmPrefix
$env:npm_config_cache = $NpmCache
$env:npm_config_update_notifier = "false"
$env:npm_config_fund = "false"
$env:npm_config_audit = "false"
$env:PATH = "$NodeRoot;$NpmPrefix;$env:PATH"

foreach ($dir in @(
  $env:OPENCLAW_HOME,
  $env:OPENCLAW_STATE_DIR,
  (Split-Path -Parent $env:OPENCLAW_CONFIG_PATH),
  $env:OPENCLAW_PORTABLE_WORKSPACE,
  $env:APPDATA,
  $env:LOCALAPPDATA,
  $env:XDG_CONFIG_HOME,
  $env:XDG_CACHE_HOME,
  $env:XDG_STATE_HOME,
  $env:XDG_DATA_HOME,
  $env:TEMP,
  $NpmPrefix,
  $NpmCache,
  (Join-Path $Root "packages\downloads"),
  (Join-Path $Root "logs")
)) {
  New-Item -ItemType Directory -Force -Path $dir | Out-Null
}

function ConvertTo-PortableJsonPath([string]$Path) {
  return $Path.Replace('\', '\\')
}

function Write-Utf8NoBom([string]$Path, [string]$Value) {
  $encoding = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($Path, $Value, $encoding)
}

function Set-JsonProperty([object]$Object, [string]$Name, [object]$Value) {
  if ($Object.PSObject.Properties.Name -contains $Name) {
    $Object.$Name = $Value
  } else {
    $Object | Add-Member -MemberType NoteProperty -Name $Name -Value $Value
  }
}

function New-PortableConfig {
  $template = Join-Path $Root "templates\openclaw.portable.json"
  if (Test-Path -LiteralPath $template) {
    $configText = Get-Content -LiteralPath $template -Raw
    $workspaceJson = ConvertTo-PortableJsonPath $env:OPENCLAW_PORTABLE_WORKSPACE
    $configText = $configText.Replace('${OPENCLAW_PORTABLE_WORKSPACE}', $workspaceJson)
    Write-Utf8NoBom -Path $env:OPENCLAW_CONFIG_PATH -Value $configText
  } else {
    Write-Utf8NoBom -Path $env:OPENCLAW_CONFIG_PATH -Value "{}"
  }
}

if (-not (Test-Path -LiteralPath $env:OPENCLAW_CONFIG_PATH)) {
  New-PortableConfig
} else {
  try {
    $configText = Get-Content -LiteralPath $env:OPENCLAW_CONFIG_PATH -Raw
    $config = $configText | ConvertFrom-Json
    if (-not $config.agents) {
      Set-JsonProperty $config "agents" ([pscustomobject]@{})
    }
    if (-not $config.agents.defaults) {
      Set-JsonProperty $config.agents "defaults" ([pscustomobject]@{})
    }
    if ($config.agents.defaults.workspace -eq $env:OPENCLAW_PORTABLE_WORKSPACE) {
      return
    }
    Set-JsonProperty $config.agents.defaults "workspace" $env:OPENCLAW_PORTABLE_WORKSPACE
    $configJson = $config | ConvertTo-Json -Depth 20 -Compress
    Write-Utf8NoBom -Path $env:OPENCLAW_CONFIG_PATH -Value $configJson
  } catch {
    $backup = "$($env:OPENCLAW_CONFIG_PATH).invalid-$(Get-Date -Format 'yyyyMMdd-HHmmss').bak"
    Copy-Item -LiteralPath $env:OPENCLAW_CONFIG_PATH -Destination $backup -Force
    New-PortableConfig
  }
}
