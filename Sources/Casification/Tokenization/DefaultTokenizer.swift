import Foundation

extension String.Casification.Tokenizer
where Self == String.Casification.Tokenizers.Default {
	@inlinable
	public static func `default`(
		config: Self.Config = .init()
	) -> Self {
		.init(config: config)
	}
}

extension String.Casification.Tokenizers {
	public struct Default: String.Casification.Tokenizer {
		public struct Config {
			public var acronyms: [Substring] = []

			@inlinable
			public init(
				acronyms: Set<Substring> = String.Casification.standardAcronyms
			) {
				self.init(
					sortedAcronyms: acronyms.sorted(by: { $0.count > $1.count })
				)
			}

			public init(
				sortedAcronyms: [Substring]
			) {
				self.acronyms = sortedAcronyms
			}
		}

		public var config: Config

		public init(config: Config = .init(
			acronyms: String.Casification.standardAcronyms
		)) {
			self.config = config
		}

		@inlinable
		public func tokenize(_ input: Substring) -> [String.Casification.Token] {
			var tokens: [String.Casification.Token] = []
			var currentStart = input.startIndex
			var currentIndex = input.startIndex

			func commitToken(upTo end: String.Index) {
				guard currentStart < end else { return }
				let value = input[currentStart..<end]
				commitToken(value, kind: value.allSatisfy(\.isNumber) ? .number : .word)
			}

			func commitToken(_ value: Substring, kind: String.Casification.Token.Kind) {
				if let last = tokens.last, last.kind != .separator, kind != .separator {
					commitToken("", kind: .separator)
				}

				tokens.append(.init(value, kind: kind))
			}

			func getAcronym(at index: String.Index) -> Substring? {
				config.acronyms.first { acronym in
					guard let end = input.index(index, offsetBy: acronym.count, limitedBy: input.endIndex)
					else { return false }

					if input[index..<end] != acronym { return false }

					if end == input.endIndex { return true }

					let nextChar = input[end]

					// Separator or digit — valid boundary
					if !nextChar.isLetter { return true }

					guard let lastChar = acronym.last else { return false }

					// Case transition — always a valid boundary
					if lastChar.isUppercase != nextChar.isUppercase { return true }

					// Next is Uppercase AND followed by lowercase (PascalCase boundary)
					let afterNext = input.index(after: end)
					if nextChar.isUppercase,
						 afterNext < input.endIndex,
						 input[afterNext].isLowercase {
						return true
					}

					// Recursively allow split if another acronym follows
					return getAcronym(at: end) != nil
				}.map { acronym in
					let end = input.index(index, offsetBy: acronym.count)
					return input[index..<end]
				}
			}

			while currentIndex < input.endIndex {
				do { // match acronyms
					if let acronym = getAcronym(at: currentIndex) {
						var isSuffixOfOtherToken: Bool {
							if currentStart == currentIndex { return false }

							let prevIdx = input.index(
								before: currentIndex,
								limitedBy: input.startIndex
							)

							guard let prevIdx else { return false }

							let prevChar = input[prevIdx]
							let currChar = input[currentIndex]

							return prevChar.isUppercase || currChar.isLowercase
						}

						if !isSuffixOfOtherToken {
							commitToken(upTo: currentIndex)

							let end = input.index(currentIndex, offsetBy: acronym.count)
							commitToken(input[currentIndex..<end], kind: .acronym)
							currentIndex = end
							currentStart = end
							continue
						}
					}
				}

				do { // match separators
					let char = input[currentIndex]
					if !char.isAlphanumeric {
						commitToken(upTo: currentIndex)

						let start = currentIndex
						while
							currentIndex < input.endIndex,
							!input[currentIndex].isAlphanumeric
						{
							currentIndex = input.index(after: currentIndex)
						}
						commitToken(input[start..<currentIndex], kind: .separator)
						currentStart = currentIndex
						continue
					}
				}

				do { // match case transitions (lower → upper / letter ↔ number)
					let nextIndex = input.index(after: currentIndex)
					if nextIndex < input.endIndex {
						let curr = input[currentIndex]
						let next = input[nextIndex]

						let shouldCommit = (curr.isLowercase && next.isUppercase)
						|| (curr.isLetter && next.isNumber)
						|| (curr.isNumber && next.isLetter)

						if shouldCommit {
							currentIndex = nextIndex
							commitToken(upTo: currentIndex)
							currentStart = currentIndex
							continue
						}
					}
				}

				currentIndex = input.index(after: currentIndex)
			}

			commitToken(upTo: currentIndex)
			return tokens
		}
	}
}

extension Character {
	@usableFromInline
	var isAlphanumeric: Bool { (isLetter || isNumber) }
}

extension StringProtocol {
	@usableFromInline
	var lastIndex: Index? {
		count > 0 ? index(before: endIndex) : nil
	}

	@usableFromInline
	func index(before other: Index, limitedBy limit: Index) -> Index? {
		guard other > limit else { return nil }
		return index(before: other)
	}

	@usableFromInline
	func index(after other: Index, limitedBy limit: Index) -> Index? {
		guard other < limit else { return nil }
		return index(after: other)
	}
}
