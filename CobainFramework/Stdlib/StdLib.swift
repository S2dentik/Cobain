import LLVM_C

struct StdLib {

    private let module: LLVMModuleRef
    private let context: LLVMContextRef
    private let builder: LLVMBuilderRef

    @discardableResult
    init(in module: LLVMModuleRef, with context: LLVMContextRef, builder: LLVMBuilderRef) {
        self.module = module
        self.context = context
        self.builder = builder

        initialize()
    }

    private func initialize() {
        registerPrintf()
        registerPrint()
    }

    private func registerPrint() {
        var doubleTy = LLVMDoubleTypeInContext(context)
        let type = LLVMFunctionType(LLVMVoidTypeInContext(context), &doubleTy, 1, 0)
        let print = LLVMAddFunction(module, "print", type)
        LLVMSetLinkage(print, LLVMExternalLinkage)

        let params = UnsafeMutablePointer<LLVMValueRef?>.allocate(capacity: 1)
        LLVMGetParams(print, params)
        UnsafeBufferPointer(start: params, count: 1).enumerated().forEach { index, arg in
            LLVMSetValueName(arg, "d")
        }
        let bb = LLVMAppendBasicBlockInContext(context, print, "entry")
        LLVMPositionBuilderAtEnd(builder, bb)
        let printf = LLVMGetNamedFunction(module, "printf")

        var format = LLVMBuildGlobalStringPtr(builder, "%.2f", "printf_format")
        let formatPtr = LLVMBuildGlobalStringPtr(builder, "%.2f", "printf_format_ptr")
        let value = Array(pointer: params, count: 1)[0]
//        let vaArgValue = LLVMBuildVAArg(builder, value, doubleTy, "va_argtmp")

        LLVMBuildCall(builder, printf, [format, params[0]].unsafeMutablePointer, 2, "")
        LLVMBuildRetVoid(builder)
        LLVMVerifyFunction(print, LLVMAbortProcessAction)
    }

    private func registerPrintf() {
        var printf = LLVMGetNamedFunction(module, "printf")
        if printf == nil  {
            var pty = LLVMPointerType(LLVMInt8TypeInContext(context), 0)
            let type = LLVMFunctionType(LLVMInt32TypeInContext(context), &pty, 1, 1)
            printf = LLVMAddFunction(module, "printf", type)
            LLVMSetLinkage(printf, LLVMExternalLinkage)
            LLVMSetFunctionCallConv(printf, LLVMCCallConv.rawValue)
        }
        LLVMVerifyFunction(printf, LLVMAbortProcessAction)
    }

//    private func registerDoubleDescription() {
//        var doubleDescription = LLVMGetNamedFunction(module, "double_description")
//        if doubleDescription == nil  {
//            var double = LLVMDoubleTypeInContext(context)
//            let pty = LLVMPointerType(LLVMInt8TypeInContext(context), 0)
//            let type = LLVMFunctionType(pty, &double, 1, 0)
//            doubleDescription = LLVMAddFunction(module, "double_description", type)
//        }
//    }
}
