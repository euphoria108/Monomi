import Testing
@testable import MonomiKit

@Suite struct RingBufferTests {
    @Test func appendBelowCapacity() {
        var buffer = RingBuffer<Int>(capacity: 4)
        buffer.append(1)
        buffer.append(2)
        #expect(buffer.elements == [1, 2])
        #expect(buffer.count == 2)
        #expect(buffer.last == 2)
    }

    @Test func wrapsAroundAtCapacity() {
        var buffer = RingBuffer<Int>(capacity: 3)
        for value in 1...5 { buffer.append(value) }
        #expect(buffer.elements == [3, 4, 5])
        #expect(buffer.count == 3)
        #expect(buffer.last == 5)
    }

    @Test func exactlyAtCapacity() {
        var buffer = RingBuffer<Int>(capacity: 3)
        for value in 1...3 { buffer.append(value) }
        #expect(buffer.elements == [1, 2, 3])
        #expect(buffer.last == 3)
    }

    @Test func emptyBuffer() {
        let buffer = RingBuffer<Int>(capacity: 3)
        #expect(buffer.elements.isEmpty)
        #expect(buffer.last == nil)
    }
}
