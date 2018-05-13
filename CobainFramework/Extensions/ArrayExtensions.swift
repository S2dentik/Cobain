extension Array {
    var unsafeMutablePointer: UnsafeMutablePointer<Element> {
        let pointer = UnsafeMutablePointer<Element>.allocate(capacity: count)
        pointer.initialize(from: self, count: count)

        return pointer
    }

    init(pointer: UnsafePointer<Element>, count: Int) {
        let buffer = UnsafeBufferPointer(start: pointer, count: count)
        self.init(buffer)
    }
}
