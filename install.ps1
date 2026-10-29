# terminal-attack installer
#   irm https://raw.githubusercontent.com/Tokagero13/terminal-attack/main/install.ps1 | iex
# or, from a clone:  .\install.ps1
# Set $env:TERMINAL_ATTACK_EXTRAS = 'yes' or 'no' to skip the extras question.

& {
$ErrorActionPreference = 'Stop'
$Repo = 'https://raw.githubusercontent.com/Tokagero13/terminal-attack/main'
$wt   = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function Step($text) { Write-Host "`n> $text" -ForegroundColor Magenta }

if (-not (Test-Path "$wt\settings.json")) {
    Write-Host "Windows Terminal (Microsoft Store version) not found. Install it, open it once, then run this again." -ForegroundColor Red
    return
}

# Files come from the local clone when there is one, otherwise from GitHub.
$local = if ($PSScriptRoot -and (Test-Path (Join-Path $PSScriptRoot 'shaders'))) { $PSScriptRoot }
$web = New-Object Net.WebClient
$web.Encoding = [Text.Encoding]::UTF8
function Get-RepoText([string]$path) {
    if ($local) { [IO.File]::ReadAllText((Join-Path $local $path)) } else { $web.DownloadString("$Repo/$path") }
}

# Inserts objects into a top-level JSON array ("schemes"/"themes") unless one with the same name is already there.
# Text-based on purpose: keeps the user's formatting and works in Windows PowerShell 5.1.
function Add-Named([string]$json, [string]$key, $items) {
    $pattern = '"' + $key + '"\s*:\s*\['
    if ($json -notmatch $pattern) { $json = $json.Insert($json.IndexOf('{') + 1, "`n    `"$key`": [],") }
    $m = [regex]::Match($json, $pattern)
    $start = $m.Index + $m.Length
    $depth = 1; $inStr = $false; $i = $start
    for (; $i -lt $json.Length -and $depth -gt 0; $i++) {
        $c = $json[$i]
        if ($inStr) { if ($c -eq '\') { $i++ } elseif ($c -eq '"') { $inStr = $false } }
        elseif ($c -eq '"') { $inStr = $true }
        elseif ($c -eq '[' -or $c -eq '{') { $depth++ }
        elseif ($c -eq ']' -or $c -eq '}') { $depth-- }
    }
    $body = $json.Substring($start, $i - 1 - $start)
    $new  = @($items | Where-Object { $body -notmatch ('"name"\s*:\s*"' + [regex]::Escape($_.name) + '"') })
    if (-not $new.Count) { return $json }
    $text = ($new | ForEach-Object { $_ | ConvertTo-Json -Depth 10 }) -join ",`n"
    if ($body.Trim()) { $text += ',' }
    return $json.Insert($start, "`n$text`n")
}

Step 'Shaders -> Windows Terminal folder'
foreach ($s in 'neon-glow.hlsl', 'arcade-crt.hlsl', 'matrix-rain.hlsl') {
    [IO.File]::WriteAllText("$wt\$s", (Get-RepoText "shaders/$s"))
    "  $s"
}

Step 'Color schemes and tab themes -> settings.json'
$settings = "$wt\settings.json"
$json = [IO.File]::ReadAllText($settings)
$backup = "$wt\settings.before-terminal-attack.json"
if (-not (Test-Path $backup)) { Copy-Item $settings $backup; "  backup: $backup" }
$json = Add-Named $json 'schemes' (Get-RepoText 'terminal/schemes.json' | ConvertFrom-Json)
$json = Add-Named $json 'themes'  (Get-RepoText 'terminal/themes.json'  | ConvertFrom-Json)
if ($json -notmatch '"theme"\s*:') { $json = $json.Insert($json.IndexOf('{') + 1, "`n    `"theme`": `"Neon Cyberpunk`",") }
if ($json -notmatch '"defaults"\s*:') { $json = ([regex]'("profiles"\s*:\s*\{)').Replace($json, '$1 "defaults": {},', 1) }
try { $null = $json | ConvertFrom-Json } catch {
    Write-Host "  Could not update settings.json safely (it may contain comments). Add terminal/schemes.json and terminal/themes.json by hand; see README." -ForegroundColor Yellow
    $json = $null
}
if ($json) { [IO.File]::WriteAllText($settings, $json, (New-Object Text.UTF8Encoding $false)); '  done' }

Step 'PowerShell profile'
$profiles = @(Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'WindowsPowerShell\Microsoft.PowerShell_profile.ps1')
if ($PSVersionTable.PSEdition -eq 'Core') { $profiles += $PROFILE }
$profileText = Get-RepoText 'profile/Microsoft.PowerShell_profile.ps1'
foreach ($p in $profiles | Select-Object -Unique) {
    New-Item -ItemType Directory -Force (Split-Path $p) | Out-Null
    if ((Test-Path $p) -and [IO.File]::ReadAllText($p) -ne $profileText) { Copy-Item $p "$p.bak" -Force; "  old profile saved as $p.bak" }
    [IO.File]::WriteAllText($p, $profileText, (New-Object Text.UTF8Encoding $true))
    "  $p"
}

$policy = Get-ExecutionPolicy -Scope CurrentUser
if ($policy -in 'Undefined', 'Restricted', 'AllSigned') {
    Step 'Allowing your own scripts to run (needed for the profile)'
    Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force
    '  ExecutionPolicy (CurrentUser) = RemoteSigned'
}

$extras = $env:TERMINAL_ATTACK_EXTRAS
if (-not $extras) { $extras = Read-Host "`nInstall extras: Nerd Font (icons), Terminal-Icons, Oh My Posh? [Y/n]" }
if ($extras -notmatch '^(n|no)$') {
    Step 'Terminal-Icons'
    try { Install-Module Terminal-Icons -Repository PSGallery -Scope CurrentUser -Force -AllowClobber; '  done' }
    catch { "  skipped: $($_.Exception.Message)" }

    Step 'Oh My Posh + CaskaydiaCove Nerd Font'
    try {
        if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
            winget install JanDeDobbeleer.OhMyPosh --source winget --scope user --accept-package-agreements --accept-source-agreements --disable-interactivity | Out-Null
        }
        $omp = (Get-Command oh-my-posh -ErrorAction SilentlyContinue).Source
        if (-not $omp) { $omp = "$env:LOCALAPPDATA\Microsoft\WindowsApps\oh-my-posh.exe" }
        & $omp font install CascadiaCode | Out-Null
        New-Item -ItemType Directory -Force "$HOME\.poshthemes" | Out-Null
        $web.DownloadFile('https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/powerlevel10k_rainbow.omp.json', "$HOME\.poshthemes\powerlevel10k_rainbow.omp.json")
        '  done'
    } catch { "  skipped: $($_.Exception.Message)" }
}

Step 'Applying the style (neon on first install, otherwise your last one)'
if (-not (Test-Path "$HOME\.termstyle")) { Set-Content "$HOME\.termstyle" 'neon' }
powershell -NoLogo -Command "Set-TermStyle (Get-Content '$HOME\.termstyle' -TotalCount 1)" | Out-Null

Write-Host "`nDone! Open a new Windows Terminal tab, then try:" -ForegroundColor Green
Write-Host "  styles                      list styles"
Write-Host "  style-matrix                switch style"
Write-Host "  style-matrix --help         show its settings"
Write-Host "  style-matrix --set RAIN 0.3 change a setting`n"
}
