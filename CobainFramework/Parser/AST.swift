public indirect enum AST: Equatable {
    case number(Double)
    case variable(String)
    case binary(op: Character, AST, AST)
    case call(callee: String, args: [AST])
    case prototype(Prototype)
    case motif(Prototype, body: AST?)

    public func description(_ tabs: Int = 0) -> String {
        let t = [String](repeating: "\t", count: tabs).joined()
        switch self {
        case let .number(n):
            return t + "(number: \(n))"
        case let .variable(v):
            return t + "(variable: \(v))"
        case let .binary(op, left, right):
            return t + "(operator: \(op)\n"
                + "\(left.description(tabs + 1))\n"
                + "\(right.description(tabs + 1)))"
        case let .call(callee, args):
            return t + "(call: \(callee)\n"
                + "\(args.map { $0.description(tabs + 1) }.joined(separator: "\n")))"
        case let .prototype(proto):
            return t + "(prototype: \(proto.description))"
        case let .motif(proto, body):
            let p = proto.description
            let b = body.map { "\n\($0.description(tabs + 1))" } ?? ""
            return t + "(motif: \(p)\(b))"
        }
    }
}

public struct Prototype: Equatable {
    public let name: String
    public let args: [String]

    var description: String {
        return "\(name)(\(args.joined(separator: ", ")))"
    }
}
