import Foundation

extension String.Casification.Modifiers {
	public struct ProcessingTokens<
		Processor: String.Casification.TokensProcessor
	>: String.Casification.Modifier {
		@usableFromInline
		internal var processor: Processor

		@usableFromInline
		internal var reservedAcronyms: Set<Substring>

		public init(
			using processor: Processor,
			acronyms: Set<Substring> = String.Casification.standardAcronyms
		) {
			self.processor = processor
			self.reservedAcronyms = Set(acronyms.map { $0[...] })
		}

		@inlinable
		public func transform(_ input: Substring) -> Substring {
			let tokens = input.tokenize(
				using: .default(config: .init(acronyms: reservedAcronyms))
			)

			return processor.processTokens(tokens[...]).reduce("") { buffer, token in
				buffer.appending(token.value)
			}[...]
		}
	}
}

extension String.Casification.Modifier
where Self == String.Casification.Modifiers.AnyModifier {
	@inlinable
	public static func processingTokens<Processor: String.Casification.TokensProcessor>(
		with processor: Processor,
		acronyms: Set<Substring> = String.Casification.standardAcronyms
	) -> Self {
		.init(String.Casification.Modifiers.ProcessingTokens(
			using: processor,
			acronyms: acronyms
		))
	}
}
