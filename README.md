# CleanText

A macOS menu bar app that cleans up clipboard text — removes trailing spaces, unwraps hard line breaks, and preserves paragraph structure.

## Install

```
./build.sh
cp -r build/CleanText.app /Applications/
```

## Usage

1. Copy messy text to your clipboard
2. Press **⌃⌥C** (Ctrl + Option + C)
3. Paste the cleaned text

You can also click the scissors icon in the menu bar and select "Clean Clipboard".

## What it does

- Strips trailing and leading whitespace from lines
- Unwraps hard-wrapped lines into flowing paragraphs
- Preserves paragraph breaks (double newlines)
- Preserves list items (`-`, `*`, numbered)
- Strips `⏺` markers from Claude Code output
