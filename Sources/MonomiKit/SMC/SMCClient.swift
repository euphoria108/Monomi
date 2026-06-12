import CShims
import Foundation
import IOKit

public enum SMCError: Error, Sendable {
    case serviceNotFound
    case openFailed(kern_return_t)
    case callFailed(kern_return_t)
    case keyNotFound(String)
    case smcResult(UInt8)
    case undecodable(key: String, type: String)
}

/// AppleSMC ユーザークライアントへの薄いラッパー。
/// App Sandbox 非適用であれば entitlement なしで読み取れる。
@MetricsActor
public final class SMCClient {
    private let connection: io_connect_t

    public init() throws {
        let service = IOServiceGetMatchingService(
            kIOMainPortDefault, IOServiceMatching("AppleSMC")
        )
        guard service != 0 else { throw SMCError.serviceNotFound }
        defer { IOObjectRelease(service) }

        var connection: io_connect_t = 0
        let kr = IOServiceOpen(service, mach_task_self_, 0, &connection)
        guard kr == KERN_SUCCESS else { throw SMCError.openFailed(kr) }
        self.connection = connection
    }

    deinit {
        IOServiceClose(connection)
    }

    /// キーの値を SMC が報告する型でデコードして返す
    public func readDouble(_ key: String) throws -> Double {
        let (size, type) = try keyInfo(key)

        var input = MNSMCParamStruct()
        input.key = SMCDataType.fourCC(key)
        input.keyInfo.dataSize = UInt32(size)
        input.data8 = UInt8(kMNSMCReadKey)
        let output = try call(&input)

        let bytes = withUnsafeBytes(of: output.bytes) { Array($0.prefix(size)) }
        guard let value = SMCDataType.decode(type: type, bytes: bytes) else {
            throw SMCError.undecodable(key: key, type: type)
        }
        return value
    }

    public func keyInfo(_ key: String) throws -> (size: Int, type: String) {
        var input = MNSMCParamStruct()
        input.key = SMCDataType.fourCC(key)
        input.data8 = UInt8(kMNSMCGetKeyInfo)
        let output = try call(&input)
        return (
            size: Int(output.keyInfo.dataSize),
            type: SMCDataType.string(fromFourCC: output.keyInfo.dataType)
        )
    }

    public func keyCount() throws -> Int {
        Int(try readDouble("#KEY"))
    }

    public func key(at index: Int) throws -> String {
        var input = MNSMCParamStruct()
        input.data8 = UInt8(kMNSMCGetKeyFromIndex)
        input.data32 = UInt32(index)
        let output = try call(&input)
        return SMCDataType.string(fromFourCC: output.key)
    }

    private func call(_ input: inout MNSMCParamStruct) throws -> MNSMCParamStruct {
        assert(MemoryLayout<MNSMCParamStruct>.stride == 80, "SMCParamStruct must be 80 bytes")

        var output = MNSMCParamStruct()
        var outputSize = MemoryLayout<MNSMCParamStruct>.stride
        let kr = IOConnectCallStructMethod(
            connection,
            UInt32(kMNSMCHandleYPCEvent),
            &input,
            MemoryLayout<MNSMCParamStruct>.stride,
            &output,
            &outputSize
        )
        guard kr == KERN_SUCCESS else { throw SMCError.callFailed(kr) }
        guard output.result != UInt8(kMNSMCKeyNotFound) else {
            throw SMCError.keyNotFound(SMCDataType.string(fromFourCC: input.key))
        }
        guard output.result == 0 else { throw SMCError.smcResult(output.result) }
        return output
    }
}
