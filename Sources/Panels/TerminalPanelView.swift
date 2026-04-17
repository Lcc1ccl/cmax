import SwiftUI
import Foundation
import AppKit
import Bonsplit

enum TextBoxToggleTarget {
    case active
    case all

    static var `default`: TextBoxToggleTarget { .all }
}

enum TextBoxShortcutBehavior: String, CaseIterable, Identifiable, Equatable {
    case toggleDisplay = "toggleDisplay"
    case toggleFocus = "toggleFocus"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .toggleDisplay:
            return String(localized: "textbox.shortcutBehavior.toggleDisplay", defaultValue: "Toggle Display")
        case .toggleFocus:
            return String(localized: "textbox.shortcutBehavior.toggleFocus", defaultValue: "Toggle Focus")
        }
    }
}

enum TextBoxEscapeBehavior: String, CaseIterable, Identifiable, Equatable {
    case sendEscape = "sendEscape"
    case focusTerminal = "focusTerminal"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .sendEscape:
            return String(localized: "textbox.escapeBehavior.sendEscape", defaultValue: "Send ESC Key")
        case .focusTerminal:
            return String(localized: "textbox.escapeBehavior.focusTerminal", defaultValue: "Focus Terminal")
        }
    }
}

enum TextBoxInputSettings {
    static let enabledKey = "textBoxEnabled"
    static let enterToSendKey = "textBoxEnterToSend"
    static let escapeBehaviorKey = "textBoxEscapeBehavior"
    static let shortcutBehaviorKey = "textBoxShortcutBehavior"

    static let defaultEnabled = true
    static let defaultEnterToSend = true
    static let defaultEscapeBehavior = TextBoxEscapeBehavior.sendEscape
    static let defaultShortcutBehavior = TextBoxShortcutBehavior.toggleFocus
    static let disabledSettingsOpacity: Double = 0.5

    static func resetAll() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: enabledKey)
        defaults.removeObject(forKey: enterToSendKey)
        defaults.removeObject(forKey: escapeBehaviorKey)
        defaults.removeObject(forKey: shortcutBehaviorKey)
    }

    static func isEnabled() -> Bool {
        bool(forKey: enabledKey, default: defaultEnabled)
    }

    static func isEnterToSend() -> Bool {
        bool(forKey: enterToSendKey, default: defaultEnterToSend)
    }

    static func escapeBehavior() -> TextBoxEscapeBehavior {
        guard let raw = UserDefaults.standard.string(forKey: escapeBehaviorKey),
              let value = TextBoxEscapeBehavior(rawValue: raw) else {
            return defaultEscapeBehavior
        }
        return value
    }

    static func shortcutBehavior() -> TextBoxShortcutBehavior {
        guard let raw = UserDefaults.standard.string(forKey: shortcutBehaviorKey),
              let value = TextBoxShortcutBehavior(rawValue: raw) else {
            return defaultShortcutBehavior
        }
        return value
    }

    private static func bool(forKey key: String, default defaultValue: Bool) -> Bool {
        UserDefaults.standard.object(forKey: key) == nil
            ? defaultValue
            : UserDefaults.standard.bool(forKey: key)
    }
}

enum TextBoxAppDetection: CaseIterable {
    case claudeCode
    case codex

    private var tabTitlePattern: String {
        switch self {
        case .claudeCode: return "Claude Code|^[✱✳⠂] "
        case .codex: return "Codex"
        }
    }

    func matches(terminalTitle: String) -> Bool {
        terminalTitle.range(of: tabTitlePattern, options: [.caseInsensitive, .regularExpression]) != nil
    }
}

enum TextBoxKeyInput {
    case ctrl(String)
    case key(String)
    case text(String)
    case command(Selector, shifted: Bool)
}

enum TextBoxKeyAction: Equatable {
    case emacsEdit
    case forwardControl
    case forwardPrefix(String)
    case forwardKeyEvent
    case submit
    case insertNewline
    case escape
    case forwardKey(TextBoxKeyRouting.TerminalKey)
    case textInput
}

enum TextBoxKeyRouting {
    enum TerminalKey: Equatable {
        case returnKey
        case arrowUp
        case arrowDown
        case arrowLeft
        case arrowRight
        case tab
        case backspace
        case escape

        var characters: String {
            switch self {
            case .returnKey: return "\r"
            case .arrowUp: return "\u{F700}"
            case .arrowDown: return "\u{F701}"
            case .arrowLeft: return "\u{F702}"
            case .arrowRight: return "\u{F703}"
            case .tab: return "\t"
            case .backspace: return "\u{7F}"
            case .escape: return "\u{1B}"
            }
        }

        var keyCode: UInt16 {
            switch self {
            case .returnKey: return 36
            case .arrowUp: return 126
            case .arrowDown: return 125
            case .arrowLeft: return 123
            case .arrowRight: return 124
            case .tab: return 48
            case .backspace: return 51
            case .escape: return 53
            }
        }
    }

    private static let emacsEditingKeys: Set<String> = ["a", "e", "f", "b", "n", "p", "k", "h"]
    private static let prefixForwardKeys: [TextBoxAppDetection: [String]] = [
        .claudeCode: ["/", "@"],
        .codex: ["/", "@"],
    ]
    private static let textForwardKeys: [TextBoxAppDetection: [String]] = [
        .claudeCode: ["?"],
        .codex: ["?"],
    ]
    private static let emptyStateSelectors: [Selector: TerminalKey] = [
        #selector(NSResponder.moveUp(_:)): .arrowUp,
        #selector(NSResponder.moveDown(_:)): .arrowDown,
        #selector(NSResponder.moveLeft(_:)): .arrowLeft,
        #selector(NSResponder.moveRight(_:)): .arrowRight,
        #selector(NSResponder.insertTab(_:)): .tab,
        #selector(NSResponder.deleteBackward(_:)): .backspace,
    ]

    static func route(
        _ input: TextBoxKeyInput,
        isEmpty: Bool,
        terminalTitle: String,
        enterToSend: Bool
    ) -> TextBoxKeyAction {
        switch input {
        case .ctrl(let char):
            return emacsEditingKeys.contains(char) ? .emacsEdit : .forwardControl
        case .key(let char):
            if isEmpty {
                for (app, keys) in textForwardKeys where keys.contains(char) && app.matches(terminalTitle: terminalTitle) {
                    return .forwardKeyEvent
                }
            }
            return .textInput
        case .text(let str):
            if isEmpty {
                for (app, keys) in prefixForwardKeys where keys.contains(str) && app.matches(terminalTitle: terminalTitle) {
                    return .forwardPrefix(str)
                }
            }
            return .textInput
        case .command(let selector, let shifted):
            if selector == #selector(NSResponder.insertNewline(_:)) ||
                selector == #selector(NSResponder.insertNewlineIgnoringFieldEditor(_:)) {
                let shouldSend = enterToSend ? !shifted : shifted
                return shouldSend ? .submit : .insertNewline
            }
            if selector == #selector(NSResponder.cancelOperation(_:)) {
                return .escape
            }
            if isEmpty, let key = emptyStateSelectors[selector] {
                return .forwardKey(key)
            }
            return .textInput
        }
    }
}

enum TextBoxKeyEvent {
    case submit
    case escape
    case key(TextBoxKeyRouting.TerminalKey)
    case control(NSEvent)
}

enum TextBoxSubmit {
    static func send(_ text: String, via surface: TerminalSurface) {
        let trimmed = text.trimmingCharacters(in: .newlines)
        if !trimmed.isEmpty {
            surface.sendText(trimmed)
        }
        surface.sendKey(.returnKey)
    }
}

enum TerminalTextBoxReturnAction: Equatable {
    case submit
    case insertNewline
}

func terminalTextBoxPlaceholderText(enterToSend: Bool) -> String {
    if enterToSend {
        return String(
            localized: "terminalTextBox.placeholder.enterToSend",
            defaultValue: "Commands or prompts here… Shift+Return for newline"
        )
    }
    return String(
        localized: "terminalTextBox.placeholder.shiftReturnSends",
        defaultValue: "Commands or prompts here… Shift+Return to send"
    )
}

func terminalTextBoxReturnAction(
    enterToSend: Bool,
    isShiftPressed: Bool
) -> TerminalTextBoxReturnAction {
    switch (enterToSend, isShiftPressed) {
    case (true, false), (false, true):
        return .submit
    case (true, true), (false, false):
        return .insertNewline
    }
}

func terminalTextBoxHeight(
    forVisibleLineCount lineCount: Int,
    font: NSFont
) -> CGFloat {
    let clampedLineCount = max(
        TerminalTextBoxLayout.minimumVisibleLineCount,
        min(TerminalTextBoxLayout.maximumVisibleLineCount, lineCount)
    )
    let adjustedFont = NSFont.monospacedSystemFont(
        ofSize: max(1, font.pointSize + TerminalTextBoxLayout.fontSizeOffset),
        weight: .regular
    )
    let lineHeight = adjustedFont.ascender - adjustedFont.descender + adjustedFont.leading
    return lineHeight * CGFloat(clampedLineCount) +
        (TerminalTextBoxLayout.lineSpacing * CGFloat(max(clampedLineCount - 1, 0))) +
        (TerminalTextBoxLayout.textInset.height * 2)
}

func terminalTextBoxClampedHeight(
    measuredHeight: CGFloat,
    font: NSFont
) -> CGFloat {
    let minimum = terminalTextBoxHeight(
        forVisibleLineCount: TerminalTextBoxLayout.minimumVisibleLineCount,
        font: font
    )
    let maximum = terminalTextBoxHeight(
        forVisibleLineCount: TerminalTextBoxLayout.maximumVisibleLineCount,
        font: font
    )
    return min(max(measuredHeight, minimum), maximum)
}

private enum TerminalTextBoxLayout {
    static let minimumVisibleLineCount = 2
    static let maximumVisibleLineCount = 8
    static let horizontalPadding: CGFloat = 8
    static let verticalPadding: CGFloat = 8
    static let contentSpacing: CGFloat = 4
    static let sendButtonSize: CGFloat = 18
    static let fontSizeOffset: CGFloat = 1
    static let lineSpacing: CGFloat = 4
    static let textInset = NSSize(width: 2, height: 6)
    static let borderWidth: CGFloat = 1
    static let borderOpacity: CGFloat = 0.25
    static let focusedBorderOpacity: CGFloat = 0.45
    static let cornerRadius: CGFloat = 6
    static let placeholderOpacity: CGFloat = 0.35
}

/// View for rendering a terminal panel
struct TerminalPanelView: View {
    @ObservedObject var panel: TerminalPanel
    @AppStorage(NotificationPaneRingSettings.enabledKey)
    private var notificationPaneRingEnabled = NotificationPaneRingSettings.defaultEnabled
    @AppStorage(TextBoxInputSettings.enabledKey) private var textBoxEnabled = TextBoxInputSettings.defaultEnabled
    @AppStorage(TextBoxInputSettings.enterToSendKey) private var enterToSend = TextBoxInputSettings.defaultEnterToSend
    @AppStorage(TextBoxInputSettings.shortcutBehaviorKey) private var shortcutBehavior = TextBoxInputSettings.defaultShortcutBehavior.rawValue
    let paneId: PaneID
    let isFocused: Bool
    let isVisibleInUI: Bool
    let portalPriority: Int
    let isSplit: Bool
    let appearance: PanelAppearance
    let hasUnreadNotification: Bool
    let onFocus: () -> Void
    let onTriggerFlash: () -> Void
    @State private var terminalTextBoxMeasuredHeight: CGFloat = 0

    private var shouldShowTerminalTextBox: Bool {
        textBoxEnabled && panel.isTextBoxActive
    }

    var body: some View {
        let config = GhosttyConfig.load()
        let runtimeBackground = GhosttyApp.shared.defaultBackgroundColor
            .withAlphaComponent(GhosttyApp.shared.defaultBackgroundOpacity)
        let runtimeForeground = config.foregroundColor
        let terminalFont = NSFont.monospacedSystemFont(ofSize: config.fontSize, weight: .regular)

        // Layering contract: terminal find UI is mounted in GhosttySurfaceScrollView (AppKit portal layer)
        // via `searchState`. Rendering `SurfaceSearchOverlay` in this SwiftUI container can hide it.
        VStack(spacing: 0) {
            GhosttyTerminalView(
                terminalSurface: panel.surface,
                paneId: paneId,
                isActive: isFocused,
                isVisibleInUI: isVisibleInUI,
                portalZPriority: portalPriority,
                showsInactiveOverlay: isSplit && !isFocused,
                showsUnreadNotificationRing: hasUnreadNotification && notificationPaneRingEnabled,
                inactiveOverlayColor: appearance.unfocusedOverlayNSColor,
                inactiveOverlayOpacity: appearance.unfocusedOverlayOpacity,
                searchState: panel.searchState,
                reattachToken: panel.viewReattachToken,
                onFocus: { _ in onFocus() },
                onTriggerFlash: onTriggerFlash
            )
            // Keep the NSViewRepresentable identity stable across bonsplit structural updates.
            // This prevents transient teardown/recreate that can momentarily detach the hosted terminal view.
            .id(panel.id)
            .background(Color.clear)

            if shouldShowTerminalTextBox {
                TerminalTextBoxBar(
                    text: $panel.textBoxContent,
                    measuredHeight: $terminalTextBoxMeasuredHeight,
                    enterToSend: enterToSend,
                    terminalBackgroundColor: runtimeBackground,
                    terminalForegroundColor: runtimeForeground,
                    terminalFont: terminalFont,
                    terminalTitle: panel.title,
                    surface: panel.surface,
                    onInputTextViewCreated: { panel.inputTextView = $0 },
                    onSubmit: { submittedText in
                        TextBoxSubmit.send(submittedText, via: panel.surface)
                    }
                )
            }
        }
        .onChange(of: textBoxEnabled) { enabled in
            if enabled && !panel.isTextBoxActive {
                panel.isTextBoxActive = true
            }
        }
        .onChange(of: shortcutBehavior) { newValue in
            if newValue == TextBoxShortcutBehavior.toggleFocus.rawValue && !panel.isTextBoxActive {
                panel.isTextBoxActive = true
            }
        }
    }
}

private struct TerminalTextBoxBar: View {
    @Binding var text: String
    @Binding var measuredHeight: CGFloat
    let enterToSend: Bool
    let terminalBackgroundColor: NSColor
    let terminalForegroundColor: NSColor
    let terminalFont: NSFont
    let terminalTitle: String
    let surface: TerminalSurface
    let onInputTextViewCreated: (InputTextView) -> Void
    let onSubmit: (String) -> Void

    var body: some View {
        HStack(alignment: .bottom, spacing: TerminalTextBoxLayout.contentSpacing) {
            TerminalTextBoxInputView(
                text: $text,
                measuredHeight: $measuredHeight,
                enterToSend: enterToSend,
                placeholder: terminalTextBoxPlaceholderText(enterToSend: enterToSend),
                terminalBackgroundColor: terminalBackgroundColor,
                terminalForegroundColor: terminalForegroundColor,
                terminalFont: terminalFont,
                terminalTitle: terminalTitle,
                onInputTextViewCreated: onInputTextViewCreated,
                onKeyEvent: handleKeyEvent,
                onPrefixForward: handlePrefixForward,
                onSubmit: submitCurrentText
            )
            .frame(
                height: terminalTextBoxClampedHeight(
                    measuredHeight: measuredHeight,
                    font: terminalFont
                )
            )

            Button(action: submitCurrentText) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: TerminalTextBoxLayout.sendButtonSize))
            }
            .buttonStyle(
                TerminalTextBoxSendButtonStyle(
                    foregroundColor: Color(nsColor: terminalForegroundColor)
                )
            )
            .help(String(localized: "terminalTextBox.send.tooltip", defaultValue: "Send"))
            .accessibilityIdentifier("TerminalInlineTextBoxSendButton")
        }
        .padding(.horizontal, TerminalTextBoxLayout.horizontalPadding)
        .padding(.vertical, TerminalTextBoxLayout.verticalPadding)
        .background(Color(nsColor: terminalBackgroundColor))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("TerminalInlineTextBox")
    }

    private func submitCurrentText() {
        let submittedText = text
        onSubmit(submittedText)
        text = ""
        measuredHeight = 0
    }

    private func handleKeyEvent(_ event: TextBoxKeyEvent) {
        switch event {
        case .submit:
            submitCurrentText()
        case .escape:
            switch TextBoxInputSettings.escapeBehavior() {
            case .focusTerminal:
                surface.focusTerminalView()
            case .sendEscape:
                surface.sendKey(.escape)
            }
        case .key(let key):
            surface.sendKey(key)
        case .control(let event):
            surface.forwardKeyEvent(event)
        }
    }

    private func handlePrefixForward(_ prefix: String) {
        surface.sendText(prefix)
        surface.focusTerminalView()
    }
}

private struct TerminalTextBoxInputView: NSViewRepresentable {
    @Binding var text: String
    @Binding var measuredHeight: CGFloat
    let enterToSend: Bool
    let placeholder: String
    let terminalBackgroundColor: NSColor
    let terminalForegroundColor: NSColor
    let terminalFont: NSFont
    let terminalTitle: String
    let onInputTextViewCreated: (InputTextView) -> Void
    let onKeyEvent: (TextBoxKeyEvent) -> Void
    let onPrefixForward: (String) -> Void
    let onSubmit: () -> Void

    private func paragraphStyle() -> NSMutableParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = TerminalTextBoxLayout.lineSpacing
        return style
    }

    private func typingAttributes() -> [NSAttributedString.Key: Any] {
        [
            .font: adjustedFont,
            .foregroundColor: terminalForegroundColor,
            .paragraphStyle: paragraphStyle(),
        ]
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        var parent: TerminalTextBoxInputView
        weak var containerView: NSView?
        var isProgrammaticUpdate = false

        init(parent: TerminalTextBoxInputView) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            guard !isProgrammaticUpdate,
                  let textView = notification.object as? InputTextView else {
                return
            }
            parent.text = textView.string
            recalculateHeight(for: textView)
        }

        func textDidBeginEditing(_ notification: Notification) {
            updateBorderOpacity(isFocused: true)
        }

        func textDidEndEditing(_ notification: Notification) {
            updateBorderOpacity(isFocused: false)
        }

        func recalculateHeight(for textView: NSTextView) {
            guard let layoutManager = textView.layoutManager,
                  let textContainer = textView.textContainer else {
                return
            }
            layoutManager.ensureLayout(for: textContainer)
            let usedRect = layoutManager.usedRect(for: textContainer)
            let baseHeight = ceil(usedRect.height) + (TerminalTextBoxLayout.textInset.height * 2)
            parent.measuredHeight = max(baseHeight, 0)
        }

        func updateBorderOpacity(isFocused: Bool) {
            containerView?.layer?.borderColor = parent.terminalForegroundColor
                .withAlphaComponent(
                    isFocused
                    ? TerminalTextBoxLayout.focusedBorderOpacity
                    : TerminalTextBoxLayout.borderOpacity
                )
                .cgColor
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeNSView(context: Context) -> NSView {
        let containerView = NSView(frame: .zero)
        containerView.wantsLayer = true
        containerView.layer?.borderWidth = TerminalTextBoxLayout.borderWidth
        containerView.layer?.cornerRadius = TerminalTextBoxLayout.cornerRadius
        containerView.layer?.masksToBounds = true
        containerView.layer?.borderColor = terminalForegroundColor
            .withAlphaComponent(TerminalTextBoxLayout.borderOpacity)
            .cgColor

        let scrollView = NSScrollView(frame: .zero)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder
        scrollView.drawsBackground = false

        let textView = InputTextView(frame: .zero)
        textView.isRichText = false
        textView.allowsUndo = true
        textView.isEditable = true
        textView.isSelectable = true
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.minSize = .zero
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.drawsBackground = false
        textView.textContainerInset = TerminalTextBoxLayout.textInset
        textView.font = adjustedFont
        textView.textColor = terminalForegroundColor
        textView.insertionPointColor = terminalForegroundColor
        textView.selectedTextAttributes = [
            .backgroundColor: terminalForegroundColor,
            .foregroundColor: terminalBackgroundColor.withAlphaComponent(1.0),
        ]
        textView.typingAttributes = typingAttributes()
        textView.defaultParagraphStyle = paragraphStyle()
        textView.delegate = context.coordinator
        textView.placeholderText = placeholder
        textView.placeholderColor = terminalForegroundColor.withAlphaComponent(TerminalTextBoxLayout.placeholderOpacity)
        textView.enterToSend = enterToSend
        textView.terminalTitle = terminalTitle
        textView.onKeyEvent = onKeyEvent
        textView.onPrefixForward = onPrefixForward
        textView.onSubmit = onSubmit
        textView.string = text
        textView.setAccessibilityIdentifier("TerminalInlineTextBoxEditor")

        if let textContainer = textView.textContainer {
            textContainer.widthTracksTextView = true
            textContainer.containerSize = NSSize(width: 0, height: CGFloat.greatestFiniteMagnitude)
        }

        scrollView.documentView = textView
        containerView.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: containerView.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])

        context.coordinator.containerView = containerView
        context.coordinator.recalculateHeight(for: textView)
        onInputTextViewCreated(textView)

        return containerView
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        context.coordinator.parent = self
        context.coordinator.containerView = nsView

        guard let scrollView = nsView.subviews.first as? NSScrollView,
              let textView = scrollView.documentView as? InputTextView else {
            return
        }

        textView.placeholderText = placeholder
        textView.placeholderColor = terminalForegroundColor.withAlphaComponent(TerminalTextBoxLayout.placeholderOpacity)
        textView.enterToSend = enterToSend
        textView.terminalTitle = terminalTitle
        textView.onKeyEvent = onKeyEvent
        textView.onPrefixForward = onPrefixForward
        textView.onSubmit = onSubmit
        textView.font = adjustedFont
        textView.textColor = terminalForegroundColor
        textView.insertionPointColor = terminalForegroundColor
        textView.selectedTextAttributes = [
            .backgroundColor: terminalForegroundColor,
            .foregroundColor: terminalBackgroundColor.withAlphaComponent(1.0),
        ]
        textView.typingAttributes = typingAttributes()
        textView.defaultParagraphStyle = paragraphStyle()

        if textView.string != text {
            context.coordinator.isProgrammaticUpdate = true
            textView.string = text
            context.coordinator.isProgrammaticUpdate = false
        }

        context.coordinator.recalculateHeight(for: textView)

        let isFocused = textView.window?.firstResponder === textView
        context.coordinator.updateBorderOpacity(isFocused: isFocused)
    }

    private var adjustedFont: NSFont {
        NSFont.monospacedSystemFont(
            ofSize: max(1, terminalFont.pointSize + TerminalTextBoxLayout.fontSizeOffset),
            weight: .regular
        )
    }
}

final class InputTextView: NSTextView {
    var placeholderText: String = ""
    var placeholderColor: NSColor = .secondaryLabelColor
    var enterToSend: Bool = true
    var terminalTitle: String = ""
    var onKeyEvent: ((TextBoxKeyEvent) -> Void)?
    var onPrefixForward: ((String) -> Void)?
    var onSubmit: (() -> Void)?
    private var keyEventAlreadyForwarded = false

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        guard string.isEmpty else { return }
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: placeholderColor,
            .font: font ?? NSFont.monospacedSystemFont(ofSize: 13, weight: .regular),
        ]
        let origin = NSPoint(
            x: textContainerInset.width + 1,
            y: textContainerInset.height
        )
        (placeholderText as NSString).draw(at: origin, withAttributes: attributes)
    }

    override var acceptsFirstResponder: Bool { true }

    override func mouseDown(with event: NSEvent) {
        window?.makeFirstResponder(self)
        super.mouseDown(with: event)
    }

    override func keyDown(with event: NSEvent) {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        if flags.contains(.control),
           let chars = event.charactersIgnoringModifiers?.lowercased() {
            let action = TextBoxKeyRouting.route(
                .ctrl(chars),
                isEmpty: string.isEmpty,
                terminalTitle: terminalTitle,
                enterToSend: enterToSend
            )
            switch action {
            case .emacsEdit:
                super.keyDown(with: event)
            case .forwardControl:
                onKeyEvent?(.control(event))
            default:
                super.keyDown(with: event)
            }
            return
        }

        if hasMarkedText() {
            super.keyDown(with: event)
            return
        }

        if let chars = event.characters {
            let action = TextBoxKeyRouting.route(
                .key(chars),
                isEmpty: string.isEmpty,
                terminalTitle: terminalTitle,
                enterToSend: enterToSend
            )
            if case .forwardKeyEvent = action {
                keyEventAlreadyForwarded = true
                onKeyEvent?(.control(event))
                return
            }
        }

        super.keyDown(with: event)
    }

    override func insertText(_ string: Any, replacementRange: NSRange) {
        if keyEventAlreadyForwarded {
            keyEventAlreadyForwarded = false
            return
        }
        if let str = string as? String {
            let action = TextBoxKeyRouting.route(
                .text(str),
                isEmpty: self.string.isEmpty,
                terminalTitle: terminalTitle,
                enterToSend: enterToSend
            )
            switch action {
            case .forwardPrefix(let prefix):
                onPrefixForward?(prefix)
                return
            case .textInput:
                break
            default:
                break
            }
        }
        super.insertText(string, replacementRange: replacementRange)
    }

    override func doCommand(by selector: Selector) {
        let shifted = NSApp.currentEvent?.modifierFlags.contains(.shift) ?? false
        let action = TextBoxKeyRouting.route(
            .command(selector, shifted: shifted),
            isEmpty: string.isEmpty,
            terminalTitle: terminalTitle,
            enterToSend: enterToSend
        )
        switch action {
        case .submit:
            onKeyEvent?(.submit)
        case .insertNewline:
            insertNewlineIgnoringFieldEditor(nil)
        case .escape:
            onKeyEvent?(.escape)
        case .forwardKey(let key):
            onKeyEvent?(.key(key))
        case .textInput, .emacsEdit, .forwardControl, .forwardPrefix, .forwardKeyEvent:
            super.doCommand(by: selector)
        }
    }
}

private struct TerminalTextBoxSendButtonStyle: ButtonStyle {
    let foregroundColor: Color

    func makeBody(configuration: Configuration) -> some View {
        TerminalTextBoxSendButtonBody(
            configuration: configuration,
            foregroundColor: foregroundColor
        )
    }
}

private struct TerminalTextBoxSendButtonBody: View {
    let configuration: TerminalTextBoxSendButtonStyle.Configuration
    let foregroundColor: Color
    @State private var isHovered = false

    var body: some View {
        configuration.label
            .foregroundStyle(foregroundColor)
            .frame(width: 28, height: 28)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            .onHover { hovering in
                isHovered = hovering
            }
    }

    private var backgroundColor: Color {
        if configuration.isPressed {
            return foregroundColor.opacity(0.18)
        }
        if isHovered {
            return foregroundColor.opacity(0.12)
        }
        return .clear
    }
}

/// Shared appearance settings for panels
struct PanelAppearance {
    let dividerColor: Color
    let unfocusedOverlayNSColor: NSColor
    let unfocusedOverlayOpacity: Double

    static func fromConfig(_ config: GhosttyConfig) -> PanelAppearance {
        PanelAppearance(
            dividerColor: Color(nsColor: config.resolvedSplitDividerColor),
            unfocusedOverlayNSColor: config.unfocusedSplitOverlayFill,
            unfocusedOverlayOpacity: config.unfocusedSplitOverlayOpacity
        )
    }
}
