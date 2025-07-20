# swift-casification

[![SwiftPM 6.2](https://img.shields.io/badge/swiftpm-6.2-ED523F.svg?style=flat)](https://swift.org/download/) ![Platforms](https://img.shields.io/badge/Platforms-iOS_13_|_macOS_10.15_|_Catalyst_|_tvOS_14_|_watchOS_7-ED523F.svg?style=flat) [![@capture_context](https://img.shields.io/badge/contact-@capture__context-1DA1F2.svg?style=flat&logo=twitter)](https://twitter.com/capture_context) 

Package for tokenizing and case swapping for free strings

## Usage

There are a bunch of predefined case modifiers that you can use out of the box

#### Basic

| Modifiers    | Examples                  |
| :----------- | ------------------------- |
| `upper`      | string -> STRING          |
| `lower`      | STRING → string           |
| `upperFirst` | strinG → StrinG           |
| `lowerFirst` | STRINg → sTRINg           |
| `capital`    | some string → Some String |
| `swap`       | Some String → sOME sTRING |

Any case modifiers can be combined with other ones by calling `combined(with:)`, keep in mind that the order matters and transformations are applied sequentially

```swift
"myString".case(.lower.combined(with: .upperFirst)) // Mystring
```

#### Programming

Those modifiers are a bit more compex and do support configuration

- `String.Casification.PrefixPredicate` allows to configure allowed prefixes, `.swiftDeclarations` is used by default allowing `$` and `_` symbols for prefixes
- You can also pass list of acronyms, default list can be found here [`String.Casification.standardAcronyms`](./Sources/Casification/Casification.swift), there is no way to modify this list at least yet, but you can explicitly specify your own, we'll add modification mechanism in future versions of the library

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
> _Check out [Tests](./Tests/CasificationTests) for more examples_

### Creating custom modifiers

For simple modifiers conforming your types to `String.Casification.Modifier` should be enough

```swift
extension String.Casification.Modifiers {
  public struct Delete: String.Casification.Modifier {
    public init() {}
    
    @inlinable 
    public func transform(_ input: Substring) -> Substring {
      ""
    }
  }
}

extension String.Casification.Modifier
where Self == String.Casification.Modifiers.Delete {
  @inlinable
  public var delete: Self { .init() }
}

func test() {
  "myString".case(.delete) // ""
}
```

For complex processing you can process [tokens](./Sources/Casification/Casification.swift) instead of raw strings by creating a type conforming to `String.Casification.TokensProcessor`

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

// This declaration looks heavy, but allows to
// create a modifier from tokens processor without
// creating a separate modifier type
extension String.Casification.Modifier
where Self == String.Casification.Modifier.ProcessingTokens<
  String.Casification.TokensProcessors.RemoveSeparators
>{
  @inlinable
  public var noSeparators: Self {
    .init(using: .init())
  }
}

func test() {
  "my test-string".case(.noSeparators.combined(with: .upper)) // "MYTESTSTRING"
}
```

## Installation

### Basic

You can add Casification to an Xcode project by adding it as a package dependency.

1. From the **File** menu, select **Swift Packages › Add Package Dependency…**
2. Enter [`"https://github.com/capturecontext/swift-casification.git"`](https://github.com/capturecontext/swift-casification.git) into the package repository URL text field
3. Choose products you need to link them to your project.

### Recommended

If you use SwiftPM for your project, you can add StandardExtensions to your package file.

```swift
.package(
  url: "https://github.com/capturecontext/swift-casification.git", 
  .upToNextMinor(from: "0.0.1")
)
```

Do not forget about target dependencies:

```swift
.product(
  name: "Casification", 
  package: "swift-casification"
)
```

## License

This library is released under the MIT license. See [LICENSE](LICENSE) for details.
