# terminal-attack

Nine switchable styles for **Windows Terminal + PowerShell**, from neon cyberpunk to a 1984 Macintosh,
a retro arcade with a spinning coin cursor, and a Matrix-style screen with falling glyph rain.
Switch with one command, tune every effect from the terminal.

```powershell
style-matrix                  # switch style
style-matrix --help           # see what you can tune
style-matrix --set RAIN 0.3   # tune it
```

| Command | Look |
|---|---|
| `style-neon` | Neon cyberpunk: pink/cyan on deep purple, glow around text |
| `style-arcade` | Retro arcade CRT: scanlines, starfield, rolling band, **spinning gold coin cursor**, `1UP / READY! / GAME OVER` prompt |
| `style-matrix` | The Matrix: old-TV pixels, curved screen, scanlines, grain, **falling glyph rain**, blue pill / red pill prompt |
| `style-amber` | 1980s amber monitor with glow |
| `style-mac` | Classic 1984 Macintosh: black on white, `Macintosh HD:Users:you>` prompt, `[BOMB]` on errors |
| `style-platinum` | Mac OS 8/9 Platinum gray |
| `style-macos` | Modern macOS Terminal, dark mode, `you@MacBook-Pro ~ %` |
| `style-p10k` | Powerlevel10k-look powerline prompt: path, git branch/dirty count, status, duration, clock |
| `style-posh` | Real Oh My Posh with the `powerlevel10k_rainbow` theme |

---

## 1. Requirements

- Windows 10/11 with **Windows Terminal** from the Microsoft Store (open it once before installing)
- **Windows PowerShell 5.1** (built in). PowerShell 7 works too.
- Optional, installed for you if you say yes: CaskaydiaCove **Nerd Font** (icons), **Terminal-Icons**, **Oh My Posh**

> Windows only. The styles are built on Windows Terminal shaders and a PowerShell profile, so there is no bash/macOS/Linux version.

## 2. Install (one line)

Open **PowerShell** and run:

```powershell
irm https://raw.githubusercontent.com/Tokagero13/terminal-attack/main/install.ps1 | iex
```

It asks once whether to install the extras (Nerd Font, Terminal-Icons, Oh My Posh). Then **close and reopen Windows Terminal**.

What the installer does:

1. Copies the shaders (`neon-glow.hlsl`, `arcade-crt.hlsl`, `matrix-rain.hlsl`) into Windows Terminal's folder.
2. Adds the color schemes and tab themes to Terminal's `settings.json`, leaving your own ones alone.
   A backup is saved first as `settings.before-terminal-attack.json`.
3. Installs the PowerShell profile. An existing profile is kept as `Microsoft.PowerShell_profile.ps1.bak`.
4. Sets `ExecutionPolicy RemoteSigned` for your user if scripts are blocked, so the profile can load.
5. Optionally installs the extras, then switches to the neon style.

Safe to run again: it never adds a scheme or theme twice.

### Install from a clone instead

```powershell
git clone https://github.com/Tokagero13/terminal-attack.git
cd terminal-attack
.\install.ps1
```

To skip the question (for scripts): `$env:TERMINAL_ATTACK_EXTRAS = 'no'` (or `'yes'`) before running.

## 3. Use it

```powershell
styles                         # list all styles, * marks the current one
style-arcade                   # switch (all open tabs change immediately)
style-arcade --help            # font, colors, cursor + every effect setting with its value
style-arcade --set COIN_SIZE 1.5
reload-style                   # reload the current style after editing a shader by hand
```

- The chosen style is remembered for new windows.
- The same `style-*` and `styles` commands also work in **cmd** (the profile puts small launchers in `%USERPROFILE%\bin`).
  Switching from cmd also updates that cmd window's prompt.
- The prompt changes per style. In `arcade`, `matrix`, `mac`, `platinum`, `macos`, `p10k` it also shows whether the last command failed.

## 4. Tune the effects

Every number in a style's shader can be changed from the terminal:

```powershell
style-matrix --help
style-matrix --set RAIN 0.25        # rain brightness (0 = off)
style-matrix --set RAIN_BIT 5       # bigger rain glyphs
style-matrix --set PIXEL_SIZE 1     # turn off the chunky old-TV pixels
style-arcade --set SCANLINE_DARK 0  # no scanlines
```

Names are not case-sensitive. Only numbers are accepted, so a typo can't break a shader.
If you change a style you're not currently using, switch to it and run `reload-style` once.

Some useful settings:

| Style | Setting | What it does |
|---|---|---|
| matrix | `RAIN`, `RAIN_SPEED`, `RAIN_BIT`, `RAIN_DROPS` | Rain brightness, speed, glyph size, drops per column |
| matrix | `PIXEL_SIZE`, `CURVE`, `MASK`, `GRAIN`, `VIGNETTE` | Old-TV pixels, screen bulge, RGB stripes, grain, dark corners |
| arcade | `COIN_SIZE`, `COIN_SPEED` | Coin cursor size and spin speed |
| arcade | `STARS`, `STAR_SPEED`, `BAND`, `FLICKER` | Starfield, rolling CRT band, flicker |
| neon / amber | `GLOW_STRENGTH`, `GLOW_RADIUS`, `CONTOUR` | Glow and outline around text |

**Fonts, sizes and colors** live in the profile, in the `$TermStyles` table at the top of
`Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1`. Edit, save, and run the `style-*` command again.

## 5. Good to know

- **GPU use.** `arcade` and `matrix` are animated, so Windows Terminal redraws the window 60 times a second.
  On a laptop iGPU that can be 50-80% GPU. The other styles only redraw when text changes (about 2-10%).
  Use `style-neon` or `style-macos` on battery.
- **Cursor blinking.** The arcade coin blinks with the Windows cursor. To keep it steady, set
  *Control Panel > Keyboard > Cursor blink rate* to *None* (this affects all apps).
- **Icons** (Nerd Font glyphs, `ls` file icons, the pill in matrix) need the extras.
- **Shader didn't change?** Terminal caches loaded shaders. Run `reload-style`, or restart Terminal.
- **Mouse selection** is slightly offset near the screen edges in `matrix` because of the curved screen
  (`style-matrix --set CURVE 0` to flatten it).

## 6. Uninstall

```powershell
# Windows Terminal settings
$wt = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
Copy-Item "$wt\settings.before-terminal-attack.json" "$wt\settings.json" -Force
Remove-Item "$wt\neon-glow.hlsl", "$wt\arcade-crt.hlsl", "$wt\matrix-rain.hlsl"

# PowerShell profile (restores your old one if there was one)
$p = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'WindowsPowerShell\Microsoft.PowerShell_profile.ps1'
if (Test-Path "$p.bak") { Move-Item "$p.bak" $p -Force } else { Remove-Item $p }

# Launchers, saved style and cmd prompt
Remove-Item "$HOME\bin\style-*.cmd", "$HOME\bin\styles.cmd", "$HOME\.termstyle"
[Environment]::SetEnvironmentVariable('PROMPT', $null, 'User')
```

## 7. Keep your fork in sync

Tuned some values or edited the profile? Push your setup back to your own copy of this repo:

```powershell
git clone https://github.com/<you>/terminal-attack.git "$HOME\terminal-attack"   # once
sync-styles                          # copy profile, shaders, schemes, themes -> commit -> push
sync-styles "Brighter matrix rain"   # with your own commit message
```

It only commits when something actually changed.

## Repo layout

```
install.ps1                          one-line installer
profile/Microsoft.PowerShell_profile.ps1   style switcher, prompts, --help/--set, cmd launchers
shaders/neon-glow.hlsl               glow + outline (neon, amber)
shaders/arcade-crt.hlsl              arcade CRT + coin cursor + starfield
shaders/matrix-rain.hlsl             old TV + glyph rain + glow
terminal/schemes.json                color schemes
terminal/themes.json                 tab/titlebar themes
```

## License

[MIT](LICENSE)
