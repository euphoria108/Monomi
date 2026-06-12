import Foundation
import Observation
import ServiceManagement

@MainActor
@Observable
final class AppPreferences {
    static let shared = AppPreferences()

    var showCPU: Bool { didSet { defaults.set(showCPU, forKey: "showCPU") } }
    var showMemory: Bool { didSet { defaults.set(showMemory, forKey: "showMemory") } }
    var showNetwork: Bool { didSet { defaults.set(showNetwork, forKey: "showNetwork") } }
    var showDisk: Bool { didSet { defaults.set(showDisk, forKey: "showDisk") } }
    var showBattery: Bool { didSet { defaults.set(showBattery, forKey: "showBattery") } }
    var showSensors: Bool { didSet { defaults.set(showSensors, forKey: "showSensors") } }
    /// 高頻度系（CPU/メモリ/ネットワーク）の更新間隔（秒）
    var updateInterval: Double { didSet { defaults.set(updateInterval, forKey: "updateInterval") } }
    var launchAtLogin: Bool {
        didSet {
            defaults.set(launchAtLogin, forKey: "launchAtLogin")
            applyLaunchAtLogin()
        }
    }

    @ObservationIgnored private let defaults = UserDefaults.standard

    private init() {
        showCPU = defaults.object(forKey: "showCPU") as? Bool ?? true
        showMemory = defaults.object(forKey: "showMemory") as? Bool ?? true
        showNetwork = defaults.object(forKey: "showNetwork") as? Bool ?? true
        showDisk = defaults.object(forKey: "showDisk") as? Bool ?? true
        showBattery = defaults.object(forKey: "showBattery") as? Bool ?? true
        showSensors = defaults.object(forKey: "showSensors") as? Bool ?? true
        updateInterval = defaults.object(forKey: "updateInterval") as? Double ?? 2.0
        launchAtLogin = defaults.object(forKey: "launchAtLogin") as? Bool ?? false
    }

    var enabledItems: [StatusItemManager.Item] {
        var items: [StatusItemManager.Item] = []
        if showCPU { items.append(.cpu) }
        if showMemory { items.append(.memory) }
        if showNetwork { items.append(.network) }
        if showDisk { items.append(.disk) }
        if showBattery { items.append(.battery) }
        if showSensors { items.append(.sensors) }
        return items
    }

    /// SMAppService は .app バンドルからの起動時のみ動作する（swift run では不可）
    private func applyLaunchAtLogin() {
        do {
            if launchAtLogin {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            NSLog("launch at login failed: \(error.localizedDescription)")
        }
    }
}
