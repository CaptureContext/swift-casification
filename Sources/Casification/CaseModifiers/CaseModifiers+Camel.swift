import Foundation
import IssueReporting
import ConcurrencyExtras

extension String.Casification.Modifiers {
	public struct Camel<
		PrefixPredicate: String.Casification.PrefixPredicate
	>: String.Casification.Modifier {
		public typealias Config = String.Casification.Configuration.CamelCase
		public typealias SeparatorProcessor = String.Casification.TokenProcessor

		@usableFromInline
		struct FirstTokenModifier: String.Casification.Modifier {
			@usableFromInline
			@String.Casification.ConfigurationReader(\.camelCase)
			internal var config

			@usableFromInline
			internal var mode: Config.Mode

			@usableFromInline
			init(mode: Config.Mode) {
				self.mode = mode
			}

			@usableFromInline
			func withMode(
				_ mode: Config.Mode
			) -> Self {
				.init(mode: mode)
			}

			@usableFromInline
			func transform(_ input: Substring) -> Substring {
				switch mode {
				case .automatic:
					guard let first = input.first
					else { return input }

					return first.isLowercase
					? input.case(withMode(.camel))
					: input.case(withMode(.pascal))

				case .pascal:
					guard Set.currentAcronyms.contains(input)
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
					guard Set.currentAcronyms.contains(input)
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
				guard Set.currentAcronyms.contains(input)
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
		@String.Casification.ConfigurationReader(\.camelCase)
		internal var config

		@usableFromInline
		internal var mode: Config.Mode

		@usableFromInline
		internal let prefixPredicate: PrefixPredicate

		@usableFromInline
		internal let separatorProcessor: SeparatorProcessor

		@usableFromInline
		internal var modeAfterNumber: Config.Mode {
			config.numbers.nextTokenMode.overridenValue ?? self.mode
		}

		public init(
			mode: Config.Mode = .default,
			prefixPredicate: PrefixPredicate
		) {
			@String.Casification.ConfigurationReader(\.camelCase)
			var config

			self.init(
				mode: mode,
				prefixPredicate: prefixPredicate,
				separatorProcessor: ._defaultProgrammingCaseSeparator(
					defaultSeparator: .none,
					numericSeparator: config.numbers.separator
				)
			)
		}

		@usableFromInline
		internal init(
			mode: Config.Mode = .default,
			prefixPredicate: PrefixPredicate,
			separatorProcessor: SeparatorProcessor
		) {
			self.mode = mode
			self.prefixPredicate = prefixPredicate
			self.separatorProcessor = separatorProcessor
		}

		public func transform(_ input: Substring) -> Substring {
			let defaultFirstModifier = FirstTokenModifier(mode: mode)
			let defaultRestModifier = RestTokensModifier(acronyms: config.acronyms)

			return input.case(String.Casification.Modifiers.ProcessingTokens(
				using: String.Casification.TokensProcessors._ProgrammingCaseModifiers(
					tokenProcessor: .inline { index, tokens in
						guard let token = tokens[safe: index] else { return [] }

						if token.kind == .separator {
							return separatorProcessor.processToken(at: index, in: tokens)
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
								$config.numbers.boundaryOptions.contains(
									where: { $0.predicate(token.value) && $0.options.contains(.disableNextTokenProcessing) }
								)
							{ return [token] }

							switch modeAfterNumber {
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
	public static func camel(_ mode: Self.Config.Mode = .default) -> Self {
		return .init(
			mode: mode,
			prefixPredicate: .swiftDeclarations
		)
	}
}

extension String.Casification.Modifier where Self == String.Casification.Modifiers.AnyModifier {
	@inlinable
	public static func camel<PrefixPredicate: String.Casification.PrefixPredicate>(
		_ mode: String.Casification.Configuration.CamelCase.Mode = .default,
		prefixPredicate: PrefixPredicate,
	) -> Self {
		return .init(String.Casification.Modifiers.Camel(
			mode: mode,
			prefixPredicate: prefixPredicate
		))
	}
}

// MARK: LocalExtensions

extension String.Casification.Token {
	@usableFromInline
	var isSingleLetter: Bool { value.count == 1 && value.first?.isLetter == true }
}
