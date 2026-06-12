import Testing
@testable import MonomiKit

@Suite struct SMCDecodingTests {
    @Test func fourCCRoundTrip() {
        let value = SMCDataType.fourCC("TC0P")
        #expect(value == 0x5443_3050)
        #expect(SMCDataType.string(fromFourCC: value) == "TC0P")
    }

    @Test func sp78DecodesTemperature() {
        // 0x3B80 = 15232 / 256 = 59.5 ℃
        #expect(SMCDataType.decode(type: "sp78", bytes: [0x3B, 0x80]) == 59.5)
        // 負温度（符号付き）
        #expect(SMCDataType.decode(type: "sp78", bytes: [0xFF, 0x00]) == -1.0)
    }

    @Test func fpe2DecodesFanRPM() {
        // 0x0BB8 = 3000 / 4 = 750 RPM
        #expect(SMCDataType.decode(type: "fpe2", bytes: [0x0B, 0xB8]) == 750.0)
    }

    @Test func fltDecodesLittleEndianFloat() {
        // Float32 1234.5 = 0x449A5000 (LE: 00 50 9A 44)
        #expect(SMCDataType.decode(type: "flt ", bytes: [0x00, 0x50, 0x9A, 0x44]) == 1234.5)
    }

    @Test func unsignedIntegers() {
        #expect(SMCDataType.decode(type: "ui8 ", bytes: [0x02]) == 2)
        #expect(SMCDataType.decode(type: "ui16", bytes: [0x01, 0x00]) == 256)
        #expect(SMCDataType.decode(type: "ui32", bytes: [0x00, 0x00, 0x01, 0x00]) == 256)
    }

    @Test func unknownTypeReturnsNil() {
        #expect(SMCDataType.decode(type: "ch8*", bytes: [0x41]) == nil)
    }

    @Test func shortBufferReturnsNil() {
        #expect(SMCDataType.decode(type: "sp78", bytes: [0x3B]) == nil)
        #expect(SMCDataType.decode(type: "flt ", bytes: [0x00, 0x50]) == nil)
    }

    /// 実ホストの SMC 読み取り（SMC が開けない環境ではスキップ）
    @Test @MetricsActor func liveSMCReadIfAvailable() throws {
        guard let client = try? SMCClient() else { return }
        let count = try client.keyCount()
        #expect(count > 0)

        let firstKey = try client.key(at: 0)
        #expect(firstKey.count == 4)
    }

    @Test @MetricsActor func liveSensorCollectorIfAvailable() {
        guard let collector = try? SensorCollector() else { return }
        let snapshot = collector.sample()
        if let cpu = snapshot.cpuTemperature {
            #expect(SensorCollector.isPlausibleTemperature(cpu))
        }
        for fan in snapshot.fans {
            #expect(fan.rpm >= 0)
            #expect(fan.rpm < 10000)
        }
    }
}
