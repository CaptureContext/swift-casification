import Foundation
import IssueReporting

extension String.Casification.Modifiers {
	public struct CamelCaseConfig {
		public var mode: Mode
		public var numbers: Numbers
		public var acronyms: Acronyms

		public init(
			mode: Mode = .automatic,
			numbers: Numbers = .default,
			acronyms: Acronyms = .default
		) {
			self.mode = mode
			self.numbers = numbers
			self.acronyms = acronyms
		}

		@usableFromInline
		func withMode(_ mode: Mode) -> Self {
			.init(mode: mode, numbers: numbers, acronyms: acronyms)
		}

		public enum Mode {
			case automatic
			case camel
			case pascal
		}

		public struct Numbers {
			@inlinable
			public static var `default`: Self { .init() }

			public var nextTokenMode: NextTokenMode
			public var separator: Substring
			public var singleLetterBounaryOptions: SingleLetterBoundaryOptions

			public init(
				nextTokenMode: NextTokenMode = .inherit,
				separator: Substring = "_",
				singleLetterBounaryOptions: SingleLetterBoundaryOptions = [
					.disableSeparators,
					.disableNextTokenProcessing,
				]
			) {
				self.nextTokenMode = nextTokenMode
				self.separator = separator
				self.singleLetterBounaryOptions = singleLetterBounaryOptions
			}

			public struct SingleLetterBoundaryOptions: OptionSet {
				public var rawValue: UInt

				public init(rawValue: UInt) {
					self.rawValue = rawValue
				}

				public static var disableSeparators: Self { .init(rawValue: 1 << 1) }
				public static var disableNextTokenProcessing: Self { .init(rawValue: 1 << 1) }
			}

			public enum NextTokenMode {
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

		public struct Acronyms {
			@inlinable
			public static var `default`: Self { .init() }

			@usableFromInline
			var processingPolicy: ProcessingPolicy

			public init(
				processingPolicy: ProcessingPolicy = .default
			) {
				self.processingPolicy = processingPolicy
			}

			public enum ProcessingPolicy {
				public static var `default`: Self { .alwaysMatchCase }

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

	public struct Camel<
		PrefixPredicate: String.Casification.PrefixPredicate
	>: String.Casification.Modifier {
		public typealias SeparatorTokenProcessor = String.Casification.TokenProcessor

		@usableFromInline
		struct FirstTokenModifier: String.Casification.Modifier {
			@usableFromInline
			internal var config: CamelCaseConfig

			@usableFromInline
			init(config: CamelCaseConfig) {
				self.config = config
			}

			@usableFromInline
			func withMode(
				_ mode: CamelCaseConfig.Mode
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
			internal var acronyms: CamelCaseConfig.Acronyms

			@usableFromInline
			init(
				acronyms: CamelCaseConfig.Acronyms
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
		internal let config: CamelCaseConfig

		@usableFromInline
		internal let prefixPredicate: PrefixPredicate

		@usableFromInline
		internal let separatorTokenProcessor: SeparatorTokenProcessor

		@inlinable
		public init(
			config: CamelCaseConfig = .init(),
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
			config: CamelCaseConfig = .init(),
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
		_ mode: String.Casification.Modifiers.CamelCaseConfig.Mode = .automatic,
		numbers: String.Casification.Modifiers.CamelCaseConfig.Numbers = .default,
		acronyms: String.Casification.Modifiers.CamelCaseConfig.Acronyms = .default
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
		_ mode: String.Casification.Modifiers.CamelCaseConfig.Mode = .automatic,
		numbers: String.Casification.Modifiers.CamelCaseConfig.Numbers = .default,
		acronyms: String.Casification.Modifiers.CamelCaseConfig.Acronyms = .default,
		prefixPredicate: PrefixPredicate,
	) -> Self {
		return .init(String.Casification.Modifiers.Camel(
			config: .init(mode: mode, numbers: numbers, acronyms: acronyms),
			prefixPredicate: prefixPredicate
		))
	}
}

extension String.Casification.Token {
	@usableFromInline
	var isSingleLetter: Bool { value.count == 1 && value.first?.isLetter == true }
}

extension String.Casification.Modifiers.CamelCaseConfig {
	@usableFromInline
	var modeAfterNumber: Mode {
		numbers.nextTokenMode.overridenValue ?? mode
	}
}
