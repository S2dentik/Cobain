import CobainFramework

var stream = Stream("""
motif fact(a) {
    is a < 1 ? a : a * fact(a - 1)
}
print(fact(5))
""")

if CommandLine.arguments.count > 1 {
    let currentDir = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    let fileURL = currentDir.appendingPathComponent(CommandLine.arguments[1])
    let file = try! String(contentsOf: fileURL)
    stream = Stream(file)
}

let tokens = Lexer(stream: stream).tokens
if CommandLine.arguments.contains("-emit-tokens") {
    print(tokens.map { $0.description })
    exit(0)
}
do {
    let ast = try Parser(tokens: tokens).parse()
    if CommandLine.arguments.contains("-emit-ast") {
        print(ast.map { $0.description() }.joined(separator: "\n"))
        exit(0)
    }
    let generator = try LLVMCodeGenerator()
    try generator.generate(ast, dump: CommandLine.arguments.contains("-emit-llvm"))
} catch let error as ParserError {
    print(error.description)
} catch let error {
    print(error.localizedDescription)
}
