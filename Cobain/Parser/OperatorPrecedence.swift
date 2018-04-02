extension Character {
    var precedence: Int? {
        switch self {
        case "<": return 10
        case "+", "-": return 20
        case "*": return 40
        default: return nil
        }
    }
}
