import Foundation

extension Identifier {

    static func fuzzyParseInternal(_ string: String, _ isAcronym: (String) -> Bool) -> Identifier {
        do {
            // try splitting on whitespaces
            let words = string.components(separatedBy: .whitespacesAndNewlines)
            if words.count > 1 {
                return fromBits(words, isAcronym)
            }
        }
        
        do {
            // try splitting on punctuation
            let words = string.components(separatedBy: .punctuationCharacters)
            if words.count > 1 {
                return fromBits(words, isAcronym)
            }
        }
        
        // fall back to camel parse, which'll at worst produce a single part
        return Identifier(parts: camelParse(string, .asWords, isAcronym))
    }
    
    private static func fromBits(_ bits: [String], _ isAcronym: (String) -> Bool) -> Identifier {
        Identifier(parts: bits.map {
            isAcronym($0) ? .acronym($0) : .word($0)
        })
    }

}
