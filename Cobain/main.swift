let stream = Stream("""
motif add() {
    return 1+1; #just adds these two numbers
}
""")

let tokens = Lexer(stream: stream).tokens
print(tokens)
