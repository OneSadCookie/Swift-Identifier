import TransformCoding

private let swiftLower = Orthography(casing: .inverseSentence, acronyms: .upperUnlessInitial)

/// By default, these will use `AcronymHandling.CommonAcronyms` to guess acronyms.
/// If you need control over that, wrap one of these up in `WithAcronyms`.
public protocol PredefinedOrthography: TransformCodable where
    EncodedType == String,
    DecodedType == Identifier
{
    static var orthography: Orthography { get }
}

extension PredefinedOrthography {

    public static func transformEncode(_ value: Identifier) throws -> String {
        orthography.format(value)
    }

    public static func transformDecode(_ encoded: String) throws -> Identifier {
        try orthography.parse(encoded)
    }

}

extension PredefinedOrthography {

    public static func parse(
        _ string: String,
        isAcronym: (String) -> Bool = AcronymHandling.CommonAcronyms.isAcronym(_:)
    ) throws -> Identifier {
        try orthography.parse(string, isAcronym: isAcronym)
    }

    public static func parse<A: AcronymList>(
        _ string: String,
        acronymList: A.Type
    ) throws -> Identifier {
        try orthography.parse(string, acronymList: acronymList)
    }
    
    public static func format(_ identifier: Identifier) -> String {
        orthography.format(identifier)
    }

}

extension Orthography {

    /// some common, generally-useful convenience orthographies
    public struct Generic {
        public struct snake_case: PredefinedOrthography {
            public static let orthography = Orthography(separator: "_", casing: .lower)
        }
        public struct SCREAMING_SNAKE_CASE: PredefinedOrthography {
            public static let orthography = Orthography(separator: "_", casing: .screaming)
        }
        public struct camelCase: PredefinedOrthography {
            public static let orthography = Orthography(casing: .inverseSentence)
        }
        public struct UpperCamelCase: PredefinedOrthography {
            public static let orthography = Orthography(casing: .title)
        }
    }

    public struct Swift {
        public struct Case: PredefinedOrthography {
            public static let orthography = swiftLower
        }
        public struct Func: PredefinedOrthography {
            public static let orthography = swiftLower
        }
        public struct PropertyWrapper: PredefinedOrthography {
            public static let orthography = Orthography(wart: "@", casing: .title, acronyms: .upper)
        }
        public struct TypeIdentifier: PredefinedOrthography {
            public static let orthography = Orthography(casing: .title, acronyms: .upper)
        }
        public struct Var: PredefinedOrthography {
            public static let orthography = swiftLower
        }
    }
    
    public struct Ruby {
        public struct Constant: PredefinedOrthography {
            public static let orthography = Orthography(separator: "_", casing: .screaming)
        }
        public struct Global: PredefinedOrthography {
            public static let orthography = Orthography(wart: "$", separator: "_", casing: .lower)
        }
        public struct IVar: PredefinedOrthography {
            public static let orthography = Orthography(wart: "@", separator: "_", casing: .lower)
        }
        public struct Method: PredefinedOrthography {
            public static let orthography = Orthography(separator: "_", casing: .lower)
        }
        public struct TypeIdentifier: PredefinedOrthography {
            public static let orthography = Orthography(casing: .title, acronyms: .upper)
        }
    }
    
    public struct GraphQL {
        public struct EnumValue: PredefinedOrthography {
            public static let orthography = Orthography(separator: "_", casing: .screaming)
        }
        public struct Field: PredefinedOrthography {
            public static let orthography = Orthography(casing: .inverseSentence)
        }
        public struct TypeIdentifier: PredefinedOrthography {
            public static let orthography = Orthography(casing: .title)
        }
    }

}
