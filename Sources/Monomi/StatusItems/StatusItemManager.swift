import AppKit
import SwiftUI

/// 表示中のステータスアイテム群を管理する
@MainActor
final class StatusItemManager {
    enum Item: String, CaseIterable {
        case cpu
        case memory
    }

    private let store: MetricStore
    private var controllers: [Item: StatusItemController] = [:]

    init(store: MetricStore) {
        self.store = store
    }

    func show(_ items: [Item]) {
        for (item, controller) in controllers where !items.contains(item) {
            controller.remove()
            controllers[item] = nil
        }
        // 逆順に挿入すると NSStatusBar 上で宣言順に左から並ぶ
        for item in items.reversed() where controllers[item] == nil {
            controllers[item] = makeController(for: item)
        }
    }

    private func makeController(for item: Item) -> StatusItemController {
        switch item {
        case .cpu:
            StatusItemController(
                autosaveName: "monomi.cpu",
                width: 72,
                label: AnyView(CPULabelView(store: store)),
                detail: AnyView(CPUDetailView(store: store))
            )
        case .memory:
            StatusItemController(
                autosaveName: "monomi.memory",
                width: 44,
                label: AnyView(MemoryLabelView(store: store)),
                detail: AnyView(MemoryDetailView(store: store))
            )
        }
    }
}
