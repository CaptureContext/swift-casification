import Foundation

extension String.Casification.Modifiers {
	public struct _ProcessingTokensWithProgrammingCaseModifiers<
		FirstModifier: String.Casification.Modifier,
		RestModifier: String.Casification.Modifier,
		NumericModifier: String.Casification.Modifier,
		SeparatorProcessor: String.Casification.TokenProcessor,
		PrefixPredicate: String.Casification.PrefixPredicate
	>: String.Casification.Modifier {

		@usableFromInline
		internal let firstModifier: FirstModifier

		@usableFromInline
		internal let restModifier: RestModifier

		@usableFromInline
		internal let numericModifier: NumericModifier

		@usableFromInline
		internal let prefixPredicate: PrefixPredicate

		@usableFromInline
		internal let separatorProcessor: SeparatorProcessor

		public init(
			firstModifier: FirstModifier,
			restModifier: RestModifier,
			numericModifier: NumericModifier,
			separatorProcessor: SeparatorProcessor,
			prefixPredicate: PrefixPredicate
		) {
			self.firstModifier = firstModifier
			self.restModifier = restModifier
			self.separatorProcessor = separatorProcessor
			self.numericModifier = numericModifier
			self.prefixPredicate = prefixPredicate
		}

		@inlinable
		public func transform(_ input: Substring) -> Substring {
			input.case(String.Casification.Modifiers.ProcessingTokens(
				using: String.Casification.TokensProcessors._ProgrammingCaseModifiers(
					prefixPredicate: prefixPredicate,
					separatorProcessor: separatorProcessor,
					firstModifier: firstModifier,
					restModifier: restModifier,
					numericModifier: numericModifier
				)
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
		SeparatorProcessor: String.Casification.TokenProcessor,
		PrefixPredicate: String.Casification.PrefixPredicate
	>(
		firstModifier: FirstModifier,
		restModifier: RestModifier,
		numericModifier: NumericModifier,
		separatorProcessor: SeparatorProcessor,
		prefixPredicate: PrefixPredicate
	) -> Self {
		return .init(String.Casification.Modifiers._ProcessingTokensWithProgrammingCaseModifiers(
			firstModifier: firstModifier,
			restModifier: restModifier,
			numericModifier: numericModifier,
			separatorProcessor: separatorProcessor,
			prefixPredicate: prefixPredicate
		))
	}

	@inlinable
	public static func _programmingCaseModifiers<
		TokenModifier: String.Casification.Modifier,
		SeparatorProcessor: String.Casification.TokenProcessor,
		PrefixPredicate: String.Casification.PrefixPredicate
	>(
		tokenModifier: TokenModifier,
		separatorProcessor: SeparatorProcessor,
		prefixPredicate: PrefixPredicate
	) -> Self {
		return .init(String.Casification.Modifiers._ProcessingTokensWithProgrammingCaseModifiers(
			firstModifier: tokenModifier,
			restModifier: tokenModifier,
			numericModifier: tokenModifier,
			separatorProcessor: separatorProcessor,
			prefixPredicate: prefixPredicate
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
		prefixPredicate: PrefixPredicate
	) -> Self {
		return .snake(
			tokenModifier: .lower,
			prefixPredicate: prefixPredicate
		)
	}

	@inlinable
	public static func snake<
		TokenModifier: String.Casification.Modifier,
		PrefixPredicate: String.Casification.PrefixPredicate
	>(
		tokenModifier: TokenModifier,
		prefixPredicate: PrefixPredicate
	) -> Self {
		return ._programmingCaseModifiers(
			tokenModifier: tokenModifier,
			separatorProcessor: .inline { index, tokens in
				return .init([.init("_", kind: .separator)])
			},
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
		prefixPredicate: PrefixPredicate
	) -> Self {
		return .kebab(
			tokenModifier: .lower,
			prefixPredicate: prefixPredicate
		)
	}

	@inlinable
	public static func kebab<
		TokenModifier: String.Casification.Modifier,
		PrefixPredicate: String.Casification.PrefixPredicate
	>(
		tokenModifier: TokenModifier,
		prefixPredicate: PrefixPredicate
	) -> Self {
		return ._programmingCaseModifiers(
			tokenModifier: tokenModifier,
			separatorProcessor: .inline { index, tokens in
				return .init([.init("-", kind: .separator)])
			},
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
		prefixPredicate: PrefixPredicate
	) -> Self {
		return .dot(
			tokenModifier: .lower,
			prefixPredicate: prefixPredicate
		)
	}

	@inlinable
	public static func dot<
		TokenModifier: String.Casification.Modifier,
		PrefixPredicate: String.Casification.PrefixPredicate
	>(
		tokenModifier: TokenModifier,
		prefixPredicate: PrefixPredicate
	) -> Self {
		return ._programmingCaseModifiers(
			tokenModifier: tokenModifier,
			separatorProcessor: .inline { index, tokens in
				return .init([.init(".", kind: .separator)])
			},
			prefixPredicate: prefixPredicate
		)
	}
}
