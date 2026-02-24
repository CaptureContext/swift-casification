# swift-casification

[![CI](https://github.com/capturecontext/swift-casification/actions/workflows/ci.yml/badge.svg)](https://github.com/capturecontext/swift-casification/actions/workflows/ci.yml) [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fcapturecontext%2Fswift-casification%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/capturecontext/swift-casification) [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fcapturecontext%2Fswift-casification%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/capturecontext/swift-casification)

Package for tokenizing and applying case transformations to arbitrary strings.

## Table of contents

- [Motivation](#motivation)
- [Usage](#usage)
  - [Basic modifiers](#basic-modifiers)
  - [Token-based modifiers](#token-based-modifiers)
  - [Composing modifiers](#composing-modifiers)
  - [Custom modifiers](#custom-modifiers)
- [Installation](#installation)
- [License](#license)

## Motivation

Swift does not provide a standard way to tokenize strings or to build formatted strings from such tokens.

As a result, even common transformations like `camelCase` are often implemented differently across projects, leading to duplicated logic and inconsistent results.

This package focuses on providing a set of predefined, reusable string modifiers for common casing and formatting transformations, with consistent behavior across codebases.

## Usage

A set of predefined string modifiers is available out of the box

### Basic modifiers

| Modifiers    | Examples                  |
| :----------- | ------------------------- |
| `upper`      | some string → SOME STRING |
| `lower`      | Some string → some string |
| `upperFirst` | some String → Some String |
| `lowerFirst` | Some string → some String |
| `capital`    | some string → Some String |
| `swap`       | Some String → sOME sTRING |

### Token-based modifiers

Those modifiers are a bit more complex and do support configuration

| Modifiers           | Examples                  |
| ------------------- | ------------------------- |
| `camel(.camel)` | `camel` | Some string 1 x value → someString_1xValue |
| `camel(.pascal)`  | `pascal` | Some string 1 x value → SomeString_1xValue |
| `camel` | `camel(.camel)` | some string 1 x value → someString_1xValue |
| `pascal` | `camel(.pascal)` | some string 1 x value → SomeString_1xValue |
| `camel(.automatic)` | `camel()` | some string 1 x value → someString_1xValue |
| `camel(.automatic)` | `camel()` | Some string 1 x value → SomeString_1xValue |
| `snake`           | some string 1 x value → some_string_1x_value |
| `kebab`           | some string 1 x value → some-string-1x-value |
| `dot`             | some string 1 x value → some.string.1x.value |

>  [!NOTE] 
>
> _See [Tests](./Tests/CasificationTests) for more examples_

#### Configuration

Tokenization uses list of acronyms to properly handle common values like `UUID`, but the list is limited and statically defined, which may lead to tokenization misses for such values. Tokenization misses will lead to incorrect formatting for some modifiers.

There are 2 ways to override existing acronyms

First one is overriding default values globally using `prepareConfiguration(_:)` function and should be performed at the application start (as early as possible):

```swift
String.Casification.prepareConfiguration { 
  $0.acronyms.formUnion(["uml", "Uml", "UML"])              
}

"uml_string".case(.pascal) // UMLString
```

Second one is providing contextual override using `withAcronyms(_:operation:)` function:

```swift
"uml_string".case(.pascal) // UmlString

withAcronyms { $0 
	.formUnion(["uml", "Uml", "UML"]) 
} operation: {
	"uml_string".case(.pascal) // UMLString
}
```

> [!TIP]
>
> _Explore [Configuration](./Sources/Casification/Configuration) to find out more about available options, for example predefined modifiers do handle numbers gently out-of-the box:_
>
> `"1.23 in a Sentence".case(.pascal)` → `"1_23_InASentence"`
>
> `"Lens1x".case(.snake)` → `"lens_1x"` instead of `"lens_1_x"`
>
> `"Grid1x1".case(.camel)` → `"grid_1x1"` instead of `"grid_1_X_1"`
>
> _Though you can disable this behavior with:_
>
> ```swift
> String.Casification.prepareConfiguration {
>   // Default is `[.singleLetter([.disableSeparators, .disableNextTokenProcessing])]`
>   $0.common.numbers.boundaryOptions = []
>   
>   // You can also enable allowed delimeters
>   // "1.23 String".case(.snake) -> 1.23_string
>   $0.common.numbers.allowedDelimeters = ["."]
> }
> ```

#### Camel

Camel case modifiers do also support advanced configuration

You can use explicit parameters:

```swift
"string_id".case(.camel()) // stringID

withCasification { $0.camelCase.acronyms.processingPolicy = .alwaysCapitalize } operation: {
	"string_id".case(.camel(.)) // stringId
}
```

You can override default config using `prepareConfiguration(_:)` function and it also should be performed at the application start (as early as possible):

```swift
String.Casification.prepareConfiguration {
  $0.camelCase.acronyms.processingPolicy = .alwaysCapitalize
}

"string_id".case(.camel()) // stringId
```

### Composing modifiers

Modifiers can be combined using `combined(with:)` method. Order matters – transformations are applied sequentially.

```swift
// "myString" → "mystring" → "Mystring"
"myString".case(.lower.combined(with: .upperFirst))
```

```swift
// "myString" → "Mystring" → "mystring"
"myString".case(.upperFirst.combined(with: .lower)) // mystring
```

### Custom modifiers

For simple modifiers, conforming a type to `String.Casification.Modifier` is enough

```swift
extension String.Casification.Modifiers {
  /// Deletes input string
  public struct Delete: String.Casification.Modifier {
    public init() {}
    
    @inlinable 
    public func transform(_ input: Substring) -> Substring {
      ""
    }
  }
}
```

> [!TIP]
>
> It's a good idea to declare convenience accessor for the protocol
> ```swift
> extension String.Casification.Modifier
> where Self == String.Casification.Modifiers.Delete {
>      public var delete: Self { .init() }
> }
> ```
>
> ```swift
> "myString".case(.delete) // ""
> ```

For more complex processing, you can operate on [tokens](./Sources/Casification/Casification.swift) instead of raw strings by conforming to `String.Casification.TokensProcessor`

```swift
extension String.Casification.TokensProcessors {
  public struct RemoveSeparators: String.Casification.TokensProcessor {
    public init() {}
    @inlinable
    public func processTokens(
      _ tokens: ArraySlice<String.Casification.Token>
    ) -> ArraySlice<String.Casification.Token> {
      return filter { $0.kind != .separator }[...]
    }
  }
}

extension String.Casification.Modifier
where Self == String.Casification.Modifier.ProcessingTokens<
  String.Casification.TokensProcessors.RemoveSeparators
>{
  public var noSeparators: Self {
    .init(using: .init())
  }
}
```

```swift
"my test-string".case(.noSeparators) // "myteststring"
```

> [!NOTE]
>
> _The package is primarily designed around predefined reusable modifiers. Custom modifiers are supported, but declarations can be verbose due to namespacing and generic types._

## Installation

### Basic

You can add `swift-casification` to an Xcode project by adding it as a package dependency.

1. From the **File** menu, select **Swift Packages › Add Package Dependency…**
2. Enter [`"https://github.com/capturecontext/swift-casification"`](https://github.com/capturecontext/swift-casification) into the package repository URL text field
3. Choose products you need to link to your project.

### Recommended

If you use SwiftPM for your project structure, add `swift-casification` dependency to your package file

```swift
.package(
  url: "https://github.com/capturecontext/swift-casification.git", 
  .upToNextMinor("0.5.0")
)
```

Do not forget about target dependencies

```swift
.product(
  name: "Casification", 
  package: "swift-casification"
)
```

## License

This library is released under the MIT license. See [LICENSE](LICENSE) for details.
