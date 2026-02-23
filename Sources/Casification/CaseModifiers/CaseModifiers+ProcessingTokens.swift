import Foundation

extension String.Casification.Modifiers {
	public struct ProcessingTokens<
		Processor: String.Casification.TokensProcessor
	>: String.Casification.Modifier {
		@usableFromInline
		internal var processor: Processor

		public init(
			using processor: Processor
		) {
			self.processor = processor
		}

		@inlinable
		public func transform(_ input: Substring) -> Substring {
			let tokens = input.tokenize(
				using: .default()
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
	public static func processingTokens<
		Processor: String.Casification.TokensProcessor
	>(
		with processor: Processor
	) -> Self {
		.init(String.Casification.Modifiers.ProcessingTokens(
			using: processor
		))
	}
}
