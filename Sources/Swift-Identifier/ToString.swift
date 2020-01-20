extension Orthography {

    func toStringInternal(_ identifier: Identifier) -> String {
        var result = wart
        for (i, part) in identifier.parts.enumerated() {
            if i != 0, let separator = separator {
                result.append(separator)
            }
            writePart(part, to: &result, isFirstWord: i == 0)
        }
        return result
    }
    
    private func writePart(_ part: Identifier.Part, to string: inout String, isFirstWord: Bool) {
        switch part {
        case let .word(s):
            for (i, c) in s.enumerated() {
                writeChar(c, case: casing, to: &string, isFirstWord: isFirstWord, isFirstChar: i == 0)
            }
        
        case let .acronym(s):
            switch (isFirstWord, acronyms) {
            case (_, .asWords), (true, .upperUnlessInitial):
                writePart(.word(s), to: &string, isFirstWord: isFirstWord)
            case (_, .upper), (false, .upperUnlessInitial):
                for (i, c) in s.enumerated() {
                    writeChar(c, case: .screaming, to: &string, isFirstWord: isFirstWord, isFirstChar: i == 0)
                }
            }
        }
    }
    
    private func writeChar(
        _ character: Character,
        case: Casing,
        to string: inout String,
        isFirstWord: Bool,
        isFirstChar: Bool
    ) {
        switch (`case`, isFirstWord, isFirstChar) {
        case (.lower,           _,     _),
             (.title,           _,     false),
             (.sentence,        false, _),
             (.sentence,        true,  false),
             (.inverseSentence, true,  _),
             (.inverseSentence, false, false):
            string.append(character.lowercased())
        case (.title,           _,     true),
             (.sentence,        true,  true),
             (.inverseSentence, false, true),
             (.screaming,       _,     _):
            string.append(character.uppercased())
        }
    }

}
