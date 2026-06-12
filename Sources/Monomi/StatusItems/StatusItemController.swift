import AppKit
import SwiftUI

/// NSStatusItem 1 つ分の管理。ボタンに SwiftUI ラベルを載せ、クリックで詳細ポップオーバーを出す。
@MainActor
final class StatusItemController: NSObject {
    private let statusItem: NSStatusItem
    private let popover: NSPopover

    init(autosaveName: String, width: CGFloat, label: AnyView, detail: AnyView) {
        statusItem = NSStatusBar.system.statusItem(withLength: width)
        statusItem.autosaveName = autosaveName

        popover = NSPopover()
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: detail)

        super.init()

        if let button = statusItem.button {
            let hosting = PassthroughHostingView(rootView: label)
            hosting.frame = button.bounds
            hosting.autoresizingMask = [.width, .height]
            button.addSubview(hosting)
            button.target = self
            button.action = #selector(togglePopover)
        }
    }

    @objc private func togglePopover() {
        if popover.isShown {
            popover.performClose(nil)
        } else if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    func remove() {
        popover.performClose(nil)
        NSStatusBar.system.removeStatusItem(statusItem)
    }
}

/// クリックを下のステータスバーボタンへ素通しさせる NSHostingView
private final class PassthroughHostingView<Content: View>: NSHostingView<Content> {
    override func hitTest(_ point: NSPoint) -> NSView? { nil }
}
