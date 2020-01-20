import TransformCoding

public protocol AcronymList {

    static func isAcronym(_ string: String) -> Bool

}

private let commonAcronyms = Set([
    "html", "http", "https",
    "jpeg", "jpg", "json",
    "pdf", "png",
    "ssh", "svg",
    "url", "utc", "utf8", "utf16",
    "xml",
])

extension AcronymHandling {

    /// Never try to guess which words are acronyms, assume if it looks like a word
    /// it's a word.
    public struct NoAcronyms: AcronymList {
        public static func isAcronym(_ string: String) -> Bool {
            false
        }
    }
    
    /// A helpful list of acronyms commonly found in programming identifiers.
    /// Pull requests welcome!
    /// You can provide your own instead, or build your own around this one.
    public struct CommonAcronyms: AcronymList {
        public static func isAcronym(_ string: String) -> Bool {
            commonAcronyms.contains(string.lowercased())
        }
    }
    
    /// Whether "id" is a word or an acronym seems controversial, and possibly
    /// context-dependent; for that reason it's not in the common list. Use this
    /// to add it easily to any list.
    public struct IDOr<A: AcronymList>: AcronymList {
        public static func isAcronym(_ string: String) -> Bool {
            string.lowercased() == "id" || A.isAcronym(string)
        }
    }

}

public struct WithAcronyms<O: PredefinedOrthography, A: AcronymList>: TransformCodable {

    public typealias EncodedType = String
    public typealias DecodedType = Identifier
    
    public static func transformEncode(_ value: Identifier) throws -> String {
        O.orthography.format(value)
    }

    public static func transformDecode(_ encoded: String) throws -> Identifier {
        try O.orthography.parse(encoded, isAcronym: A.isAcronym(_:))
    }

}
