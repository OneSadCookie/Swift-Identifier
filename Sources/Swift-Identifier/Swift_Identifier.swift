/// describes the case of letters in identifiers
public enum Casing: Hashable {
    /// all words lowercase
    case lower
    /// All Words Initial Upper
    case title
    /// First word initial upper
    case sentence
    /// all But First Word Initial Upper
    case inverseSentence
    /// ALL CAPS ALL THE TIME
    case screaming    
}

/// describes how acronyms should be cased in identifiers
public enum AcronymHandling: Hashable {
    /// acronyms are cased exactly like any other word (eg. Rust)
    case asWords
    /// acronyms are always ALL CAPS (eg. ObjC)
    case upper
    /// acronyms are ALL CAPS unless they're the first word (eg. Swift)
    case upperUnlessInitial
}

/// Completely describes how to construct an identifier
public struct Orthography: Equatable {

    public enum ParseError: Error {
        case invalidCasing
    }

    /// leading sigil, eg `"_"`, `"$"` or `"@"`
    public var wart: String
    /// separator between words, eg. `"_"`. `nil` means camelCase.
    public var separator: Character?
    public var casing: Casing
    public var acronyms: AcronymHandling
    
    public init(
        wart: String = "",
        separator: Character? = nil,
        casing: Casing,
        acronyms: AcronymHandling = .asWords
    ) {
        self.wart = wart
        self.separator = separator
        self.casing = casing
        self.acronyms = acronyms
    }
    
    public func format(_ identifier: Identifier) -> String {
        toStringInternal(identifier)
    }
    
    public func parse(
        _ string: String,
        isAcronym: (String) -> Bool = isCommonAcronym
    ) throws -> Identifier {
        try parseInternal(string, isAcronym)
    }
    
}

/// a parsed identifier, ready to be reformatted in a different style.
/// use it in your code in place of `String`.
public struct Identifier {

    enum Part {
        case word(String)
        case acronym(String)
    }
    
    var parts: [Part]
    
    /// create an empty identifier
    public init() {
        self.init(parts: [])
    }
    
    init(parts: [Part]) {
        self.parts = parts
    }
    
    /// append a word segment to the identifier
    public mutating func appendWord(_ word: String) {
        parts.append(.word(word))
    }
    
    /// append an acronym segment to the identifier
    public mutating func appendAcronym(_ acronym: String) {
        parts.append(.acronym(acronym))
    }
    
    /// parse any string, but probably badly. Prefer to use `Orthography.parse` if you
    /// know what the string looks like.
    static func fuzzyParse(
        _ string: String,
        isAcronym: (String) -> Bool = isCommonAcronym
    ) -> Identifier {
        fuzzyParseInternal(string, isAcronym)
    }

}

private let commonAcronyms = Set([
    "html", "http", "https",
    "jpeg", "jpg", "json",
    "pdf", "png",
    "ssh", "svg",
    "url", "utf8", "utf16",
    "xml",
])

/// A helpful list of acronyms commonly found in programming identifiers.
/// Pull requests welcome!
/// You can provide your own instead, or build your own around this one.
public func isCommonAcronym(_ string: String) -> Bool {
    commonAcronyms.contains(string.lowercased())
}
