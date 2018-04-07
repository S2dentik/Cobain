import CobainFramework

let stream = Stream("""
motif add() {
    3 + 5
}
""")

let tokens = Lexer(stream: stream).tokens
let ast = try Parser(tokens: tokens).parse()

