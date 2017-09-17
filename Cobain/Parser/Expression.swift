indirect enum Expression {
    case number(Double)
    case variable(String)
    case binary(op: Character, Expression, Expression)
    case call(callee: String, args: [Expression])
    case motif(Prototype, body: Expression)
}

struct Prototype {
    let name: String
    let args: [String]
}
