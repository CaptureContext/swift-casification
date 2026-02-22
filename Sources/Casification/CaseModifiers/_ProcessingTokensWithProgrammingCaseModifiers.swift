import Foundation

extension String.Casification.Modifiers {
	public struct _ProcessingTokensWithProgrammingCaseModifiers<
		FirstModifier: String.Casification.Modifier,
		RestModifier: String.Casification.Modifier,
		NumericModifier: String.Casification.Modifier,
		PrefixPredicate: String.Casification.PrefixPredicate
	>: String.Casification.Modifier {
		public typealias MapSeparator = (
			Substring,
			String.Casification.Token?,
			ArraySlice<String.Casification.Token>
		) -> Substring

		@usableFromInline
		internal let prefixPredicate: PrefixPredicate

		@usableFromInline
		internal let mapSeparator: MapSeparator

		@usableFromInline
		internal let firstModifier: FirstModifier

		@usableFromInline
		internal let restModifier: RestModifier

		@usableFromInline
		internal let numericModifier: NumericModifier

		@usableFromInline
		internal let reservedAcronyms: Set<Substring>

		public init(
			prefixPredicate: PrefixPredicate,
			mapSeparator: @escaping MapSeparator,
			firstModifier: FirstModifier,
			restModifier: RestModifier,
			numericModifier: NumericModifier,
			reservedAcronyms: Set<Substring>
		) {
			self.prefixPredicate = prefixPredicate
			self.mapSeparator = mapSeparator
			self.firstModifier = firstModifier
			self.restModifier = restModifier
			self.numericModifier = numericModifier
			self.reservedAcronyms = reservedAcronyms
		}

		@inlinable
		public func transform(_ input: Substring) -> Substring {
			input.case(String.Casification.Modifiers.ProcessingTokens(
				using: String.Casification.TokensProcessors._ProgrammingCaseModifiers(
					prefixPredicate: prefixPredicate,
					mapSeparator: mapSeparator,
					firstModifier: firstModifier,
					restModifier: restModifier,
					numericModifier: numericModifier
				),
				acronyms: reservedAcronyms
			))
		}
	}
}

extension String.Casification.Modifier
where Self == String.Casification.Modifiers.AnyModifier {
	@inlinable
	public static func _programmingCaseModifiers<
		FirstModifier: String.Casification.Modifier,
		RestModifier: String.Casification.Modifier,
		NumericModifier: String.Casification.Modifier,
		PrefixPredicate: String.Casification.PrefixPredicate
	>(
		mapSeparator: @escaping (
			Substring,
			String.Casification.Token?,
			ArraySlice<String.Casification.Token>
		) -> Substring,
		firstModifier: FirstModifier,
		restModifier: RestModifier,
		numericModifier: NumericModifier,
		acronyms: Set<Substring> = String.Casification.standardAcronyms,
		prefixPredicate: PrefixPredicate
	) -> Self {
		return .init(String.Casification.Modifiers._ProcessingTokensWithProgrammingCaseModifiers(
			prefixPredicate: prefixPredicate,
			mapSeparator: mapSeparator,
			firstModifier: firstModifier,
			restModifier: restModifier,
			numericModifier: numericModifier,
			reservedAcronyms: acronyms
		))
	}

	@inlinable
	public static func _programmingCaseModifiers<
		TokenModifier: String.Casification.Modifier,
		PrefixPredicate: String.Casification.PrefixPredicate
	>(
		mapSeparator: @escaping (
			Substring,
			String.Casification.Token?,
			ArraySlice<String.Casification.Token>
		) -> Substring,
		tokenModifier: TokenModifier,
		acronyms: Set<Substring> = String.Casification.standardAcronyms,
		prefixPredicate: PrefixPredicate
	) -> Self {
		return .init(String.Casification.Modifiers._ProcessingTokensWithProgrammingCaseModifiers(
			prefixPredicate: prefixPredicate,
			mapSeparator: mapSeparator,
			firstModifier: tokenModifier,
			restModifier: tokenModifier,
			numericModifier: tokenModifier,
			reservedAcronyms: acronyms
		))
	}

	@inlinable
	public static var snake: Self {
		.snake(tokenModifier: .lower, prefixPredicate: .swiftDeclarations)
	}

	@inlinable
	public static func snake<
		PrefixPredicate: String.Casification.PrefixPredicate
	>(
		acronyms: Set<Substring> = String.Casification.standardAcronyms,
		prefixPredicate: PrefixPredicate
	) -> Self {
		return .snake(
			tokenModifier: .lower,
			acronyms: acronyms,
			prefixPredicate: prefixPredicate
		)
	}

	@inlinable
	public static func snake<
		TokenModifier: String.Casification.Modifier,
		PrefixPredicate: String.Casification.PrefixPredicate
	>(
		tokenModifier: TokenModifier,
		acronyms: Set<Substring> = String.Casification.standardAcronyms,
		prefixPredicate: PrefixPredicate
	) -> Self {
		return ._programmingCaseModifiers(
			mapSeparator: { _, _, _ in "_" },
			tokenModifier: tokenModifier,
			acronyms: acronyms,
			prefixPredicate: prefixPredicate
		)
	}

	@inlinable
	public static var kebab: Self {
		.kebab(tokenModifier: .lower, prefixPredicate: .swiftDeclarations)
	}

	@inlinable
	public static func kebab<
		PrefixPredicate: String.Casification.PrefixPredicate
	>(
		acronyms: Set<Substring> = String.Casification.standardAcronyms,
		prefixPredicate: PrefixPredicate
	) -> Self {
		return .kebab(
			tokenModifier: .lower,
			acronyms: acronyms,
			prefixPredicate: prefixPredicate
		)
	}

	@inlinable
	public static func kebab<
		TokenModifier: String.Casification.Modifier,
		PrefixPredicate: String.Casification.PrefixPredicate
	>(
		tokenModifier: TokenModifier,
		acronyms: Set<Substring> = String.Casification.standardAcronyms,
		prefixPredicate: PrefixPredicate
	) -> Self {
		return ._programmingCaseModifiers(
			mapSeparator: { _, _, _ in "-" },
			tokenModifier: tokenModifier,
			acronyms: acronyms,
			prefixPredicate: prefixPredicate
		)
	}

	@inlinable
	public static var dot: Self {
		.dot(tokenModifier: .lower, prefixPredicate: .swiftDeclarations)
	}

	@inlinable
	public static func dot<
		PrefixPredicate: String.Casification.PrefixPredicate
	>(
		acronyms: Set<Substring> = String.Casification.standardAcronyms,
		prefixPredicate: PrefixPredicate
	) -> Self {
		return .dot(
			tokenModifier: .lower,
			acronyms: acronyms,
			prefixPredicate: prefixPredicate
		)
	}

	@inlinable
	public static func dot<
		TokenModifier: String.Casification.Modifier,
		PrefixPredicate: String.Casification.PrefixPredicate
	>(
		tokenModifier: TokenModifier,
		acronyms: Set<Substring> = String.Casification.standardAcronyms,
		prefixPredicate: PrefixPredicate
	) -> Self {
		return ._programmingCaseModifiers(
			mapSeparator: { _, _, _ in "." },
			tokenModifier: tokenModifier,
			acronyms: acronyms,
			prefixPredicate: prefixPredicate
		)
	}
}
