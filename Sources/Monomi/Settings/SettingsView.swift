import SwiftUI

struct SettingsView: View {
    @Bindable var preferences = AppPreferences.shared

    var body: some View {
        Form {
            Section("メニューバーに表示") {
                Toggle("CPU", isOn: $preferences.showCPU)
                Toggle("メモリ", isOn: $preferences.showMemory)
                Toggle("ネットワーク", isOn: $preferences.showNetwork)
                Toggle("ディスク", isOn: $preferences.showDisk)
                Toggle("バッテリー", isOn: $preferences.showBattery)
                Toggle("センサー（温度・ファン）", isOn: $preferences.showSensors)
            }

            Section("更新") {
                Picker("更新間隔", selection: $preferences.updateInterval) {
                    Text("1 秒").tag(1.0)
                    Text("2 秒").tag(2.0)
                    Text("5 秒").tag(5.0)
                }
            }

            Section {
                Toggle("ログイン時に起動", isOn: $preferences.launchAtLogin)
            } footer: {
                Text("ログイン時起動は `make app` で生成した Monomi.app から起動した場合のみ有効です。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(width: 340)
        .fixedSize(horizontal: false, vertical: true)
    }
}
