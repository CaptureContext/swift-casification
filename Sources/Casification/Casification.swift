import Foundation
import ConcurrencyExtras

extension Set where Element == Substring {
	public static var standardAcronyms: Self { String.Casification.acronyms.value }
}

extension String {
	public enum Casification {
		@TaskLocal
		@_spi(Internals)
		public static var acronyms: LockIsolated<Set<Substring>> = _defaultAcronyms

		@_spi(Internals)
		public static let _defaultAcronyms: LockIsolated<Set<Substring>> = .init(_standardAcronyms)

		@_spi(Internals)
		public static let _standardAcronyms: Set<Substring> = [
			"uri", "Uri", "URI",
			"url", "Url", "URL",
			"spm", "Spm", "SPM",
			"npm", "Npm", "NPM",
			"id", "Id", "ID", // todo: add more common acronyms like SQL
			"uuid", "Uuid", "UUID",
			"ulid", "Ulid", "ULID",
			"usid", "Usid", "USID",
			"idfa", "Idfa", "IDFA",
			"void", "Void", "VOID",
			"json", "Json", "JSON",
			"xml", "Xml", "XML",
			"yaml", "Yaml", "YAML", // todo: add more extensions
			"sf", "SF",
			"ns", "NS",
			"ui", "UI",
			"ux", "UX",
			"sk", "SK" // todo: add more system prefixes
		]
	}
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
