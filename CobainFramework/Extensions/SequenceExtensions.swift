extension Collection where Self: SubsequenceInitializable {
    var droppingFirst: Self {
        return type(of: self).init(subsequence: dropFirst())
    }
}

public protocol SubsequenceInitializable {
    associatedtype SubSequence
    init(subsequence: SubSequence)
}

extension String: SubsequenceInitializable {
    public init(subsequence: SubSequence) {
        self.init(subsequence)
    }
}

extension Array: SubsequenceInitializable {
    public init(subsequence: SubSequence) {
        self.init(subsequence)
    }
}
