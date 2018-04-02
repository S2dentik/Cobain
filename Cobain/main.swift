let stream = Stream("""
motif add() {
    3 + 5
}
""")

let tokens = Lexer(stream: stream).tokens
let parser = Parser(tokens: tokens)
print(tokens)
do {
    print(try parser.parse())
} catch let error as ParserError {
    print(error.description)
}
