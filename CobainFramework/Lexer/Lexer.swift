public struct Lexer {

    let stream: Stream<String>

    public var tokens: [Token] {
        var t = [Token]()
        while let token = (try? getToken()).flatMap({ $0 }) { t.append(token) }
        return t
    }

    public init(stream: Stream<String>) {
        self.stream = stream
    }

    func getToken() throws -> Token? {
        var lastChar = Character.space
        while true {
            guard let next = stream.read() else { return nil }
            if (lastChar =! next) != .space && lastChar != .newline { break } // Ignore spaces and newlines
        }
        if lastChar.isAlpha {
            var identifier = String(lastChar)
            while stream.stalk()?.isAlphanumeric ?? false {
                lastChar = stream.read()!
                identifier.append(lastChar)
            }
            return Token(identifier: identifier)
        }
        if lastChar.isDigitOrDot {
            var number = String(lastChar)
            while stream.stalk()?.isDigitOrDot ?? false {
                lastChar = stream.read()!
                number.append(lastChar)
            }
            guard number.lazy.filter({ $0 == "." }).count < 2, let token = Double(number).map(Token.number) else {
                throw LexerError.incorrectNumberLiteral(number)
            }
            return token
        }
        if lastChar.isHash {
            while !((lastChar =! stream.read())?.isNewline ?? true) { }
            return try getToken()
        }
        return .unknown(lastChar)
    }
}

infix operator =!: AssignmentPrecedence
func =!<T> (_ assigned: inout T, assignee: T) -> T {
    assigned = assignee
    return assigned
}

func =!<T> (_ assigned: inout T, assignee: T?) -> T? {
    assignee.flatMap { assigned = $0 }
    return assignee
}
