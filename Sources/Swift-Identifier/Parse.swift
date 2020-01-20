func camelParse(
    _ string: String,
    _ acronyms: AcronymHandling,
    _ isAcronym: (String) -> Bool
) -> [Identifier.Part] {
    var buffer: String = ""
    var bits: [String] = []
    for char in string {
        if char.isUppercase {
            if buffer.isEmpty {
                buffer.append(char)
            } else {
                bits.append(buffer)
                buffer = String(char)
            }
        } else {
            buffer.append(char)
        }
    }
    if !buffer.isEmpty {
        bits.append(buffer)
        buffer = ""
    }
    var result: [Identifier.Part] = []
    for bit in bits {
        if bit.count == 1 {
            buffer.append(bit)
        } else {
            if !buffer.isEmpty {
                result.append(.acronym(buffer))
                buffer = ""
            }
            switch (acronyms, result.isEmpty) {
            case (.asWords,            _),
                 (.upperUnlessInitial, true):
                result.append(isAcronym(bit) ? .acronym(bit) : .word(bit))
            default:
                result.append(.word(bit))
            }
        }
    }
    if !buffer.isEmpty {
        result.append(.acronym(buffer))
    }
    return result
}

extension Orthography {

    func parseInternal(_ string: String, _ isAcronym: (String) -> Bool) throws -> Identifier {
        let parts: [Identifier.Part]
        if let separator = separator {
            parts = string.split(separator: separator).enumerated().map { pair in
                let (i, part) = pair
                return guessPart(String(part), isFirstWord: i == 0, isAcronym)
            }
        } else {
            parts = camelParse(string, acronyms, isAcronym)
        }
        for (i, part) in parts.enumerated() {
            try checkCase(part, isFirstWord: i == 0)
        }
        return Identifier(parts: parts)
    }
    
    private func guessPart(
        _ part: String,
        isFirstWord: Bool,
        _ isAcronym: (String) -> Bool
    ) -> Identifier.Part {
        switch (casing, acronyms, isFirstWord) {
        case (.screaming,       _,                   _),
             (.lower,           .asWords,            _),
             (_,                .upperUnlessInitial, true),
             (.inverseSentence, .asWords,            true):
            if isAcronym(part) {
                return .acronym(part)
            } else {
                return .word(part)
            }
        default:
            if part.allSatisfy({ $0.isUppercase }) {
                return .acronym(part)
            } else {
                return .word(part)
            }
        }
    }
    
    private func checkCase(_ part: Identifier.Part, isFirstWord: Bool) throws {
        switch (part, acronyms, isFirstWord) {
        case let (.word(word),    _,                   _),
             let (.acronym(word), .asWords,            _),
             let (.acronym(word), .upperUnlessInitial, true):
            switch (casing, isFirstWord) {
            case (.lower,           _),
                 (.sentence,        false),
                 (.inverseSentence, true):
                guard word.allSatisfy({ $0.isLowercase }) else {
                    throw ParseError.invalidCasing
                }
            case (.title,           _),
                 (.sentence,        true),
                 (.inverseSentence, false):
                var it = word.makeIterator()
                if let c = it.next() {
                    guard c.isUppercase else {
                        throw ParseError.invalidCasing
                    }
                }
                guard IteratorSequence(it).allSatisfy({ $0.isLowercase }) else {
                    throw ParseError.invalidCasing
                }
            case (.screaming, _):
                guard word.allSatisfy({ $0.isUppercase }) else {
                    throw ParseError.invalidCasing
                }
            }
        case let (.acronym(acronym), .upper,              _),
             let (.acronym(acronym), .upperUnlessInitial, false):
            guard acronym.allSatisfy({ $0.isUppercase }) else {
                throw ParseError.invalidCasing
            }
        }
    }
    
}
