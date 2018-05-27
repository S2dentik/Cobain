import CobainFramework

var stream = Stream("""
motif incr(a) {
    a + 1
}
print(incr(2))
""")

if CommandLine.arguments.count > 1 {
    let currentDir = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    let fileURL = currentDir.appendingPathComponent(CommandLine.arguments[1])
    let file = try! String(contentsOf: fileURL)
    stream = Stream(file)
}

let tokens = Lexer(stream: stream).tokens
print(tokens.map { $0.description })
do {
    let ast = try Parser(tokens: tokens).parse()
    print(ast.map { $0.description() }.joined(separator: "\n"))
    let generator = try LLVMCodeGenerator()
    try generator.generate(ast)
} catch let error as ParserError {
    print(error.description)
} catch let error {
    print(error.localizedDescription)
}
print(tokens.map { $0.description })
