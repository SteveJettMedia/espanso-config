<#
  Clones espanso-config repo → makes symlink → restarts espanso
  Usage: .\Install-EspansoGit.ps1 -Repo "https://github.com/SteveJettMedia/espanso-config.git"
#>
param(
  [string]$Repo = "https://github.com/SteveJettMedia/espanso-config.git",
  [string]$ClonePath = "C:\Repos\espanso-config",
  [string]$EspansoExe = "espanso"
)

function Assert-Admin {
  if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Write-Warning "Re-running as admin..."
    Start-Process powershell "-File `"$PSCommandPath`" -Repo `"$Repo`"" -Verb RunAs
    exit
  }
}

Assert-Admin
$LocalPath = Join-Path $Env:APPDATA 'espanso'

# 1. clone or pull
if (-not (Test-Path $ClonePath)) {
  git clone $Repo $ClonePath
} else {
  git -C $ClonePath pull
}

# 2. stop espanso (ignore errors if not running)
& $EspansoExe cmd disable 2>$null | Out-Null

# 3. remove old folder/link
if (Test-Path $LocalPath) { Remove-Item $LocalPath -Recurse -Force }

# 4. make symlink
New-Item -Path $LocalPath -ItemType SymbolicLink -Target $ClonePath | Out-Null

# 5. restart espanso
& $EspansoExe start 2>$null | Out-Null
Write-Host "Espanso now reading config from $ClonePath"

