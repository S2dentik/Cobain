import CobainFramework

let stream = Stream("""
motif add(a, b) {
    a + b
}
""")

let tokens = Lexer(stream: stream).tokens
do {
    let ast = try Parser(tokens: tokens).parse()
    let generator = try LLVMCodeGenerator()
    try generator.generate(ast)
} catch let error {
    print(error.localizedDescription)
}

