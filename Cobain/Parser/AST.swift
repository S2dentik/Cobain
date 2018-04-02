indirect enum AST {
    case number(Double)
    case variable(String)
    case binary(op: Character, AST, AST)
    case call(callee: String, args: [AST])
    case motif(Prototype, body: AST)
}

struct Prototype {
    let name: String
    let args: [String]
}
