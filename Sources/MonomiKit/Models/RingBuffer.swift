/// 固定容量のリングバッファ。グラフ描画用の履歴保持に使う。
public struct RingBuffer<Element: Sendable>: Sendable {
    private var storage: [Element] = []
    private var head = 0
    public let capacity: Int

    public init(capacity: Int) {
        precondition(capacity > 0)
        self.capacity = capacity
        storage.reserveCapacity(capacity)
    }

    public var count: Int { storage.count }
    public var isEmpty: Bool { storage.isEmpty }
    public var last: Element? {
        guard !storage.isEmpty else { return nil }
        return storage[(head + storage.count - 1) % storage.count]
    }

    public mutating func append(_ element: Element) {
        if storage.count < capacity {
            storage.append(element)
        } else {
            storage[head] = element
            head = (head + 1) % capacity
        }
    }

    /// 古い順に並べた要素列
    public var elements: [Element] {
        guard storage.count == capacity else { return storage }
        return Array(storage[head...] + storage[..<head])
    }
}
