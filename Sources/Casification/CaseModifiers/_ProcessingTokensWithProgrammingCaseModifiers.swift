import Foundation
import IssueReporting

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
			separatorProcessor: ._defaultProgrammingCaseSeparator("_"),
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
			separatorProcessor: ._defaultProgrammingCaseSeparator("-"),
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
			separatorProcessor: ._defaultProgrammingCaseSeparator("."),
			prefixPredicate: prefixPredicate
		)
	}
}

extension String.Casification.TokenProcessor
where Self == String.Casification.TokenProcessors.Inline {
	@usableFromInline
	static func _defaultProgrammingCaseSeparator(
		_ defaultSeparator: Substring
	) -> Self {
		_defaultProgrammingCaseSeparator(
			defaultSeparator: defaultSeparator,
			numericSeparator: defaultSeparator
		)
	}

	@_spi(Internals)
	public static func _defaultProgrammingCaseSeparator(
		defaultSeparator: Substring?,
		numericSeparator: Substring?
	) -> Self {
		@String.Casification.ConfigurationReader(\.common)
		var config

		return .inline { index, tokens in
			guard let token = tokens[safe: index] else { return [] }

			let numericSeparatorToken: String.Casification.Token? = numericSeparator.map {
				.init($0, kind: .separator)
			}

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

			print(prevToken?.description ?? "nil", token.description, nextToken?.description ?? "nil")

			let leadingNumericBoundary = prevToken?.value.last?.isNumber == true
			if leadingNumericBoundary {
				guard let nextToken else { return [] }

				if
					config.numbers.boundaryOptions.contains(
						where: { $0.predicate(nextToken.value) && $0.options.contains(.disableSeparators) }
					)
				{ return [] }

				if let numericSeparatorToken {
					return [numericSeparatorToken]
				}
			}

			let trailingNumericBoundary = nextToken?.value.first?.isNumber == true
			if trailingNumericBoundary {
				guard let prevToken else { return [] }

				if
					config.numbers.boundaryOptions.contains(
						where: { $0.predicate(prevToken.value) && $0.options.contains(.disableSeparators) }
					)
				{ return [] }

				if let numericSeparatorToken {
					return [numericSeparatorToken]
				}
			}

			if let defaultSeparator {
				return [.init(defaultSeparator, kind: .separator)]
			} else {
				return []
			}
		}
	}
}
