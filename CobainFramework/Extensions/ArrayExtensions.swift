extension Array {
    var unsafeMutablePointer: UnsafeMutablePointer<Element> {
        let pointer = UnsafeMutablePointer<Element>.allocate(capacity: count)
        pointer.initialize(from: self, count: count)

        return pointer
    }
}
