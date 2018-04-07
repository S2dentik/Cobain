import LLVM_C

final public class LLVMCodeGenerator {
    var context: LLVMContextRef
    var builder: LLVMBuilderRef
    var module: LLVMModuleRef

    var namedValues = [String: LLVMValueRef]()

    public init?() {
        guard let context = LLVMContextCreate(), let builder = LLVMCreateBuilderInContext(context) else {
            return nil
        }
        self.context = context
        self.builder = builder
        self.module = LLVMModuleCreateWithName("Cobain")
    }

    func generate(_ trees: [AST]) throws -> Int32 {
        let values = try trees.map(getValue)
        let error = UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>.allocate(capacity: 1)
        LLVMVerifyModule(module, LLVMAbortProcessAction, error)
        if let error = error.pointee {
            print(error)
        }
        return LLVMWriteBitcodeToFile(module, "result.bc")
    }

    func getValue(for tree: AST) throws -> LLVMValueRef {
        switch tree {
        case let .number(number):
            return LLVMConstReal(LLVMFloatTypeInContext(context), number)
        case let .variable(name):
            if let value = namedValues[name] { return value }
            throw LLVMCodeGeneratorError.unknownVariable(name)
        case let .binary(op: op, left, right):
            let (l, r) = (try getValue(for: left), try getValue(for: right))
            switch op {
            case "+":
                return LLVMBuildFAdd(builder, l, r, "addtmp")
            case "-":
                return LLVMBuildFSub(builder, l, r, "subtmp")
            case "*":
                return LLVMBuildFMul(builder, l, r, "multmp")
            case "/":
                return LLVMBuildFDiv(builder, l, r, "divtmp")
            case "<":
                let bool = LLVMBuildFCmp(builder, LLVMRealULT, l, r, "cmptmp")
                return LLVMBuildUIToFP(builder, bool, LLVMDoubleTypeInContext(context), "booltmp")
            default:
                throw LLVMCodeGeneratorError.unknownOperator(op)
            }
        case let .call(callee: name, args: args):
            guard let f = LLVMGetNamedFunction(module, name) else {
                throw LLVMCodeGeneratorError.unknownFunction(name)
            }
            let expectedArgsCount = Int(LLVMGetNumArgOperands(f))
            guard args.count == expectedArgsCount else {
                throw LLVMCodeGeneratorError.incorrectNumberOfArguments(expected: expectedArgsCount, got: args.count)
            }
            return LLVMBuildCall(builder, f, try args.map(getValue).unsafeMutablePointer, UInt32(args.count), "calltmp")
        case let .prototype(prototype):
            let doubles = prototype.args.map { _ in LLVMDoubleTypeInContext(context) }
            let f = LLVMFunctionType(LLVMDoubleTypeInContext(context), doubles.unsafeMutablePointer, UInt32(prototype.args.count), 0)
            let params = UnsafeMutablePointer<LLVMValueRef?>.allocate(capacity: prototype.args.count)
            LLVMGetParams(f, params)
            UnsafeBufferPointer(start: params, count: prototype.args.count).enumerated().forEach { index, arg in
                LLVMSetValueName(arg, prototype.args[index])
            }
            return LLVMAddFunction(module, prototype.name, f)
        case let .motif(proto, body):
            let f = try LLVMGetNamedFunction(module, proto.name) ?? (try getValue(for: .prototype(proto)))
            // TODO: Check if the function was already defined
            let bb = LLVMAppendBasicBlock(f, "entry")
            let instr = try body.map(getValue)
            LLVMPositionBuilder(builder, bb, instr)

            return f
        }
    }

    deinit {
        LLVMContextDispose(context)
        LLVMDisposeBuilder(builder)
    }
}

public enum LLVMCodeGeneratorError: Error {
    case unknownVariable(String)
    case unknownOperator(Character)
    case unknownFunction(String)
    case incorrectNumberOfArguments(expected: Int, got: Int)

    var localizedDescription: String {
        switch self {
        case .unknownVariable(let name):
            return "Unknown variable named \(name)"
        case .unknownOperator(let op):
            return "Unknown operator \(op)"
        case .unknownFunction(let name):
            return "Unknown function \(name)"
        case let .incorrectNumberOfArguments(expected, got):
            return "Incorrect number of arguments passed. Expected \(expected), got \(got)"
        }
    }
}
