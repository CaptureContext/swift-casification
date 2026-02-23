import Foundation

extension String.Casification {
	public enum PrefixPredicates {}
	public protocol PrefixPredicate {
		@inlinable
		func isCharacterAllowed(_ charcter: Character) -> Bool
	}
}


extension String.Casification.TokensProcessors {
	public struct _ProgrammingCaseModifiers<
		TokenProcessor: String.Casification.TokenProcessor,
		PrefixPredicate: String.Casification.PrefixPredicate
	>: String.Casification.TokensProcessor {
		@usableFromInline
		internal let tokenProcessor: TokenProcessor

		@usableFromInline
		internal let prefixPredicate: PrefixPredicate

		public init(
			tokenProcessor: TokenProcessor,
			prefixPredicate: PrefixPredicate
		) {
			self.tokenProcessor = tokenProcessor
			self.prefixPredicate = prefixPredicate
		}

		@inlinable
		public func processTokens(
			_ tokens: ArraySlice<String.Casification.Token>
		) -> ArraySlice<String.Casification.Token> {
			guard
				let firstNonSeparatorIndex = tokens.firstIndex(where: { $0.kind != .separator }),
				let lastNonSeparatorIndex = tokens.lastIndex(where: { $0.kind != .separator })
			else { return tokens }

			var output: [String.Casification.Token] = []

			do { // collect leading separators
				let collectedPrefix = tokens[..<firstNonSeparatorIndex].reduce("") { buffer, token in
					buffer.appending(token.value.filter(prefixPredicate.isCharacterAllowed))
				}[...]

				if collectedPrefix.isNotEmpty {
					output.append(.init(collectedPrefix, kind: .separator))
				}
			}


			do { // process tokens
				let tokens = tokens[firstNonSeparatorIndex...lastNonSeparatorIndex]

				for index in tokens.indices {
					output.append(contentsOf: tokenProcessor.processToken(at: index, in: tokens))
				}
			}

			return output[...]
		}
	}
}

extension String.Casification.TokensProcessors._ProgrammingCaseModifiers
where TokenProcessor == String.Casification.TokenProcessors.AnyTokenProcessor {
	public init<
		FirstModifier: String.Casification.Modifier,
		RestModifier: String.Casification.Modifier,
		NumericModifier: String.Casification.Modifier,
		SeparatorProcessor: String.Casification.TokenProcessor
	>(
		prefixPredicate: PrefixPredicate,
		separatorProcessor: SeparatorProcessor,
		firstModifier: FirstModifier,
		restModifier: RestModifier,
		numericModifier: NumericModifier
	) {
		self.init(
			tokenProcessor: .init { index, tokens in
				guard let token = tokens[safe: index] else { return [] }

				if token.kind == .separator {
					return separatorProcessor.processToken(at: index, in: tokens)
				}

				if token.kind == .number {
					return [
						.init(
							numericModifier.transform(token.value),
							kind: token.kind
						),
					]
				}

				let alreadyCaughtNonNumeric: Bool = tokens[safe: ..<index]
					.contains { [.word, .acronym].contains($0.kind) }

				if alreadyCaughtNonNumeric {
					return [
						.init(
							restModifier.transform(token.value),
							kind: token.kind
						),
					]
				} else {
					return [
						.init(
							firstModifier.transform(token.value),
							kind: token.kind
						),
					]
				}
			},
			prefixPredicate: prefixPredicate
		)
	}
}


// - MARK: PrefixPredicates

extension String.Casification.PrefixPredicates {
	public struct Const: String.Casification.PrefixPredicate {
		@usableFromInline
		internal let value: Bool

		public init(_ value: Bool) {
			self.value = value
		}

		@inlinable
		public func isCharacterAllowed(
			_ character: Character
		) -> Bool {
			return value
		}
	}
}

extension String.Casification.PrefixPredicate
where Self == String.Casification.PrefixPredicates.Const {
	@inlinable
	public static func const(_ value: Bool) -> Self {
		return .init(value)
	}
}

extension String.Casification.PrefixPredicates {
	public struct AllowedCharacters: String.Casification.PrefixPredicate {
		@usableFromInline
		internal let allowedCharacters: Set<Character>

		public init(_ allowedCharacters: Set<Character>) {
			self.allowedCharacters = allowedCharacters
		}

		@inlinable
		public func isCharacterAllowed(
			_ character: Character
		) -> Bool {
			return allowedCharacters.contains(character)
		}
	}
}

extension String.Casification.PrefixPredicate
where Self == String.Casification.PrefixPredicates.AllowedCharacters {
	@inlinable
	public static func allowedCharacters<S: Sequence>(_ characters: S) -> Self
	where S.Element == Character {
		return .init(Set(characters))
	}

	@inlinable
	public static var swiftDeclarations: Self {
		.allowedCharacters("$_")
	}
}

extension String.Casification.PrefixPredicates {
	public struct AnyPrefixPredicate: String.Casification.PrefixPredicate {
		@usableFromInline
		internal let predicate: (Character) -> Bool

		@inlinable
		public init<Predicate: String.Casification.PrefixPredicate>(
			_ predicate: Predicate
		) {
			self.init(predicate.isCharacterAllowed)
		}

		public init(_ predicate: @escaping (Character) -> Bool) {
			self.predicate = predicate
		}

		@inlinable
		public func isCharacterAllowed(
			_ character: Character
		) -> Bool {
			return predicate(character)
		}
	}
}

extension String.Casification.PrefixPredicate
where Self == String.Casification.PrefixPredicates.AnyPrefixPredicate {
	@inlinable
	public static func custom(_ predicate: @escaping (Character) -> Bool) -> Self {
		return .init(predicate)
	}
}
