extension String.Casification {
	public enum PrefixPredicates {}
	public protocol PrefixPredicate {
		@inlinable
		func isCharacterAllowed(_ charcter: Character) -> Bool
	}
}

extension String.Casification.TokensProcessors {
	public struct _ProgrammingCaseModifiers<
		FirstModifier: String.Casification.Modifier,
		RestModifier: String.Casification.Modifier,
		NumericModifier: String.Casification.Modifier,
		PrefixPredicate: String.Casification.PrefixPredicate
	>: String.Casification.TokensProcessor {
		public typealias MapSeparator = (
			Substring,
			Substring?,
			Substring?
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

		public init(
			prefixPredicate: PrefixPredicate,
			mapSeparator: @escaping MapSeparator,
			firstModifier: FirstModifier,
			restModifier: RestModifier,
			numericModifier: NumericModifier
		) {
			self.prefixPredicate = prefixPredicate
			self.mapSeparator = mapSeparator
			self.firstModifier = firstModifier
			self.restModifier = restModifier
			self.numericModifier = numericModifier
		}

		public func processTokens(
			_ tokens: ArraySlice<String.Casification.Token>
		) -> ArraySlice<String.Casification.Token> {
			guard let firstNonSeparatorIndex = tokens.firstIndex(where: { $0.kind != .separator })
			else { return tokens }

			var output: [String.Casification.Token] = []

			do {
				let collectedPrefix = tokens[..<firstNonSeparatorIndex].reduce("") { buffer, token in
					buffer.appending(token.value.filter(prefixPredicate.isCharacterAllowed))
				}[...]

				if collectedPrefix.isNotEmpty {
					output.append(.init(collectedPrefix, kind: .separator))
				}
			}

			do {
				var restOfTokens = tokens[firstNonSeparatorIndex...]
				while restOfTokens.last?.kind == .separator { restOfTokens.removeLast() }

				// used to detect first non-numeric token
				var caughtNonNumeric = false

				for (token, index) in zip(restOfTokens, restOfTokens.indices) {
					guard token.kind != .separator else {
						output.append(.init(
							mapSeparator(
								token.value,
								restOfTokens[safe: index - 1]?.value,
								restOfTokens[safe: index + 1]?.value
							),
							kind: .separator
						))
						continue
					}

					if caughtNonNumeric {
						output.append(.init(
							restModifier.transform(token.value),
							kind: token.kind
						))
					} else {
						if token.kind == .number {
							output.append(.init(
								numericModifier.transform(token.value),
								kind: token.kind
							))
						} else {
							caughtNonNumeric = true
							output.append(reduce(token) {
								$0.value = firstModifier.transform($0.value)
							})
						}
					}
				}
			}

			return output[...]
		}
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
