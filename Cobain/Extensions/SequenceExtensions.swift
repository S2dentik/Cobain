extension Collection where Self: SubsequenceInitializable {
    var droppingFirst: Self {
        return type(of: self).init(dropFirst())
    }
}

protocol SubsequenceInitializable {
    associatedtype SubSequence
    init(_ subsequence: SubSequence)
}

extension String: SubsequenceInitializable {
    public init(_ subsequence: SubSequence) {
        self.init(subsequence)
    }
}

extension Array: SubsequenceInitializable {
    public init(_ subsequence: SubSequence) {
        self.init(subsequence)
    }
}
