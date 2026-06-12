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
        popover.contentViewController = NSHostingController(
            rootView: VStack(spacing: 0) {
                detail
                Divider()
                PopoverFooter()
            }
        )

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

/// 全ポップオーバー共通のフッター（設定・終了）
private struct PopoverFooter: View {
    var body: some View {
        HStack {
            SettingsLink {
                Label("設定", systemImage: "gearshape")
                    .font(.caption)
            }
            Spacer()
            Button {
                NSApp.terminate(nil)
            } label: {
                Label("終了", systemImage: "power")
                    .font(.caption)
            }
        }
        .buttonStyle(.borderless)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
    }
}
