import Foundation

/// SMC のキー値デコーダ。型はキーごとに SMC が報告するものを使う（決め打ち禁止）。
public enum SMCDataType {
    /// FourCC ("TC0P" 等) を UInt32 に変換
    public static func fourCC(_ string: String) -> UInt32 {
        string.utf8.reduce(0) { ($0 << 8) | UInt32($1) }
    }

    /// UInt32 を FourCC 文字列に戻す
    public static func string(fromFourCC value: UInt32) -> String {
        let scalars = (0..<4).reversed().map { shift -> Character in
            let byte = UInt8((value >> (shift * 8)) & 0xFF)
            return Character(UnicodeScalar(byte))
        }
        return String(scalars)
    }

    /// SMC が報告した dataType に従ってバイト列を数値へデコードする
    public static func decode(type: String, bytes: [UInt8]) -> Double? {
        switch type {
        case "flt ":
            guard bytes.count >= 4 else { return nil }
            // flt はリトルエンディアン
            let raw = UInt32(bytes[0]) | UInt32(bytes[1]) << 8
                | UInt32(bytes[2]) << 16 | UInt32(bytes[3]) << 24
            return Double(Float(bitPattern: raw))
        case "fpe2":
            // 符号なし固定小数点 14.2（ビッグエンディアン）
            guard bytes.count >= 2 else { return nil }
            return Double(UInt16(bytes[0]) << 8 | UInt16(bytes[1])) / 4.0
        case "sp78":
            // 符号付き固定小数点 7.8（ビッグエンディアン）
            guard bytes.count >= 2 else { return nil }
            let raw = Int16(bitPattern: UInt16(bytes[0]) << 8 | UInt16(bytes[1]))
            return Double(raw) / 256.0
        case "ui8 ":
            guard let first = bytes.first else { return nil }
            return Double(first)
        case "ui16":
            guard bytes.count >= 2 else { return nil }
            return Double(UInt16(bytes[0]) << 8 | UInt16(bytes[1]))
        case "ui32":
            guard bytes.count >= 4 else { return nil }
            let raw = UInt32(bytes[0]) << 24 | UInt32(bytes[1]) << 16
                | UInt32(bytes[2]) << 8 | UInt32(bytes[3])
            return Double(raw)
        case "si16":
            guard bytes.count >= 2 else { return nil }
            return Double(Int16(bitPattern: UInt16(bytes[0]) << 8 | UInt16(bytes[1])))
        default:
            return nil
        }
    }
}
