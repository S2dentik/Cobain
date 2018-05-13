public enum Token: Equatable {
    case motif // Function
    case extern // External
    case identifier(String)
    case number(Double)
    case unknown(Character)

    init(identifier: String) {
        switch identifier {
        case "motif": self = .motif
        case "extern": self = .extern
        default: self = .identifier(identifier)
        }
    }
}

extension Token: CustomStringConvertible {
    public var description: String {
        switch self {
        case .motif: return "motif"
        case .extern: return "extern"
        case let .identifier(id): return id
        case let .number(number): return String(number)
        case let .unknown(char): return String(char)
        }
    }
}

extension Token {
    var character: Character? {
        switch self {
        case let .unknown(character): return character
        case let .identifier(identifier): return Character(identifier)
        default: return nil
        }
    }

    var string: String? {
        switch self {
        case let .unknown(character): return String(character)
        case let .identifier(identifier): return identifier
        default: return nil
        }
    }
}
