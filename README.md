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
| `upper`      | string → STRING           |
| `lower`      | STRING → string           |
| `upperFirst` | String → String           |
| `lowerFirst` | STRING → sTRING           |
| `capital`    | some string → Some String |
| `swap`       | Some String → sOME sTRING |

### Token-based modifiers

Those modifiers are a bit more complex and do support configuration

- `String.Casification.PrefixPredicate` allows configuring allowed prefixes, `.swiftDeclarations` is used by default allowing `$` and `_` symbols for prefixes
- You can also provide a list of acronyms. The default list is available at [`String.Casification.standardAcronyms`](./Sources/Casification/Casification.swift), there is no way to modify this list at least yet, but you can explicitly specify your own, we'll add modification mechanism in future versions of the library.

| Modifiers           | Examples                  |
| ------------------- | ------------------------- |
| `camel(.camel)`     | some string → someString  |
| `camel(.pascal)`    | some string → SomeString  |
| `camel`            | some string → someString  |
| `pascal`           | some string → SomeString  |
| `camel(.automatic)` | some string → someString  |
| `camel(.automatic)` | Some string → SomeString  |
| `snake()`           | some string → some_string |
| `kebab()`           | some string → some-string |
| `dot()`             | some string → some.string |

>  [!NOTE] 
>
> _See [Tests](./Tests/CasificationTests) for more examples_

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
  .upToNextMinor("0.2.0")
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
