import Cocoa
import Carbon

// MARK: - Text Cleaning

func cleanText(_ input: String) -> String {
    let normalized = input
        .replacingOccurrences(of: "\r\n", with: "\n")
        .replacingOccurrences(of: "\r", with: "\n")

    let lines = normalized.components(separatedBy: "\n").map { line -> String in
        var s = line
            .replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression)
            .replacingOccurrences(of: "^\\s+", with: "", options: .regularExpression)
        if s.hasPrefix("⏺") {
            s = String(s.dropFirst())
                .replacingOccurrences(of: "^\\s+", with: "", options: .regularExpression)
        }
        return s
    }

    // Group lines into paragraphs (split on blank lines)
    var paragraphs: [[String]] = [[]]
    for line in lines {
        if line.isEmpty {
            if !paragraphs[paragraphs.count - 1].isEmpty {
                paragraphs.append([])
            }
        } else {
            paragraphs[paragraphs.count - 1].append(line)
        }
    }

    let result = paragraphs.compactMap { para -> String? in
        if para.isEmpty { return nil }

        var outputLines: [String] = []
        var buffer = ""

        for line in para {
            if isListItem(line) {
                if !buffer.isEmpty {
                    outputLines.append(buffer)
                    buffer = ""
                }
                outputLines.append(line)
            } else if !outputLines.isEmpty && isListItem(outputLines.last!) && buffer.isEmpty {
                outputLines[outputLines.count - 1] += " " + line
            } else {
                buffer = buffer.isEmpty ? line : buffer + " " + line
            }
        }
        if !buffer.isEmpty {
            outputLines.append(buffer)
        }

        return outputLines.joined(separator: "\n")
    }

    return result.joined(separator: "\n\n")
}

func isListItem(_ line: String) -> Bool {
    line.hasPrefix("- ") || line.hasPrefix("* ") ||
    line.range(of: #"^\d+[.)\]] "#, options: .regularExpression) != nil
}

// MARK: - Carbon HotKey Callback

func hotKeyCallback(
    _: EventHandlerCallRef?,
    _: EventRef?,
    userData: UnsafeMutableRawPointer?
) -> OSStatus {
    guard let userData = userData else { return OSStatus(eventNotHandledErr) }
    let delegate = Unmanaged<AppDelegate>.fromOpaque(userData).takeUnretainedValue()
    DispatchQueue.main.async { delegate.performClean() }
    return noErr
}

// MARK: - App Delegate

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var hotKeyRef: EventHotKeyRef?

    func applicationDidFinishLaunching(_: Notification) {
        setupStatusItem()
        registerGlobalHotKey()
    }

    func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(
                systemSymbolName: "scissors",
                accessibilityDescription: "Clean Text"
            )
        }

        let menu = NSMenu()

        let cleanItem = NSMenuItem(
            title: "Clean Clipboard  ⌃⌥C",
            action: #selector(cleanClipboardAction),
            keyEquivalent: ""
        )
        cleanItem.target = self
        menu.addItem(cleanItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(
            title: "Quit",
            action: #selector(quitApp),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    func registerGlobalHotKey() {
        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = OSType(0x434C4E54)  // "CLNT"
        hotKeyID.id = 1

        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        InstallEventHandler(
            GetApplicationEventTarget(),
            hotKeyCallback,
            1,
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(),
            nil
        )

        // Ctrl + Option + C  (keycode 8 = C)
        RegisterEventHotKey(
            8,
            UInt32(controlKey | optionKey),
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
    }

    @objc func cleanClipboardAction() {
        performClean()
    }

    func performClean() {
        let pb = NSPasteboard.general
        guard let text = pb.string(forType: .string) else {
            showFeedback(success: false)
            return
        }

        let cleaned = cleanText(text)
        pb.clearContents()
        pb.setString(cleaned, forType: .string)
        showFeedback(success: true)
    }

    func showFeedback(success: Bool) {
        guard success, let button = statusItem.button else { return }
        let original = button.image
        button.image = NSImage(
            systemSymbolName: "checkmark.circle.fill",
            accessibilityDescription: "Done"
        )
        NSSound(named: NSSound.Name("Tink"))?.play()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            button.image = original
        }
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}

// MARK: - Entry Point

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
