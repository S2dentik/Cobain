indirect enum AST: Equatable {
    case number(Double)
    case variable(String)
    case binary(op: Character, AST, AST)
    case call(callee: String, args: [AST])
    case prototype(Prototype)
    case motif(Prototype, body: AST?)
    case root([AST])
}

struct Prototype: Equatable {
    let name: String
    let args: [String]
}
