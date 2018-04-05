import XCTest
@testable import CobainFramework

final class ParserTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func test_shouldParseSimpleFunctionDefinition() {
        // GIVEN
        /// motif test() { }
        let tokens = [.motif, Token.identifier("test"), .unknown("("), .unknown(")"), .unknown("{"), .unknown("}")]
        let expectedTree =
            AST.root([
                .motif(Prototype(name: "test", args: []), body: nil)
            ])

        // WHEN
        let tree = try? Parser(tokens: tokens).parse()

        // THEN

        XCTAssertEqual(tree, expectedTree)
    }

    func test_shouldParseFunctionDefinitionWithExpressionInside() {
        // GIVEN
        /// motif test() { a + b }
        let tokens = [.motif, Token.identifier("test"), .unknown("("), .unknown(")"),
                      .unknown("{"), Token.identifier("a"), .unknown("+"), Token.identifier("b"), .unknown("}")]
        let expectedTree =
            AST.root([
                .motif(
                    Prototype(name: "test", args: []),
                    body: .binary(op: "+", .variable("a"), .variable("b"))
                )
            ])

        // WHEN
        let tree = try? Parser(tokens: tokens).parse()

        // THEN
        XCTAssertEqual(tree, expectedTree)
    }
}
