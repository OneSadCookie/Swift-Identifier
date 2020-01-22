# Swift-Identifier

Transform programming language identifiers from one style to another:

```swift
let ident = Orthography.Generic.screaming_snake_case.parse("THIS_IS_A_CONSTANT")
Orthography.Swift.Var.format(ident)
    => "thisIsAConstant"
```

You can invent your own orthographies if the built-in ones don't fit your needs (and please consider making a pull request!)

There's also functionality to do a "fuzzy parse" of an identifier in an unknown format:

```swift
let ident = Identifer.fuzzyParse("SomeRandomInput")
Orthography.Generic.snake_case.format(ident)
    => "some_random_input"
```

It tries to be generally sensible with and of different styles' ideas of what to do with acronyms:

```swift
let ident = Orthography.Swift.TypeIdentifier.parse("URLSession")
Orthography.Swift.Var.format(ident)
    => "urlSession"
Orthography.Generic.UpperCamelCase.format(ident)
    => "UrlSession"
```

Thanks to [TransformCoding](https://github.com/OneSadCookie/TransformCoding), you can also directly
decode identifiers from JSON:

```swift
struct MyJSONObject: Codable {
    @TransformCoding<Orthography.Generic.SCREAMING_SNAKE_CASE>
    var ident: Identifier
}
```

## Swift Package Manager

Add to your `Package.swift`'s `dependencies`: array:

```swift
.package(url: "https://github.com/onesadcookie/Swift-Identifier.git", .exact("0.2.1")),
```

You should currently always depend upon an *exact* version of Swift-Identifier, as there are a lot of
edge cases where behavior is not well-specified (or particularly well-tested) and minor changes to the
algorithms could lead to breaking results you rely on.
