import Foundation
import IssueReporting
import ConcurrencyExtras

extension String.Casification {
	public struct CamelCaseConfig: Equatable, Sendable {
		public var mode: Mode
		public var numbers: Numbers
		public var acronyms: Acronyms

		public init(
			mode: Mode = Self.default.mode,
			numbers: Numbers = Self.default.numbers,
			acronyms: Acronyms = Self.default.acronyms
		) {
			self.mode = mode
			self.numbers = numbers
			self.acronyms = acronyms
		}

		@usableFromInline
		func withMode(_ mode: Mode) -> Self {
			.init(mode: mode, numbers: numbers, acronyms: acronyms)
		}

		public enum Mode: Equatable, Sendable {
			public static let standard: Self = .automatic
			public static var `default`: Self { CamelCaseConfig.default.mode }

			case automatic
			case camel
			case pascal
		}

		public struct Numbers: Equatable, Sendable {
			public static let standard: Self = .init(
				nextTokenMode: .standard,
				separator: "_",
				singleLetterBounaryOptions: .standard
			)

			public static var `default`: Self { .init() }

			public var nextTokenMode: NextTokenMode
			public var separator: Substring
			public var singleLetterBounaryOptions: SingleLetterBoundaryOptions

			public init(
				nextTokenMode: NextTokenMode = .default,
				separator: Substring = CamelCaseConfig.default.numbers.separator,
				singleLetterBounaryOptions: SingleLetterBoundaryOptions = .default
			) {
				self.nextTokenMode = nextTokenMode
				self.separator = separator
				self.singleLetterBounaryOptions = singleLetterBounaryOptions
			}

			public struct SingleLetterBoundaryOptions: OptionSet, Equatable, Sendable {
				public static let standard: Self = [
					.disableSeparators,
					.disableNextTokenProcessing
				]

				public static var `default`: Self {
					CamelCaseConfig.default.numbers.singleLetterBounaryOptions
				}

				public var rawValue: UInt

				public init(rawValue: UInt) {
					self.rawValue = rawValue
				}

				public static var disableSeparators: Self { .init(rawValue: 1 << 1) }
				public static var disableNextTokenProcessing: Self { .init(rawValue: 1 << 1) }
			}

			public enum NextTokenMode: Equatable, Sendable {
				public static let standard: Self = .inherit
				public static var `default`: Self { CamelCaseConfig.default.numbers.nextTokenMode }

				case inherit
				case override(Mode = .automatic)

				public var overridenValue: Mode? {
					switch self {
					case let .override(mode): mode
					default: nil
					}
				}
			}
		}

		public struct Acronyms: Equatable, Sendable {
			public static let standard: Self = .init(processingPolicy: .standard)
			public static var `default`: Self { .init() }

			@usableFromInline
			var processingPolicy: ProcessingPolicy

			public init(
				processingPolicy: ProcessingPolicy = CamelCaseConfig.default.acronyms.processingPolicy
			) {
				self.processingPolicy = processingPolicy
			}

			public enum ProcessingPolicy: Equatable, Sendable {
				public static let standard: Self = .alwaysMatchCase
				public static var `default`: Self { CamelCaseConfig.default.acronyms.processingPolicy }

				/// Keep acronyms as parsed
				///
				/// Examples:
				/// - `"ID"` → `"ID"`
				/// - `"Id"` → `"Id"`
				/// - `"id"` → `"id"`
				///
				/// - Warning: Overrides camel case mode  when the first token is acronym
				///
				/// Examples:
				/// - `"someString"` → `"someString"`
				/// - `"uuidString"` → `"uuidString"`
				/// - `"UuidString"` → `"UuidString"`
				/// - `"UUIDString"` → `"UUIDString"`
				case preserve

				/// Always uppercase or lowercase acronyms
				///
				/// **Default processing policy**
				///
				/// Examples:
				/// - `"ID"` → `"ID"`, or `"id"` if first token
				/// - `"Id"` → `"ID"`, or `"id"` if first token
				/// - `"id"` → `"ID"`, or `"id"` if first token
				case alwaysMatchCase

				/// Always capitalize acronyms
				///
				/// Examples:
				/// - `"ID"` → `"Id"`
				/// - `"Id"` → `"Id"`
				/// - `"id"` → `"Id"`
				///
				/// - Warning: Overrides `Mode.camel` when the first token is acronym
				///
				/// Examples:
				/// - `"someString"` → `"someString"`
				/// - `"uuidString"` → `"UuidString"`
				case alwaysCapitalize

				/// Always capitalize acronyms
				///
				/// First token behaves like `.alwaysMatchCase`, rest tokens are processed like `.alwaysCapitalize`
				///
				/// Examples:
				/// - `"ID"` → `"Id"`, or `"id"/"ID"` if first token
				/// - `"Id"` → `"Id"`, or `"id"/"ID"` if first token
				/// - `"id"` → `"Id"`, or `"id"/"ID"` if first token
				case conditionalCapitalization
			}
		}
	}
}

extension String.Casification.Modifiers {
	public struct Camel<
		PrefixPredicate: String.Casification.PrefixPredicate
	>: String.Casification.Modifier {
		public typealias Config = String.Casification.CamelCaseConfig
		public typealias SeparatorTokenProcessor = String.Casification.TokenProcessor

		@usableFromInline
		struct FirstTokenModifier: String.Casification.Modifier {
			@usableFromInline
			internal var config: Config

			@usableFromInline
			init(config: Config) {
				self.config = config
			}

			@usableFromInline
			func withMode(
				_ mode: Config.Mode
			) -> Self {
				.init(config: config.withMode(mode))
			}

			@usableFromInline
			func transform(_ input: Substring) -> Substring {
				switch config.mode {
				case .automatic:
					guard let first = input.first
					else { return input }

					return first.isLowercase
					? input.case(withMode(.camel))
					: input.case(withMode(.pascal))

				case .pascal:
					guard Set.standardAcronyms.contains(input)
					else { return input.case(.lower.combined(with: .upperFirst)) }

					switch config.acronyms.processingPolicy {
					case .preserve:
						return input
					case .alwaysMatchCase, .conditionalCapitalization:
						return input.case(.upper)
					case .alwaysCapitalize:
						return input.case(.lower.combined(with: .upperFirst))
					}

				case .camel:
					guard Set.standardAcronyms.contains(input)
					else { return input.case(.lower) }

					switch config.acronyms.processingPolicy {
					case .preserve:
						return input
					case .alwaysMatchCase, .conditionalCapitalization:
						return input.case(.lower)
					case .alwaysCapitalize:
						return input.case(.lower.combined(with: .upperFirst))
					}
				}
			}
		}

		@usableFromInline
		struct RestTokensModifier: String.Casification.Modifier {
			@usableFromInline
			internal var acronyms: Config.Acronyms

			@usableFromInline
			init(
				acronyms: Config.Acronyms
			) {
				self.acronyms = acronyms
			}

			@usableFromInline
			func transform(_ input: Substring) -> Substring {
				guard Set.standardAcronyms.contains(input)
				else { return input.case(.lower.combined(with: .upperFirst)) }

				switch acronyms.processingPolicy {
				case .preserve:
					return input
				case .alwaysMatchCase:
					return input.case(.upper)
				case .alwaysCapitalize, .conditionalCapitalization:
					return input.case(.lower.combined(with: .upperFirst))
				}
			}
		}

		@usableFromInline
		internal let config: Config

		@usableFromInline
		internal let prefixPredicate: PrefixPredicate

		@usableFromInline
		internal let separatorTokenProcessor: SeparatorTokenProcessor

		@inlinable
		public init(
			config: Config = .init(),
			prefixPredicate: PrefixPredicate
		) {
			self.init(
				config: config,
				prefixPredicate: prefixPredicate,
				separatorTokenProcessor: .inline { index, tokens in
					guard let token = tokens[safe: index] else { return [] }

					let numericSeparatorToken = String.Casification.Token(
						config.numbers.separator,
						kind: .separator
					)

					let prevToken = tokens[safe: index - 1]
					let nextToken = tokens[safe: index + 1]

					do { // verify input
						let issuesLink = "https://github.com/capturecontext/swift-casification/issues"
						let actionMessage = "Please sumbit an issue here \(issuesLink)"

						if token.kind != .separator {
							reportIssue(
								"""
								separatorTokenProcessor should only be applied to separators
								\(actionMessage)
								"""
							)
						} else if nextToken?.kind == .separator || nextToken?.kind == .separator {
							reportIssue(
								"""
								Tokenization should not produce sequences of separators
								\(actionMessage)
								"""
							)
						}
					}

					let leadingNumericBoundary = prevToken?.value.last?.isNumber == true
					if leadingNumericBoundary {
						let removeSeparator = config.numbers.singleLetterBounaryOptions.contains(.disableSeparators)
						&& nextToken?.isSingleLetter == true
						return removeSeparator ? [] : [numericSeparatorToken]
					}

					let trailingNumericBoundary = nextToken?.value.first?.isNumber == true
					if trailingNumericBoundary {
						let removeSeparator = config.numbers.singleLetterBounaryOptions.contains(.disableSeparators)
						&& prevToken?.isSingleLetter == true
						return removeSeparator ? [] : [numericSeparatorToken]
					}

					return []
				}
			)
		}

		@usableFromInline
		internal init(
			config: Config = .init(),
			prefixPredicate: PrefixPredicate,
			separatorTokenProcessor: SeparatorTokenProcessor
		) {
			self.config = config
			self.prefixPredicate = prefixPredicate
			self.separatorTokenProcessor = separatorTokenProcessor
		}

		@inlinable
		public func transform(_ input: Substring) -> Substring {
			let defaultFirstModifier = FirstTokenModifier(config: config)
			let defaultRestModifier = RestTokensModifier(acronyms: config.acronyms)

			return input.case(String.Casification.Modifiers.ProcessingTokens(
				using: String.Casification.TokensProcessors._ProgrammingCaseModifiers(
					tokenProcessor: .inline { index, tokens in
						guard let token = tokens[safe: index] else { return [] }

						if token.kind == .separator {
							return separatorTokenProcessor.processToken(at: index, in: tokens)
						}

						if token.kind == .number {
							return [token]
						}

						let afterNumeric: Bool = tokens[safe: ..<index]
							.reversed()
							.first(where: { $0.kind != .separator })?.kind == .number

						let alreadyCaughtNonNumeric: Bool = tokens[safe: ..<index]
							.contains { [.word, .acronym].contains($0.kind) }

						if afterNumeric {
							if
								config.numbers.singleLetterBounaryOptions.contains(.disableNextTokenProcessing),
								token.value.count == 1,
								token.value.first?.isLetter == true
							{ return [token] }

							switch config.modeAfterNumber {
							case .automatic:
								var isPascal = false

								for token in tokens {
									if let letter = token.value.first(where: { $0.isLetter }) {
										isPascal = letter.isUppercase
										break
									}
								}

								if isPascal {
									return [token.withValue(defaultFirstModifier.withMode(.pascal).transform(token.value))]
								} else {
									return [token.withValue(defaultFirstModifier.withMode(.camel).transform(token.value))]
								}

							case .pascal:
								return [token.withValue(defaultFirstModifier.withMode(.pascal).transform(token.value))]

							case .camel:
								return [token.withValue(defaultFirstModifier.withMode(.camel).transform(token.value))]
							}
						}

						if alreadyCaughtNonNumeric {
							return [
								.init(
									defaultRestModifier.transform(token.value),
									kind: token.kind
								),
							]
						} else {
							return [
								.init(
									defaultFirstModifier.transform(token.value),
									kind: token.kind
								),
							]
						}
					},
					prefixPredicate: prefixPredicate,
				)
			))
		}
	}
}

extension String.Casification.Modifier where Self == String.Casification.Modifiers.Camel<
	String.Casification.PrefixPredicates.AllowedCharacters
> {
	@inlinable
	public static var camel: Self {
		.camel(.camel)
	}

	@inlinable
	public static var pascal: Self {
		.camel(.pascal)
	}

	@inlinable
	public static func camel(
		_ mode: String.Casification.CamelCaseConfig.Mode = .default,
		numbers: String.Casification.CamelCaseConfig.Numbers = .default,
		acronyms: String.Casification.CamelCaseConfig.Acronyms = .default
	) -> Self {
		return .init(
			config: .init(mode: mode, numbers: numbers, acronyms: acronyms),
			prefixPredicate: .swiftDeclarations
		)
	}
}

extension String.Casification.Modifier where Self == String.Casification.Modifiers.AnyModifier {
	@inlinable
	public static func camel<PrefixPredicate: String.Casification.PrefixPredicate>(
		_ mode: String.Casification.CamelCaseConfig.Mode = .default,
		numbers: String.Casification.CamelCaseConfig.Numbers = .default,
		acronyms: String.Casification.CamelCaseConfig.Acronyms = .default,
		prefixPredicate: PrefixPredicate,
	) -> Self {
		return .init(String.Casification.Modifiers.Camel(
			config: .init(mode: mode, numbers: numbers, acronyms: acronyms),
			prefixPredicate: prefixPredicate
		))
	}
}

// MARK: - TaskLocals

extension String.Casification.CamelCaseConfig {
	public static var `default`: Self { _default.value }

	@TaskLocal
	@_spi(Internals)
	public static var _default: LockIsolated<Self> = _storedDefault

	@_spi(Internals)
	public static let _storedDefault: LockIsolated<Self> = .init(standard)

	public static let standard: Self = .init(
		mode: .standard,
		numbers: .standard,
		acronyms: .standard
	)
}

// MARK: LocalExtensions

extension String.Casification.Token {
	@usableFromInline
	var isSingleLetter: Bool { value.count == 1 && value.first?.isLetter == true }
}

extension String.Casification.CamelCaseConfig {
	@usableFromInline
	var modeAfterNumber: Mode {
		numbers.nextTokenMode.overridenValue ?? mode
	}
}

// MARK: Overrides

let camelCasePrepared: LockIsolated<Bool> = .init(false)

/// Prepares default camel case config for the lifetime of your application.
///
/// This can be used to set up the initial default camel case config for your application in the entry point
/// of your app, or for Xcode previews. It is best to call this as early as possible in the lifetime
/// of your app.
///
/// For example, in a SwiftUI entry point, it is appropriate to call this in the initializer of
/// your `App` conformance:
///
/// ```swift
/// @main
/// struct MyApp: App {
///   init() {
///     prepareCamelCase(.init(mode: .pascal))
///   }
///
///   // ...
/// }
/// ```
///
/// Or in an app delegate entry point, you can invoke it from `didFinishLaunchingWithOptions`:
///
/// ```swift
/// @main
/// class AppDelegate: UIResponder, UIApplicationDelegate {
///   func application(
///     _ application: UIApplication,
///     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
///   ) -> Bool {
///     prepareCamelCase(.init(mode: .pascal))
///     // Override point for customization after application launch.
///     return true
///   }
///
///   // ...
/// }
/// ```
///
/// > Important: Preparation should be performed at most a single time, and should be prepared
/// > before it has been accessed. If you attempt to prepare the config multiple times a runtime warning will be emitted.
///
/// > Note: It is technically possible to use ``prepareCamelCase(_:fileID:filePath:line:column:)->()`` in tests:
/// >
/// >```swift
/// >@Suite struct FeatureTests {
/// >  init() {
/// >    prepareCamelCase(.init(mode: .pascal))
/// >  }
/// >
/// >  // ...
/// >}
/// >```
/// >
/// > However, ``prepareCamelCase(_:fileID:filePath:line:column:)->()``
/// > is not compatible with running tests repeatedly or
/// > parameterized tests, and so you may not want to use it for testing.
///
/// - Parameters:
///   - newDefaultValues: New default values for the config for the lifetime of your application.
public func prepareCamelCase(
	_ newDefaultConfig: String.Casification.CamelCaseConfig,
	fileID: StaticString = #fileID,
	filePath: StaticString = #filePath,
	line: UInt = #line,
	column: UInt = #column
) {
	prepareCamelCase(
		{ $0 = newDefaultConfig },
		fileID: fileID,
		filePath: filePath,
		line: line,
		column: column
	)
}

/// Prepares default camel case config for the lifetime of your application.
///
/// This can be used to set up the initial default camel case config for your application in the entry point
/// of your app, or for Xcode previews. It is best to call this as early as possible in the lifetime
/// of your app.
///
/// For example, in a SwiftUI entry point, it is appropriate to call this in the initializer of
/// your `App` conformance:
///
/// ```swift
/// @main
/// struct MyApp: App {
///   init() {
///     prepareCamelCase { $0.mode = .pascal }
///   }
///
///   // ...
/// }
/// ```
///
/// Or in an app delegate entry point, you can invoke it from `didFinishLaunchingWithOptions`:
///
/// ```swift
/// @main
/// class AppDelegate: UIResponder, UIApplicationDelegate {
///   func application(
///     _ application: UIApplication,
///     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
///   ) -> Bool {
///     prepareCamelCase { $0.mode = .pascal }
///     // Override point for customization after application launch.
///     return true
///   }
///
///   // ...
/// }
/// ```
///
/// > Important: Preparation should be performed at most a single time, and should be prepared
/// > before it has been accessed. If you attempt to prepare the config multiple times a runtime warning will be emitted.
///
/// > Note: It is technically possible to use ``prepareCamelCase(_:fileID:filePath:line:column:)->_`` in tests:
/// >
/// >```swift
/// >@Suite struct FeatureTests {
/// >  init() {
/// >    prepareCamelCase { $0.mode = .pascal }
/// >  }
/// >
/// >  // ...
/// >}
/// >```
/// >
/// > However, ``prepareCamelCase(_:fileID:filePath:line:column:)->_``
/// > is not compatible with running tests repeatedly or
/// > parameterized tests, and so you may not want to use it for testing.
///
/// - Parameters:
///   - updateValues: A closure for updating the current default values for the config  for the lifetime of your application.
public func prepareCamelCase<R>(
	_ updateValues: @Sendable (inout String.Casification.CamelCaseConfig) throws -> R,
	fileID: StaticString = #fileID,
	filePath: StaticString = #filePath,
	line: UInt = #line,
	column: UInt = #column
) rethrows -> R {
	camelCasePrepared.withValue { flag in
		#if DEBUG
		if flag {
			reportIssue(
				"""
				CamelCaseConfig has already been prepared.
				
				CamelCaseConfig can only be prepared a single time and shouldn't be \
				accessed beforehand. Prepare the config as early as possible in the \
				lifecycle of your application.
				""",
				fileID: fileID,
				filePath: filePath,
				line: line,
				column: column
			)
		}
		#endif
		flag = true
	}

	var config = String.Casification.CamelCaseConfig.default
	let result = try updateValues(&config)
	let updatedConfig = config
	String.Casification.CamelCaseConfig._storedDefault.withValue { $0 = updatedConfig }
	return result
}
