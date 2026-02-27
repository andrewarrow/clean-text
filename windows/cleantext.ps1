# CleanText for Windows — cleans clipboard text in place.
#
# Bind to a keyboard shortcut via:
#   - AutoHotkey: ^!c::Run, powershell -WindowStyle Hidden -File "cleantext.ps1"
#   - Or create a shortcut (.lnk) and assign a hotkey in its properties.

function Test-ListItem($line) {
    return $line -match '^- ' -or $line -match '^\* ' -or $line -match '^\d+[.)\]] '
}

function Invoke-CleanText($text) {
    $text = $text -replace "`r`n", "`n" -replace "`r", "`n"

    $lines = $text -split "`n" | ForEach-Object {
        $s = $_.Trim()
        if ($s.StartsWith([char]0x23FA)) {  # ⏺
            $s = $s.Substring(1).TrimStart()
        }
        $s
    }

    # Group into paragraphs
    $paragraphs = @()
    $current = @()
    foreach ($line in $lines) {
        if ($line -eq '') {
            if ($current.Count -gt 0) {
                $paragraphs += , $current
                $current = @()
            }
        } else {
            $current += $line
        }
    }
    if ($current.Count -gt 0) {
        $paragraphs += , $current
    }

    # Process each paragraph
    $result = @()
    foreach ($para in $paragraphs) {
        $outLines = @()
        $buf = ''
        foreach ($line in $para) {
            if (Test-ListItem $line) {
                if ($buf -ne '') {
                    $outLines += $buf
                    $buf = ''
                }
                $outLines += $line
            } elseif ($outLines.Count -gt 0 -and (Test-ListItem $outLines[-1]) -and $buf -eq '') {
                $outLines[$outLines.Count - 1] += " $line"
            } else {
                $buf = if ($buf -eq '') { $line } else { "$buf $line" }
            }
        }
        if ($buf -ne '') {
            $outLines += $buf
        }
        $result += ($outLines -join "`n")
    }

    return $result -join "`n`n"
}

# Main
$text = Get-Clipboard -Raw
if (-not $text) { exit }

$cleaned = Invoke-CleanText $text
Set-Clipboard $cleaned

# Toast notification (best-effort)
try {
    [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | Out-Null
    $notify = New-Object System.Windows.Forms.NotifyIcon
    $notify.Icon = [System.Drawing.SystemIcons]::Information
    $notify.Visible = $true
    $notify.ShowBalloonTip(2000, 'CleanText', 'Clipboard cleaned', 'Info')
    Start-Sleep -Seconds 3
    $notify.Dispose()
} catch {}
