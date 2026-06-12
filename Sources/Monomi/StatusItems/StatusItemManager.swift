import AppKit
import SwiftUI

/// 表示中のステータスアイテム群を管理する
@MainActor
final class StatusItemManager {
    enum Item: String, CaseIterable {
        case cpu
        case memory
        case network
        case disk
        case battery
        case sensors
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
        case .network:
            StatusItemController(
                autosaveName: "monomi.network",
                width: 72,
                label: AnyView(NetworkLabelView(store: store)),
                detail: AnyView(NetworkDetailView(store: store))
            )
        case .disk:
            StatusItemController(
                autosaveName: "monomi.disk",
                width: 72,
                label: AnyView(DiskLabelView(store: store)),
                detail: AnyView(DiskDetailView(store: store))
            )
        case .battery:
            StatusItemController(
                autosaveName: "monomi.battery",
                width: 56,
                label: AnyView(BatteryLabelView(store: store)),
                detail: AnyView(BatteryDetailView(store: store))
            )
        case .sensors:
            StatusItemController(
                autosaveName: "monomi.sensors",
                width: 44,
                label: AnyView(SensorLabelView(store: store)),
                detail: AnyView(SensorDetailView(store: store))
            )
        }
    }
}
