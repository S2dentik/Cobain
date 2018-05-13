import CobainFramework

let stream = Stream("""
motif incr(a) {
    a + 1
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

