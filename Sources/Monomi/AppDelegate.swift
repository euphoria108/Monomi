import AppKit
import MonomiKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var store: MetricStore?
    private var statusItemManager: StatusItemManager?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // swift run（バンドル外実行）でも Dock アイコンを出さない
        NSApp.setActivationPolicy(.accessory)

        let store = MetricStore()
        store.start()

        var items: [StatusItemManager.Item] = [.cpu, .memory, .network, .disk]
        if BatteryCollector.isBatteryPresent() {
            items.append(.battery)
        }
        let manager = StatusItemManager(store: store)
        manager.show(items)

        self.store = store
        statusItemManager = manager
    }
}
