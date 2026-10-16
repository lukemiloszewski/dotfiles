# bootstrap.ps1 — link dotfiles into a Windows profile.
#
# Windows is the client side: terminal, prompt and snippets. Development
# happens on a remote Linux host, which uses bootstrap.sh. Symlinks need
# Developer Mode or an elevated shell, so this falls back to copying; re-run it
# after pulling to refresh copied files.
$ErrorActionPreference = 'Stop'

$Repo = Resolve-Path (Join-Path $PSScriptRoot '..\..')

function Install-File($Source, $Target) {
  New-Item -ItemType Directory -Force -Path (Split-Path $Target) | Out-Null
  if ((Test-Path $Target) -and -not (Get-Item $Target).LinkType) {
    Move-Item -Force $Target "$Target.bak"
  }
  try {
    New-Item -ItemType SymbolicLink -Force -Path $Target -Target $Source | Out-Null
    Write-Host "[dotfiles] linked $Target"
  } catch {
    Copy-Item -Force $Source $Target
    Write-Host "[dotfiles] copied $Target (symlinks unavailable)"
  }
}

Install-File "$Repo\platform\windows\profile.ps1" $PROFILE.CurrentUserAllHosts
Install-File "$Repo\home\.config\starship.toml" "$HOME\.config\starship.toml"
Install-File "$Repo\home\.config\wezterm\wezterm.lua" "$HOME\.config\wezterm\wezterm.lua"

Get-ChildItem -Recurse -File "$Repo\espanso" | ForEach-Object {
  $Rel = $_.FullName.Substring("$Repo\espanso".Length)
  Install-File $_.FullName "$env:APPDATA\espanso$Rel"
}
