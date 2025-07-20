import Foundation

extension String.Casification.Modifiers {
	public enum CamelCasePolicy {
		 case automatic
		 case camel
		 case pascal
	 }

	public struct Camel<
		PrefixPredicate: String.Casification.PrefixPredicate
	>: String.Casification.Modifier {
		public typealias CapitalizationPolicy = CamelCasePolicy

		@usableFromInline
		struct FirstTokenModifier: String.Casification.Modifier {
			@usableFromInline
			internal var capitalizationPolicy: CapitalizationPolicy

			@usableFromInline
			internal var reservedAcronyms: Set<Substring>

			@usableFromInline
			init(
				capitalizationPolicy: CapitalizationPolicy,
				reservedAcronyms: Set<Substring>
			) {
				self.capitalizationPolicy = capitalizationPolicy
				self.reservedAcronyms = reservedAcronyms
			}

			@usableFromInline
			func withCapitalizationPolicy(
				_ capitalizationPolicy: CapitalizationPolicy
			) -> Self {
				.init(
					capitalizationPolicy: capitalizationPolicy,
					reservedAcronyms: reservedAcronyms
				)
			}

			@usableFromInline
			func transform(_ input: Substring) -> Substring {
				switch capitalizationPolicy {
				case .automatic:
					guard let first = input.first else { return input }
					return first.isLowercase
					? input.case(withCapitalizationPolicy(.camel))
					: input.case(withCapitalizationPolicy(.pascal))
				case .pascal:
					return reservedAcronyms.contains(input)
					? input.case(.upper)
					: input.case(.lower.combined(with: .upperFirst))
				case .camel:
					return input.case(.lower)
				}
			}
		}

		@usableFromInline
		struct RestTokensModifier: String.Casification.Modifier {
			@usableFromInline
			internal var reservedAcronyms: Set<Substring>

			@usableFromInline
			init(
				reservedAcronyms: Set<Substring>
			) {
				self.reservedAcronyms = reservedAcronyms
			}

			@usableFromInline
			func transform(_ input: Substring) -> Substring {
				return reservedAcronyms.contains(input)
				? input.case(.upper)
				: input.case(.lower.combined(with: .upperFirst))
			}
		}

		@usableFromInline
		internal let capitalizationPolicy: CapitalizationPolicy

		@usableFromInline
		internal let reservedAcronyms: Set<Substring>

		@usableFromInline
		internal let prefixPredicate: PrefixPredicate

		@usableFromInline
		internal let numericSeparator: Substring

		public init(
			capitalizationPolicy: CapitalizationPolicy = .automatic,
			acronyms: Set<Substring>,
			prefixPredicate: PrefixPredicate,
			numericSeparator: Substring = "_"
		) {
			self.capitalizationPolicy = capitalizationPolicy
			self.reservedAcronyms = acronyms
			self.prefixPredicate = prefixPredicate
			self.numericSeparator = numericSeparator
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
						capitalizationPolicy: capitalizationPolicy,
						reservedAcronyms: reservedAcronyms
					),
					restModifier: RestTokensModifier(
						reservedAcronyms: reservedAcronyms
					),
					numericModifier: .empty
				),
				acronyms: reservedAcronyms
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
		_ policy: String.Casification.Modifiers.CamelCasePolicy = .automatic,
		acronyms: Set<Substring> = String.Casification.standardAcronyms,
		numericSeparator: Substring = "_"
	) -> Self {
		return .init(
			capitalizationPolicy: policy,
			acronyms: acronyms,
			prefixPredicate: .swiftDeclarations,
			numericSeparator: numericSeparator
		)
	}
}

extension String.Casification.Modifier where Self == String.Casification.Modifiers.AnyModifier {
	@inlinable
	public static func camel<PrefixPredicate: String.Casification.PrefixPredicate>(
		_ policy: String.Casification.Modifiers.CamelCasePolicy = .automatic,
		acronyms: Set<Substring> = String.Casification.standardAcronyms,
		prefixPredicate: PrefixPredicate,
		numericSeparator: Substring = "_"
	) -> Self {
		return .init(String.Casification.Modifiers.Camel(
			capitalizationPolicy: policy,
			acronyms: acronyms,
			prefixPredicate: prefixPredicate,
			numericSeparator: numericSeparator
		))
	}
}
