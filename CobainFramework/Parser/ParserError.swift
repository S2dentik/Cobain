enum ParserError: Error {
    case unknownToken(Character)
    case expected(Character, got: Character)
    case raw(String)
}

extension ParserError {
    var description: String {
        switch self {
        case .unknownToken(let token): return "Unknown token \(token)"
        case let .expected(expected, got: got): return "Expected \(expected), but got \(got)"
        case let .raw(error): return error
        }
    }
}
