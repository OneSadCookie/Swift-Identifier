@testable import Swift_Identifier
import TransformCoding
import XCTest

struct TestCodingTransform: Codable {
    @TransformCoding<Orthography.Generic.snake_case>
    var identifier: Identifier
}

struct Compatible: Codable, Equatable {
    var identifier: String
}

private func checkForInvalidCasing(_ error: Error) {
    switch error {
    case Orthography.ParseError.invalidCasing:
        break
    default:
        XCTFail("expected Orthography.ParseError.invalidCasing but found \(error)")
    }
}

final class Swift_IdentifierTests: XCTestCase {

    func testCodingTransform() throws {
        let compat = Compatible(identifier: "url_scheme_mangler")
        let data = try JSONEncoder().encode(compat)
        let test = try JSONDecoder().decode(TestCodingTransform.self, from: data)
        XCTAssertEqual(Orthography.Swift.TypeIdentifier.format(test.identifier), "URLSchemeMangler")
        let data2 = try JSONEncoder().encode(test)
        let compat2 = try JSONDecoder().decode(Compatible.self, from: data2)
        XCTAssertEqual(compat, compat2)
    }

    func testBasics() {
        var identifier = Identifier()
        identifier.appendWord("Fast")
        identifier.appendAcronym("JPEG")
        identifier.appendWord("decompressor")
        
        XCTAssertEqual(Orthography.Generic.UpperCamelCase.format(identifier), "FastJpegDecompressor")
        XCTAssertEqual(Orthography.Swift.TypeIdentifier.format(identifier), "FastJPEGDecompressor")
        XCTAssertEqual(Orthography.Ruby.Global.format(identifier), "$fast_jpeg_decompressor")
        XCTAssertEqual(Orthography.Swift.Var.format(identifier), "fastJPEGDecompressor")
        XCTAssertEqual(Orthography.Ruby.Constant.format(identifier), "FAST_JPEG_DECOMPRESSOR")
    }
    
    func testInitialAcronym() {
        var identifier = Identifier()
        identifier.appendAcronym("JSON")
        identifier.appendWord("Parser")
        XCTAssertEqual(Orthography.Generic.UpperCamelCase.format(identifier), "JsonParser")
        XCTAssertEqual(Orthography.Swift.TypeIdentifier.format(identifier), "JSONParser")
        XCTAssertEqual(Orthography.Generic.snake_case.format(identifier), "json_parser")
        XCTAssertEqual(Orthography.Swift.Func.format(identifier), "jsonParser")
        XCTAssertEqual(Orthography.Ruby.Constant.format(identifier), "JSON_PARSER")
    }

    func testParse() {
        XCTAssertEqual(
            Orthography.Swift.TypeIdentifier.format(
                try Orthography.Ruby.Constant.parse("JSON_PARSER")),
            "JSONParser")
        XCTAssertEqual(
            Orthography.Swift.TypeIdentifier.format(
                try Orthography.Generic.UpperCamelCase.parse("JsonParser")),
            "JSONParser")
        XCTAssertEqual(
            Orthography.Swift.Var.format(
                try Orthography.Swift.TypeIdentifier.parse("BBQSauce")),
            "bbqSauce")
        XCTAssertEqual(
            Orthography.Generic.SCREAMING_SNAKE_CASE.format(
                try Orthography.Swift.Var.parse("jumpThroughHoops")),
            "JUMP_THROUGH_HOOPS")
        XCTAssertEqual(
            Orthography.Generic.snake_case.format(
                try Orthography.Swift.TypeIdentifier.parse("YoureDoingWTFNow")),
            "youre_doing_wtf_now")
        XCTAssertEqual(
            Orthography(separator: "_", casing: .lower, acronyms: .upper).format(
                try Orthography.Swift.TypeIdentifier.parse("ImAlwaysLikeWTF")),
            "im_always_like_WTF")
    }
    
    func testParseCase() {
        XCTAssertThrowsError(try Orthography.Swift.Var.parse("BBQSauce"), "", checkForInvalidCasing)
        XCTAssertThrowsError(try Orthography(separator: "_", casing: .title).parse("Too_small"), "", checkForInvalidCasing)
        XCTAssertThrowsError(try Orthography(separator: "_", casing: .title).parse("Too_BIG"), "", checkForInvalidCasing)
        XCTAssertThrowsError(try Orthography.Generic.SCREAMING_SNAKE_CASE.parse("WHISPER_softly"), "", checkForInvalidCasing)
        XCTAssertThrowsError(try Orthography(separator: "_", casing: .screaming, acronyms: .upper).parse("json_PARSER"), "", checkForInvalidCasing)
    }
    
    func testFuzzyParse() {
        let o = Orthography(separator: "_", casing: .lower, acronyms: .upper)
        XCTAssertEqual(
            o.format(Identifier.fuzzyParse("random json words")),
            "random_JSON_words")
        XCTAssertEqual(
            o.format(Identifier.fuzzyParse("snake_json")),
            "snake_JSON")
        XCTAssertEqual(
            o.format(Identifier.fuzzyParse("SCREAMING_SNAKE_JSON")),
            "screaming_snake_JSON")
        XCTAssertEqual(
            o.format(Identifier.fuzzyParse("camelJSON")),
            "camel_JSON")
        XCTAssertEqual(
            o.format(Identifier.fuzzyParse("UpperCamelJSON")),
            "upper_camel_JSON")
    }

    static var allTests = [
        ("testCodingTransform", testCodingTransform),
        ("testBasics", testBasics),
        ("testInitialAcronym", testInitialAcronym),
        ("testParse", testParse),
        ("testParseCase", testParseCase),
        ("testFuzzyParse", testFuzzyParse),
    ]
    
}
