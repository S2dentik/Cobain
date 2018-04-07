public indirect enum AST: Equatable {
    case number(Double)
    case variable(String)
    case binary(op: Character, AST, AST)
    case call(callee: String, args: [AST])
    case prototype(Prototype)
    case motif(Prototype, body: AST?)
}

public struct Prototype: Equatable {
    public let name: String
    public let args: [String]
}
