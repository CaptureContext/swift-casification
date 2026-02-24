import Foundation

extension String {
	public enum Casification {}
}

extension String.Casification {
	public enum Tokenizers {}
	public protocol Tokenizer {
		@inlinable
		func tokenize(_ input: Substring) -> [Token]
	}

	public struct Token: Hashable, CustomStringConvertible {
		public var value: Substring
		public var kind: Kind

		public init(_ value: Substring = "", kind: Kind) {
			self.value = value
			self.kind = kind
		}

		@inlinable
		public func withValue(_ value: Substring) -> Token {
			return .init(value, kind: kind)
		}

		public enum Kind: Hashable, CustomStringConvertible {
			case word
			case number
			case acronym
			case separator

			public var description: String {
				switch self {
				case .word: "word"
				case .number: "number"
				case .acronym: "acronym"
				case .separator: "separator"
				}
			}
		}

		public var description: String {
			return ".\(kind)(\"\(value)\")"
		}
	}
}

extension String {
	@inlinable
	public func tokenize<Tokenizer: Casification.Tokenizer>(
		using tokenizer: Tokenizer
	) -> [Casification.Token] {
		return self[...].tokenize(using: tokenizer)
	}
}

extension Substring {
	@inlinable
	public func tokenize<Tokenizer: String.Casification.Tokenizer>(
		using tokenizer: Tokenizer
	) -> [String.Casification.Token] {
		return tokenizer.tokenize(self[...])
	}
}
