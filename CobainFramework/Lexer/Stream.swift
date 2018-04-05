class Stream<T: Collection & SubsequenceInitializable> {
    
    private var sequence: T

    var current: T.Element?

    var isEmpty: Bool {
        return sequence.isEmpty
    }
    
    init(_ sequence: T) {
        self.sequence = sequence
    }
    
    /// Reads first character of the stream and consumes it
    @discardableResult
    func read() -> T.Element? {
        guard let firstChar = sequence.first else {
            current = nil
            
            return nil
        }
        sequence = sequence.droppingFirst
        current = firstChar
        return firstChar
    }
    
    /// Reads first character of the stream without consuming it
    func stalk() -> T.Element? {
        return sequence.first
    }
    
    /// Consumes first character of the stream and returns the remaining string
    func consume() -> Stream<T> {
        sequence = sequence.droppingFirst
        return self
    }
}
