# Cobain

A compiler for a custom programming language, built from scratch in Swift with an LLVM backend. Developed as a bachelor's diploma project to demonstrate the full compilation pipeline: lexical analysis, parsing, and native code generation.

## The Language

Cobain is a small, expression-oriented language with a functional flavor. Functions are defined with the `motif` keyword, and conditionals use an `is ... ? ... : ...` ternary syntax.

```
# Factorial function
motif fact(a) {
    is a < 1 ? a : a * fact(a - 1)
}
print(fact(5))
```

### Language Features

- **Functions** defined with `motif`
- **External declarations** with `extern`
- **Binary operators**: `+`, `-`, `*`, `/`, `<`, `>`
- **Conditional expressions**: `is condition ? then : else`
- **Recursive function calls**
- **Comments** with `#`

## Architecture

The compiler follows the classic three-stage pipeline:

```
Source Code → Lexer → Parser → LLVM Code Generator → Native Bitcode
```

| Stage | Description |
|---|---|
| **Lexer** | Tokenizes source into keywords, identifiers, numbers, and operators using a generic `Stream<T>` abstraction |
| **Parser** | Recursive descent parser with operator precedence climbing, producing an `AST` enum |
| **Code Generator** | Translates the AST to LLVM IR via the LLVM-C API, then emits bitcode (`result.bc`) |

## Project Structure

```
Cobain/
├── Cobain/                  # CLI entry point
│   └── main.swift
├── CobainFramework/         # Core compiler library
│   ├── Lexer/               # Tokenizer (Lexer, Token, Stream)
│   ├── Parser/              # AST & recursive descent parser
│   ├── Codegen/             # LLVM IR generation
│   ├── Stdlib/              # Built-in functions (print, printf)
│   └── Extensions/          # Swift helper extensions
├── CobainTests/             # XCTest unit tests
└── LLVM/                    # Pre-built LLVM 3.8 static libraries & headers
```

## Building

Requires Xcode. The repository includes pre-built LLVM static libraries, so no separate LLVM installation is needed.

```bash
# Open in Xcode
open Cobain.xcodeproj

# Or build from command line
xcodebuild -project Cobain.xcodeproj -target Cobain
```

## Usage

```bash
# Run the default example (factorial)
./Cobain

# Compile a source file
./Cobain program.cb

# Inspect compiler stages
./Cobain -emit-tokens program.cb   # Show lexer output
./Cobain -emit-ast program.cb      # Show parsed AST
./Cobain -emit-llvm program.cb     # Show generated LLVM IR
```

## Tech Stack

- **Swift** — compiler implementation
- **LLVM 3.8 C API** — backend code generation
- **XCTest** — unit testing
- **Xcode** — build system

## License

This project was developed as a bachelor's thesis. All rights reserved.
