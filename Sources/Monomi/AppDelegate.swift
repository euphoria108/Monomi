import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var store: MetricStore?
    private var statusItemManager: StatusItemManager?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // swift run（バンドル外実行）でも Dock アイコンを出さない
        NSApp.setActivationPolicy(.accessory)

        let store = MetricStore()
        store.start()

        let manager = StatusItemManager(store: store)
        manager.show([.cpu, .memory])

        self.store = store
        statusItemManager = manager
    }
}
