extension String.Casification {
	public enum TokenProcessors {}

	public protocol TokenProcessor {
		@inlinable
		func processToken(at index: Int, in tokens: ArraySlice<Token>) -> ArraySlice<Token>
	}
}

// MARK: - Any

extension String.Casification.TokenProcessors {
	public struct AnyTokenProcessor: String.Casification.TokenProcessor {
		@usableFromInline
		internal let underlyingProcessor: String.Casification.TokenProcessor

		public init<Processor: String.Casification.TokenProcessor>(
			_ processor: Processor
		) {
			self.underlyingProcessor = processor
		}

		public init(
			_ process: @escaping (
				Int,
				ArraySlice<String.Casification.Token>
			) -> ArraySlice<String.Casification.Token>
		) {
			self.init(.inline(process))
		}

		@inlinable
		public func processToken(
			at index: Int,
			in tokens: ArraySlice<String.Casification.Token>
		) -> ArraySlice<String.Casification.Token> {
			underlyingProcessor.processToken(at: index, in: tokens)
		}
	}

	public struct Inline: String.Casification.TokenProcessor {
		@usableFromInline
		internal let process: (
			Int,
			ArraySlice<String.Casification.Token>
		) -> ArraySlice<String.Casification.Token>

		public init(
			_ process: @escaping (
				Int,
				ArraySlice<String.Casification.Token>
			) -> ArraySlice<String.Casification.Token>
		) {
			self.process = process
		}

		@inlinable
		public func processToken(
			at index: Int,
			in tokens: ArraySlice<String.Casification.Token>
		) -> ArraySlice<String.Casification.Token> {
			process(index, tokens)
		}
	}
}

extension String.Casification.TokenProcessor
where Self == String.Casification.TokenProcessors.Inline {
	public static func inline(
		_ process: @escaping (
			Int,
			ArraySlice<String.Casification.Token>
		) -> ArraySlice<String.Casification.Token>
	) -> Self {
		return .init(process)
	}
}

// MARK: - Empty

extension String.Casification.TokenProcessors {
	public struct Empty: String.Casification.TokenProcessor {
		public init() {}

		@inlinable
		public func processToken(
			at index: Int,
			in tokens: ArraySlice<String.Casification.Token>
		) -> ArraySlice<String.Casification.Token> {
			tokens[safe: index].map { [$0] } ?? []
		}
	}
}

extension String.Casification.TokenProcessor
where Self == String.Casification.TokenProcessors.Empty {
	@inlinable
	public static var empty: Self { .init() }
}
