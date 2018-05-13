import LLVM_C

final public class LLVMCodeGenerator {
    var context: LLVMContextRef
    var builder: LLVMBuilderRef
    var module: LLVMModuleRef

    // Used for function arguments inside fucntion body
    var namedValues = [String: LLVMValueRef]()

    public init() throws {
        guard let context = LLVMContextCreate() else {
            throw LLVMCodeGeneratorError.uninitializedContext
        }
        guard let builder = LLVMCreateBuilderInContext(context) else {
            throw LLVMCodeGeneratorError.uninitializedBuilder
        }
        self.context = context
        self.builder = builder
        self.module = LLVMModuleCreateWithNameInContext("Cobain", context)
    }

    public func generate(_ trees: [AST]) throws -> Int32 {
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
            let fType = LLVMFunctionType(LLVMDoubleTypeInContext(context), doubles.unsafeMutablePointer, UInt32(prototype.args.count), 0)
            guard let f = LLVMAddFunction(module, prototype.name, fType) else {
                throw LLVMCodeGeneratorError.uninitializedFunction(prototype.name)
            }
            let params = UnsafeMutablePointer<LLVMValueRef?>.allocate(capacity: prototype.args.count)
            LLVMGetParams(f, params)
            namedValues = [:]
            UnsafeBufferPointer(start: params, count: prototype.args.count).enumerated().forEach { index, arg in
                LLVMSetValueName(arg, prototype.args[index])
                namedValues[prototype.args[index]] = arg
            }
            return f
        case let .motif(proto, body):
            let f = try LLVMGetNamedFunction(module, proto.name) ?? (try getValue(for: .prototype(proto)))
            // TODO: Check if the function was already defined
            let instr = try body.map(getValue)
            let bb = LLVMAppendBasicBlockInContext(context, f, "entry")
            LLVMPositionBuilderAtEnd(builder, bb)
            LLVMBuildRet(builder, instr)
            LLVMVerifyFunction(f, LLVMAbortProcessAction)

            return f
        }
    }

    deinit {
        LLVMContextDispose(context)
        LLVMDisposeBuilder(builder)
    }
}

public enum LLVMCodeGeneratorError: Error {
    case uninitializedContext
    case uninitializedBuilder
    case uninitializedFunction(String)
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
        case .uninitializedContext:
            return "Could not initialize context"
        case .uninitializedBuilder:
            return "Could not initialize builder"
        case let .uninitializedFunction(name):
            return "Could not add LLVM function \(name)"
        }
    }
}
