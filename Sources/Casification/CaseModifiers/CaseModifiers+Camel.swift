import Foundation

extension String.Casification.Modifiers {
	@available(*, deprecated, renamed: "CamelCaseConfig.Mode")
	public typealias CamelCasePolicy = CamelCaseConfig.Mode

	public struct CamelCaseConfig {
		public var mode: Mode
		public var acronyms: Acronyms

		public init(
			mode: Mode = .automatic,
			acronyms: Acronyms = .default
		) {
			self.mode = mode
			self.acronyms = acronyms
		}

		@usableFromInline
		func withMode(_ mode: Mode) -> Self {
			.init(mode: mode, acronyms: acronyms)
		}

		public enum Mode {
			case automatic
			case camel
			case pascal
		}

		public struct Acronyms {
			@inlinable
			public static var `default`: Self { .init() }

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

			@usableFromInline
			var reservedValues: Set<Substring> = .standardAcronyms

			@usableFromInline
			var processingPolicy: ProcessingPolicy

			public init(
				reservedValues: Set<Substring> = .standardAcronyms,
				processingPolicy: ProcessingPolicy = .default
			) {
				self.reservedValues = reservedValues
				self.processingPolicy = processingPolicy
			}
		}
	}

	public struct Camel<
		PrefixPredicate: String.Casification.PrefixPredicate
	>: String.Casification.Modifier {
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
					guard config.acronyms.reservedValues.contains(input)
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
					guard config.acronyms.reservedValues.contains(input)
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
				guard acronyms.reservedValues.contains(input)
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
		internal let numericSeparator: Substring

		@available(*, deprecated, renamed: "init(config:prefixPredicate:numericPrefix:)")
		public init(
			capitalizationPolicy: CamelCaseConfig.Mode = .automatic,
			acronyms: Set<Substring>,
			prefixPredicate: PrefixPredicate,
			numericSeparator: Substring
		) {
			self.init(
				config: .init(
					mode: capitalizationPolicy,
					acronyms: .init(
						reservedValues: acronyms,
						processingPolicy: .default
					)
				),
				prefixPredicate: prefixPredicate,
				numericPrefix: numericSeparator
			)
		}

		public init(
			config: CamelCaseConfig = .init(),
			prefixPredicate: PrefixPredicate,
			numericPrefix: Substring = "_"
		) {
			self.config = config
			self.prefixPredicate = prefixPredicate
			self.numericSeparator = numericPrefix
		}

		@inlinable
		public func transform(_ input: Substring) -> Substring {
			let tokenazableInput = input.first?.isNumber == true
			? numericSeparator + input
			: input

			return tokenazableInput.case(String.Casification.Modifiers.ProcessingTokens(
				using: String.Casification.TokensProcessors._ProgrammingCaseModifiers(
					prefixPredicate: prefixPredicate,
					mapSeparator: { separator, prev, next in
						let isNumericBoundary = prev?.last?.isNumber == true
						|| next?.first?.isNumber == true

						return isNumericBoundary ? numericSeparator : ""
					},
					firstModifier: FirstTokenModifier(
						config: config
					),
					restModifier: RestTokensModifier(
						acronyms: config.acronyms
					),
					numericModifier: .empty
				),
				acronyms: config.acronyms.reservedValues
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

	@available(*, deprecated, renamed: "camel(_:acronyms:numericPrefix:)")
	@inlinable
	public static func camel(
		_ mode: String.Casification.Modifiers.CamelCaseConfig.Mode = .automatic,
		acronyms: Set<Substring> = String.Casification.standardAcronyms,
		numericSeparator: Substring
	) -> Self {
		return .camel(
			mode,
			acronyms: .init(reservedValues: acronyms),
			numericPrefix: numericSeparator
		)
	}

	@inlinable
	public static func camel(
		_ mode: String.Casification.Modifiers.CamelCaseConfig.Mode = .automatic,
		acronyms: String.Casification.Modifiers.CamelCaseConfig.Acronyms = .default,
		numericPrefix: Substring = "_"
	) -> Self {
		return .init(
			config: .init(mode: mode, acronyms: acronyms),
			prefixPredicate: .swiftDeclarations,
			numericPrefix: numericPrefix
		)
	}
}

extension String.Casification.Modifier where Self == String.Casification.Modifiers.AnyModifier {
	@available(*, deprecated, renamed: "camel(_:acronyms:prefixPredicate:numericPrefix:)")
	@inlinable
	public static func camel<PrefixPredicate: String.Casification.PrefixPredicate>(
		_ mode: String.Casification.Modifiers.CamelCaseConfig.Mode = .automatic,
		acronyms: Set<Substring> = String.Casification.standardAcronyms,
		prefixPredicate: PrefixPredicate,
		numericSeparator: Substring
	) -> Self {
		return .camel(
			mode,
			acronyms: .init(reservedValues: acronyms),
			prefixPredicate: prefixPredicate,
			numericPrefix: numericSeparator
		)
	}

	@inlinable
	public static func camel<PrefixPredicate: String.Casification.PrefixPredicate>(
		_ mode: String.Casification.Modifiers.CamelCaseConfig.Mode = .automatic,
		acronyms: String.Casification.Modifiers.CamelCaseConfig.Acronyms = .default,
		prefixPredicate: PrefixPredicate,
		numericPrefix: Substring = "_"
	) -> Self {
		return .init(String.Casification.Modifiers.Camel(
			config: .init(mode: mode, acronyms: acronyms),
			prefixPredicate: prefixPredicate,
			numericPrefix: numericPrefix
		))
	}
}
