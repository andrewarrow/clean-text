# CleanText

Cleans up clipboard text — removes trailing spaces, unwraps hard line breaks, and preserves paragraph structure. Works on macOS, Linux, and Windows.

## What it does

- Strips trailing and leading whitespace from lines
- Unwraps hard-wrapped lines into flowing paragraphs
- Preserves paragraph breaks (double newlines)
- Preserves list items (`-`, `*`, numbered)
- Strips `⏺` markers from Claude Code output

## macOS

Menu bar app with global hotkey. Lives in the system tray with a scissors icon.

```
cd mac
./build.sh
cp -r build/CleanText.app /Applications/
```

**Shortcut:** `⌃⌥C` (Ctrl + Option + C)

Or click the scissors icon in the menu bar.

## Linux

Python 3 script. Bind it to a keyboard shortcut in your DE/WM.

**Requires:** `xclip` (X11) or `wl-clipboard` (Wayland)

```
# copy to somewhere on your PATH
cp linux/cleantext ~/.local/bin/

# then bind to a key in your DE/WM, e.g.:
# GNOME:  Settings → Keyboard → Custom Shortcuts
# KDE:    System Settings → Shortcuts → Custom Shortcuts
# sway:   bindsym Ctrl+Alt+c exec cleantext
# i3:     bindsym Ctrl+Mod1+c exec cleantext
```

## Windows

PowerShell script. Bind it to a keyboard shortcut via AutoHotkey or a desktop shortcut.

```powershell
# run directly
powershell -File windows\cleantext.ps1

# AutoHotkey binding (Ctrl+Alt+C):
# ^!c::Run, powershell -WindowStyle Hidden -File "C:\path\to\cleantext.ps1"
```

Or create a shortcut (.lnk) to the script and assign a hotkey in its properties.
