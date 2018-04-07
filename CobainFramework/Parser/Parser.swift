public struct Parser {

    var tokens: Stream<[Token]>

    public init(tokens: [Token]) {
        self.tokens = Stream(tokens)
    }

    public func parse() throws -> [AST] {
        tokens.read() // read first token
        var syntaxTree = [AST]()
        while !tokens.isEmpty {
            switch tokens.current {
            case .motif?:
                (try parseFunctionDefinition()).map { syntaxTree.append($0) }
            case .extern?:
                (try parseExtern()).map { syntaxTree.append($0) }
            case .unknown(let char)? where char == "," || char == "\n":
                break
            default:
                (try parseTopLevelExpression()).map { syntaxTree.append($0) }
            }
        }
        return syntaxTree
    }

    private func parsePrimary() throws -> AST? {
        guard let next = tokens.stalk() else {
            return nil
        }
        switch next {
        case .number(let number): return parseNumber(number)
        case .identifier(let identifier): return try parseIdentifier(identifier)
        case .unknown(let token): return try parseToken(token)
        default: return nil // TODO: support all types
        }
    }

    private func parseNumber(_ number: Double) -> AST {
        return .number(number)
    }

    private func parseIdentifier(_ identifier: String) throws -> AST? {
        guard let next = tokens.stalk() else { return nil }
        if next.character != "(" { // Simply a variable, not a function call
            return .variable(identifier)
        }
        guard let possiblyArg = tokens.stalk()?.string else { return nil }
        if possiblyArg == ")" {
            return .call(callee: identifier, args: [])
        }
        var args = [AST]()
        while true {
            guard let arg = try parseExpression() else { return nil }
            args.append(arg)
            guard let currentIdentifier = tokens.read()?.string else { return nil }
            if currentIdentifier == ")" { break }
            if currentIdentifier != "," {
                throw ParserError.raw("Expected ')' or ',' in argument list")
            }
        }
        return .call(callee: identifier, args: args)
    }

    private func parseParentheses() throws -> AST? {
        tokens.read() // eat '('
        guard let next = tokens.read(), let expr = try parseExpression() else { return nil }
        if let char = next.character, char != ")" {
            throw ParserError.expected(")", got: char)
        }

        return expr
    }

    private func parseCurlyBrackets() throws -> AST? {
        tokens.read() // eat '{'
        let expr = try parseExpression()
        if let char = tokens.read()?.character, char != "}" {
            throw ParserError.expected("}", got: char)
        }

        return expr
    }

    private func parseToken(_ token: Character) throws -> AST? {
        if token.precedence != nil {
            return try parseExpression()
        }
        switch token {
        case "(": return try parseParentheses()
        case "{": return try parseCurlyBrackets()
        case "}", ")": return nil // this will be handled by the function
        default: throw ParserError.unknownToken(token)
        }
    }

    private func parseExpression() throws -> AST? {
        guard let lhs = try parsePrimary() else { return nil }
        return try parseBinaryOperatorRHS(0, lhs: lhs)
    }

    private func parseBinaryOperatorRHS(_ leftPrecedence: Int, lhs: AST) throws -> AST? {
        var lhs = lhs
        var op: Character?
        while true {
            guard let precedence = tokens.stalk().flatMap({ $0.character?.precedence }),
                precedence > leftPrecedence else { return lhs } // Not a binop or lower precedence
            op = tokens.read()?.character // Consume the binop
            guard let rhs = try parsePrimary() else { return nil }
            var rightAST = rhs
            if let nextPrecedence = tokens.stalk().flatMap({ $0.character?.precedence }),
                nextPrecedence > precedence {
                (try parseBinaryOperatorRHS(precedence + 1, lhs: rhs)).map { rightAST = $0 }
            }
            op.map { lhs = .binary(op: $0, lhs, rightAST) }
        }
    }

    private func parsePrototype() throws -> Prototype? {
        guard case let .identifier(functionName)? = tokens.current else {
            throw ParserError.raw("Expected function name in prototype")
        }
        tokens.read()
        guard case let .unknown(token1)? = tokens.current, token1 == "(" else {
            throw ParserError.raw("Expected '(' in prototype")
        }
        var arguments = [String]()
        while case let .identifier(identifier)? = tokens.read() {
            arguments.append(identifier)
        }
        guard case let .unknown(token2)? = tokens.current, token2 == ")" else {
            throw ParserError.raw("Expected ')' in prototype")
        }

        return Prototype(name: functionName, args: arguments)
    }

    private func parseFunctionDefinition() throws -> AST? {
        tokens.read() // eat 'motif'
        guard let proto = try parsePrototype() else { return nil }
        let body = try parseExpression()

        return .motif(proto, body: body)
    }

    private func parseExtern() throws -> AST? {
        tokens.read() // eat 'extern'
        let proto = try parsePrototype()

        return proto.map(AST.prototype)
    }

    private func parseTopLevelExpression() throws -> AST? {
        guard let expr = try parseExpression() else { return nil }
        return .motif(Prototype(name: "", args: []), body: expr)
    }
}
