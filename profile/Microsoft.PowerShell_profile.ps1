Import-Module Terminal-Icons -ErrorAction SilentlyContinue  # file/folder icons in ls (needs the Nerd Font)

# ── Terminal style switcher ─────────────────────────────────────────────
# Usage: styles (list), then style-<name>, e.g. style-macos

$TermDir       = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
$TermSettings  = Join-Path $TermDir 'settings.json'
$TermStyleFile = "$HOME\.termstyle"

$TermStyles = [ordered]@{
    neon = @{
        Description = 'Neon cyberpunk with glow'
        Theme       = 'Neon Cyberpunk'
        Cmd         = '$E[38;2;255;0;230m[$E[38;2;0;240;255m%USERNAME%$E[38;2;255;0;230m]-[$E[38;2;125;249;255m$P$E[38;2;255;0;230m]$_$E[38;2;5;255;161m$G$E[0m '
        Defaults    = [ordered]@{
            colorScheme  = 'Neon Cyberpunk'
            font         = [ordered]@{ face = 'Cascadia Code, CaskaydiaCove NF'; size = 12; weight = 'semi-bold'; features = @{ calt = 1; liga = 1 } }
            cursorShape  = 'filledBox'
            cursorColor  = '#FF00E6'
            opacity      = 94
            useAcrylic   = $false
            padding      = '14'
            'experimental.retroTerminalEffect' = $false
            'experimental.pixelShaderPath'     = (Join-Path $TermDir 'neon-glow.hlsl')
            intenseTextStyle              = 'all'
            adjustIndistinguishableColors = 'never'
        }
    }
    mac = @{
        Description = 'Classic 1984 Macintosh, black on white'
        Theme       = 'Classic Mac'
        Cmd         = '$E[38;2;0;0;0mMacintosh HD:$P$G$E[0m '
        Defaults    = [ordered]@{
            colorScheme  = 'Classic Mac'
            font         = [ordered]@{ face = 'Lucida Console, CaskaydiaCove NF'; size = 13; weight = 'normal' }
            cursorShape  = 'filledBox'
            opacity      = 100
            useAcrylic   = $false
            padding      = '18'
            'experimental.retroTerminalEffect' = $false
            'experimental.pixelShaderPath'     = ''
            intenseTextStyle              = 'bold'
            adjustIndistinguishableColors = 'never'
        }
    }
    platinum = @{
        Description = 'Mac OS 8/9 Platinum gray'
        Theme       = 'Mac Platinum'
        Cmd         = '$E[38;2;0;0;212mMacintosh HD:$P %$E[0m '
        Defaults    = [ordered]@{
            colorScheme  = 'Mac Platinum'
            font         = [ordered]@{ face = 'Lucida Console, CaskaydiaCove NF'; size = 12; weight = 'normal' }
            cursorShape  = 'bar'
            opacity      = 100
            useAcrylic   = $false
            padding      = '16'
            'experimental.retroTerminalEffect' = $false
            'experimental.pixelShaderPath'     = ''
            intenseTextStyle              = 'bold'
            adjustIndistinguishableColors = 'never'
        }
    }
    arcade = @{
        Description = 'Retro arcade CRT with scanlines'
        Theme       = 'Retro Arcade'
        Cmd         = '$E[38;2;255;0;0m1UP $E[38;2;255;229;0m%USERNAME%  $E[38;2;0;255;255mSTAGE $P$_$E[38;2;255;229;0mINSERT COIN $E[38;2;255;184;255m$G$E[0m '
        Defaults    = [ordered]@{
            colorScheme  = 'Retro Arcade'
            font         = [ordered]@{ face = 'Consolas, CaskaydiaCove NF'; size = 13; weight = 'bold' }
            cursorShape  = 'filledBox'
            cursorColor  = '#FFCC01'  # arcade-crt.hlsl draws the coin where it sees this exact color
            opacity      = 100
            useAcrylic   = $false
            padding      = '20'
            'experimental.retroTerminalEffect' = $false
            'experimental.pixelShaderPath'     = (Join-Path $TermDir 'arcade-crt.hlsl')
            intenseTextStyle              = 'all'
            adjustIndistinguishableColors = 'never'
        }
    }
    macos = @{
        Description = 'Modern macOS Terminal, dark mode'
        Theme       = 'macOS Dark'
        Cmd         = '$E[38;2;242;242;247m%USERNAME%@MacBook-Pro $E[38;2;100;210;255m$P$E[38;2;242;242;247m %$E[0m '
        Defaults    = [ordered]@{
            colorScheme  = 'macOS Dark'
            font         = [ordered]@{ face = 'Cascadia Mono, CaskaydiaCove NF'; size = 12; weight = 'normal' }
            cursorShape  = 'filledBox'
            opacity      = 97
            useAcrylic   = $false
            padding      = '12'
            'experimental.retroTerminalEffect' = $false
            'experimental.pixelShaderPath'     = ''
            intenseTextStyle              = 'bold'
            adjustIndistinguishableColors = 'never'
        }
    }
    matrix = @{
        Description = 'Green phosphor Matrix with glow'
        Theme       = 'Matrix'
        Cmd         = '$E[38;2;0;255;65m%USERNAME%@matrix:$P$$$E[0m '
        Defaults    = [ordered]@{
            colorScheme  = 'Matrix'
            font         = [ordered]@{ face = 'Cascadia Mono, CaskaydiaCove NF'; size = 15; weight = 'normal' }
            cursorShape  = 'filledBox'
            cursorColor  = '#00FF41'
            opacity      = 100
            useAcrylic   = $false
            padding      = '14'
            'experimental.retroTerminalEffect' = $false
            'experimental.pixelShaderPath'     = (Join-Path $TermDir 'matrix-rain.hlsl')
            intenseTextStyle              = 'all'
            adjustIndistinguishableColors = 'never'
        }
    }
    p10k = @{
        Description = 'Powerlevel10k-style powerline prompt'
        Theme       = 'macOS Dark'
        Cmd         = '$E[48;2;0;95;135m$E[38;2;255;255;255m $P $E[0m$E[38;2;0;95;135m' + [char]0xE0B0 + '$E[0m$_$E[38;2;95;215;0m❯$E[0m '
        Defaults    = [ordered]@{
            colorScheme  = 'macOS Dark'
            font         = [ordered]@{ face = 'Cascadia Code, CaskaydiaCove NF'; size = 12; weight = 'normal' }
            cursorShape  = 'bar'
            opacity      = 97
            useAcrylic   = $false
            padding      = '12'
            'experimental.retroTerminalEffect' = $false
            'experimental.pixelShaderPath'     = ''
            intenseTextStyle              = 'bold'
            adjustIndistinguishableColors = 'never'
        }
    }
    posh = @{
        Description = 'Oh My Posh, Powerlevel10k rainbow theme'
        Theme       = 'macOS Dark'
        Cmd         = '$E[48;2;0;95;135m$E[38;2;255;255;255m $P $E[0m$E[38;2;0;95;135m' + [char]0xE0B0 + '$E[0m$_$E[38;2;95;215;0m❯$E[0m '
        Defaults    = [ordered]@{
            colorScheme  = 'macOS Dark'
            font         = [ordered]@{ face = 'CaskaydiaCove NF'; size = 12; weight = 'normal' }
            cursorShape  = 'bar'
            opacity      = 97
            useAcrylic   = $false
            padding      = '12'
            'experimental.retroTerminalEffect' = $false
            'experimental.pixelShaderPath'     = ''
            intenseTextStyle              = 'bold'
            adjustIndistinguishableColors = 'never'
        }
    }
    amber = @{
        Description = '1980s amber monitor with glow'
        Theme       = 'Amber CRT'
        Cmd         = '$E[38;2;255;176;0m$P$G$E[0m'
        Defaults    = [ordered]@{
            colorScheme  = 'Amber CRT'
            font         = [ordered]@{ face = 'Consolas, CaskaydiaCove NF'; size = 13; weight = 'normal' }
            cursorShape  = 'underscore'
            opacity      = 100
            useAcrylic   = $false
            padding      = '18'
            'experimental.retroTerminalEffect' = $false
            'experimental.pixelShaderPath'     = (Join-Path $TermDir 'neon-glow.hlsl')
            intenseTextStyle              = 'all'
            adjustIndistinguishableColors = 'never'
        }
    }
}

$global:TermStyle = if (Test-Path $TermStyleFile) { (Get-Content $TermStyleFile -TotalCount 1).Trim() } else { 'neon' }
if (-not $TermStyles.Contains($global:TermStyle)) { $global:TermStyle = 'neon' }

function Set-TermStyle {
    param([Parameter(Mandatory)][ValidateScript({ $TermStyles.Contains($_) })][string]$Name)
    $style = $TermStyles[$Name]
    $json  = [IO.File]::ReadAllText($TermSettings)

    $defaults = ($style.Defaults | ConvertTo-Json -Depth 5) -replace "`r?`n", "`n        "
    $json = [regex]::Replace($json, '(?s)"defaults"\s*:\s*\{.*?\}\s*,(\s*"list")', { param($m) "`"defaults`": $defaults," + $m.Groups[1].Value })
    $json = [regex]::Replace($json, '"theme"\s*:\s*"[^"]*"', "`"theme`": `"$($style.Theme)`"")
    [IO.File]::WriteAllText($TermSettings, $json, (New-Object Text.UTF8Encoding $false))

    Set-Content $TermStyleFile $Name
    $global:TermStyle = $Name
    Use-StylePrompt
    [Environment]::SetEnvironmentVariable('PROMPT', [Environment]::ExpandEnvironmentVariables($style.Cmd), 'User')
    Clear-Host
    Write-Host "Style: $Name - $($style.Description)"
}

function styles {
    foreach ($k in $TermStyles.Keys) {
        $mark = if ($k -eq $global:TermStyle) { '*' } else { ' ' }
        '{0} style-{1,-9} {2}' -f $mark, $k, $TermStyles[$k].Description
    }
}
# style-<name> switches; style-<name> --help lists settings; style-<name> --set NAME VALUE changes one.
foreach ($k in $TermStyles.Keys) {
    Set-Item "function:global:style-$k" ([scriptblock]::Create("Invoke-TermStyleCommand $k `$args"))
}

function Invoke-TermStyleCommand {
    param([string]$Name, [object[]]$Rest)
    switch -Regex ($Rest[0]) {
        '^--?h(elp)?$' { Show-TermStyleSettings $Name }
        '^--?set$'     { Set-TermStyleValue $Name $Rest[1] $Rest[2] }
        '^$'           { Set-TermStyle $Name }
        default        { Write-Host "Unknown option '$($Rest[0])'. Try: style-$Name --help" -ForegroundColor Red }
    }
}

function Set-TermStyleValue {
    param([string]$Name, [string]$Setting, [string]$Value)
    $shader = $TermStyles[$Name].Defaults.'experimental.pixelShaderPath'
    $num = 0.0
    if (-not $shader) { Write-Host "style-$Name has no adjustable effects." -ForegroundColor Red; return }
    if (-not $Setting -or -not [double]::TryParse($Value, [Globalization.NumberStyles]::Float, [Globalization.CultureInfo]::InvariantCulture, [ref]$num)) {
        Write-Host "Usage: style-$Name --set NAME VALUE   (e.g. style-$Name --set GRAIN 0.02; see style-$Name --help)" -ForegroundColor Red; return
    }
    $text = [IO.File]::ReadAllText($shader)
    $m = [regex]::Match($text, "(?im)^#define\s+($([regex]::Escape($Setting)))(\s+)([-0-9.]+)")
    if (-not $m.Success) { Write-Host "No setting '$Setting' in style-$Name. See style-$Name --help" -ForegroundColor Red; return }
    $key = $m.Groups[1].Value
    $text = $text.Remove($m.Index, $m.Length).Insert($m.Index, "#define $key$($m.Groups[2].Value)$Value")
    [IO.File]::WriteAllText($shader, $text)
    "$key`: $($m.Groups[3].Value) -> $Value"
    if ($global:TermStyle -eq $Name) { reload-style } else { "Saved. After switching with style-$Name, run reload-style once to load the change." }
}

function Show-TermStyleSettings {
    param([Parameter(Mandatory)][string]$Name)
    $style = $TermStyles[$Name]
    $d = $style.Defaults
    Write-Host "`n$Name - $($style.Description)" -ForegroundColor Cyan
    Write-Host "`n Look (in the profile, `$TermStyles.$Name):" -ForegroundColor Yellow
    '   {0,-14} {1}' -f 'colors', $d.colorScheme
    '   {0,-14} {1}, size {2}, {3}' -f 'font', $d.font.face, $d.font.size, $d.font.weight
    '   {0,-14} {1}{2}' -f 'cursor', $d.cursorShape, $(if ($d.cursorColor) { " $($d.cursorColor)" })
    '   {0,-14} {1}%' -f 'opacity', $d.opacity

    $shader = $d.'experimental.pixelShaderPath'
    if (-not $shader) { Write-Host "`n No adjustable effects for this style.`n Switch: style-$Name`n"; return }
    Write-Host "`n Effects ($(Split-Path -Leaf $shader)):" -ForegroundColor Yellow
    foreach ($line in [IO.File]::ReadAllLines($shader)) {
        if ($line -match '^#define\s+(\w+)\s+([-0-9.]+)\s*(?://\s*(.*))?$') { '   {0,-14} {1,-7} {2}' -f $Matches[1], $Matches[2], $Matches[3] }
    }
    Write-Host "`n Change: style-$Name --set NAME VALUE    e.g. style-$Name --set GRAIN 0.02" -ForegroundColor Green
    Write-Host " Switch: style-$Name`n" -ForegroundColor DarkGray
}

# ── Prompt (changes with the active style) ─────────────────────────────
function prompt {
    $ok   = $?
    $e    = [char]27
    $full = $ExecutionContext.SessionState.Path.CurrentLocation.Path
    $path = $full.Replace($HOME, '~')
    $macPath = 'Macintosh HD:' + (($full -replace '^[A-Za-z]:\\?', '') -replace '\\', ':')

    switch ($global:TermStyle) {
        'mac' {
            $bomb = if ($ok) { '' } else { "$e[38;2;0;0;0m[BOMB] " }
            "$bomb$e[38;2;0;0;0m$macPath>$e[0m "
        }
        'platinum' {
            $err = if ($ok) { '' } else { "$e[38;2;221;8;6m(!) " }
            "$err$e[38;2;0;0;212m$macPath$e[38;2;0;0;0m %$e[0m "
        }
        'arcade' {
            $score = '{0:D6}' -f ((Get-History).Count * 10)
            $state = if ($ok) { "$e[38;2;255;229;0mREADY!" } else { "$e[38;2;255;0;0mGAME OVER" }
            "$e[38;2;255;0;0m1UP $e[38;2;255;255;255m$score  $e[38;2;0;255;255mSTAGE $path`n$state $e[38;2;255;184;255m>$e[0m "
        }
        'macos' {
            $dir = if ($full -eq $HOME) { '~' } else { Split-Path -Leaf $full }
            $err = if ($ok) { '' } else { "$e[38;2;255;69;58m✗ " }
            "$err$e[38;2;242;242;247m$env:USERNAME@MacBook-Pro $e[38;2;100;210;255m$dir$e[38;2;242;242;247m %$e[0m "
        }
        'matrix' {
            # Nerd Font pill icon: blue pill = success, red pill = error
            $pill = [char]::ConvertFromUtf32(0xF0402)
            $tag  = if ($ok) { "$e[38;2;10;132;255m$pill blue pill" } else { "$e[38;2;255;42;42m$pill red pill" }
            "$tag $e[38;2;0;143;17m$env:USERNAME@matrix$e[38;2;0;200;50m:$e[1;38;2;128;255;128m$($path -replace '\\', '/')$e[22;38;2;0;255;65m`$$e[0m "
        }
        'p10k' {
            $sep  = [char]0xE0B0; $rsep = [char]0xE0B2
            # Left: directory, then git branch (green clean / yellow dirty)
            $dir  = if ($path.Length -gt 40) { '…\' + (($path -split '\\')[-2..-1] -join '\') } else { $path }
            $left = "$e[48;2;0;95;135m$e[38;2;255;255;255m $dir "
            $last = '0;95;135'
            if (Get-Command git -ErrorAction SilentlyContinue) {
                $st = @(git status --porcelain -b 2>$null)
                if ($st.Count -and $st[0] -match '^## (?:No commits yet on )?(.+?)(?:\.\.\.| \[|$)') {
                    $bg = if ($st.Count -gt 1) { '215;175;0' } else { '95;215;0' }
                    $dirty = if ($st.Count -gt 1) { " *$($st.Count - 1)" } else { '' }
                    $left += "$e[38;2;${last}m$e[48;2;${bg}m$sep$e[38;2;0;0;0m $([char]0xE0A0) $($Matches[1])$dirty "
                    $last = $bg
                }
            }
            $left += "$e[0m$e[38;2;${last}m$sep$e[0m"

            # Right: status, duration of last command (if >= 2s), clock
            $status = if ($ok) { "$e[38;2;95;215;0m✔" } else { "$e[38;2;255;69;58m✘" }
            $h = Get-History -Count 1
            $dur = if ($h) { ($h.EndExecutionTime - $h.StartExecutionTime).TotalSeconds } else { 0 }
            $took = if ($dur -ge 2) { " $e[38;2;255;214;10m{0:N1}s" -f $dur } else { '' }
            $right = "$e[38;2;58;58;60m$rsep$e[48;2;58;58;60m $status$took $e[38;2;209;209;214m$(Get-Date -Format 'HH:mm:ss') $e[0m"
            $rlen  = ($right -replace "$e\[[0-9;]*m", '').Length
            $col   = [Math]::Max(1, $Host.UI.RawUI.WindowSize.Width - $rlen)

            $arrow = if ($ok) { "$e[38;2;95;215;0m" } else { "$e[38;2;255;69;58m" }
            "$left$e[${col}G$right`n$arrow❯$e[0m "
        }
        'amber' {
            $c = if ($ok) { "$e[38;2;255;176;0m" } else { "$e[38;2;255;140;0m?" }
            "$c$full>$e[0m"
        }
        default {
            $time  = Get-Date -Format 'HH:mm'
            $arrow = if ($ok) { "$e[38;2;5;255;161m" } else { "$e[38;2;255;42;109m" }
            "$e[38;2;255;0;230m┌─[$e[38;2;0;240;255m$env:USERNAME$e[38;2;255;0;230m]─[$e[38;2;249;240;2m$time$e[38;2;255;0;230m]─[$e[38;2;125;249;255m$path$e[38;2;255;0;230m]`n└─$arrow❯$e[0m "
        }
    }
}

# ── Oh My Posh (style 'posh') ──────────────────────────────────────────
# Oh My Posh replaces the prompt; keep ours so other styles can restore it.
$global:TermPrompt = ${function:prompt}
function Use-StylePrompt {
    if ($global:TermStyle -eq 'posh' -and (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
        oh-my-posh init powershell --config "$HOME\.poshthemes\powerlevel10k_rainbow.omp.json" | Invoke-Expression
    } else {
        Set-Item function:global:prompt $global:TermPrompt
    }
}
Use-StylePrompt

# ── cmd launchers: style-*.cmd and styles.cmd in ~\bin (on the user PATH) ─
$TermBin = "$HOME\bin"
if (-not (Test-Path $TermBin)) { New-Item -ItemType Directory $TermBin | Out-Null }
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if (($userPath -split ';') -notcontains $TermBin) { [Environment]::SetEnvironmentVariable('Path', "$userPath;$TermBin", 'User') }
# Runs the PowerShell switcher, then loads the new PROMPT into the calling cmd window (UTF-8 so the glyphs survive).
$cmdTail = @(
    'for /f "tokens=2 delims=:" %%c in (''chcp'') do set "_cp=%%c"'
    'chcp 65001 >nul'
    'for /f "tokens=2,*" %%a in (''reg query HKCU\Environment /v PROMPT ^| find "REG_"'') do set "PROMPT=%%b"'
    'chcp %_cp% >nul'
    'set "_cp="'
) -join "`r`n"
foreach ($k in @($TermStyles.Keys) + 'styles') {
    $file = Join-Path $TermBin "$(if ($k -eq 'styles') { 'styles' } else { "style-$k" }).cmd"
    $body = if ($k -eq 'styles') { "@powershell -NoLogo -Command styles" }
            else { "@echo off`r`npowershell -NoLogo -Command `"style-$k %*`"`r`n$cmdTail" }
    if (-not (Test-Path $file) -or [IO.File]::ReadAllText($file) -ne $body) { [IO.File]::WriteAllText($file, $body) }
}


# Re-read shader files after editing them. Terminal only reloads a shader when its settings
# change, and it merges quick successive changes, so bounce through another style with a pause.
function reload-style {
    $current = $global:TermStyle
    Set-TermStyle $(if ($current -eq 'macos') { 'neon' } else { 'macos' }) 6>$null
    Start-Sleep -Seconds 2
    Set-TermStyle $current 6>$null
}

# ── sync-styles: copy this setup into the terminal-attack repo and push ──
function sync-styles {
    param([string]$Message = 'Update styles')
    $repo = "$HOME\terminal-attack"
    if (-not (Test-Path "$repo\.git")) {
        Write-Host "No repo at $repo. Clone yours first: git clone https://github.com/<you>/terminal-attack.git `"$repo`"" -ForegroundColor Red; return
    }
    Copy-Item $PROFILE "$repo\profile\Microsoft.PowerShell_profile.ps1" -Force
    foreach ($s in $TermStyles.Values.Defaults.'experimental.pixelShaderPath' | Where-Object { $_ } | Select-Object -Unique) {
        Copy-Item $s "$repo\shaders\" -Force
    }
    # Only the schemes/themes the styles use, one object per item, same layout as the repo files.
    $settings = Get-Content $TermSettings -Raw | ConvertFrom-Json
    $used = @{ schemes = @($TermStyles.Values.Defaults.colorScheme); themes = @($TermStyles.Values.Theme) }
    foreach ($k in 'schemes', 'themes') {
        $items = @($settings.$k | Where-Object { $used[$k] -contains $_.name })
        $json  = "[`n" + (($items | ForEach-Object { ($_ | ConvertTo-Json -Depth 10) -replace '(?m)^', '    ' }) -join ",`n") + "`n]`n"
        [IO.File]::WriteAllText("$repo\terminal\$k.json", $json, (New-Object Text.UTF8Encoding $false))
    }
    git -C $repo add -A 2>$null
    if (-not (git -C $repo status --porcelain)) { 'Nothing changed, repo is up to date.'; return }
    git -C $repo status --short
    git -C $repo commit -q -m $Message
    git -C $repo push -q 2>&1 | Where-Object { $_ -notmatch '^To |->' }
    if ($LASTEXITCODE -eq 0) { "Pushed: $Message" } else { Write-Host 'Push failed; the commit is saved locally. Run: git -C ~\terminal-attack push' -ForegroundColor Red }
}