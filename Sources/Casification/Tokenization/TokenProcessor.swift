extension String.Casification {
	public enum TokensProcessors {}
	public protocol TokensProcessor {
		@inlinable
		func processTokens(_ tokens: ArraySlice<Token>) -> ArraySlice<Token>
	}
}

// MARK: - Any

extension String.Casification.TokensProcessors {
	public struct AnyTokensProcessor: String.Casification.TokensProcessor {
		@usableFromInline
		internal let process: (ArraySlice<String.Casification.Token>) -> ArraySlice<String.Casification.Token>

		public init<Processor: String.Casification.TokensProcessor>(
			_ processor: Processor
		) {
			self.init(processor.processTokens)
		}

		public init(_ process: @escaping (ArraySlice<String.Casification.Token>) -> ArraySlice<String.Casification.Token>) {
			self.process = process
		}

		@inlinable
		public func processTokens(
			_ tokens: ArraySlice<String.Casification.Token>
		) -> ArraySlice<String.Casification.Token> {
			process(tokens)
		}
	}
}

// MARK: - Empty

extension String.Casification.TokensProcessors {
	public struct Empty: String.Casification.TokensProcessor {
		public init() {}

		@inlinable
		public func processTokens(
			_ tokens: ArraySlice<String.Casification.Token>
		) -> ArraySlice<String.Casification.Token> {
			tokens
		}
	}
}

extension String.Casification.TokensProcessor
where Self == String.Casification.TokensProcessors.Empty {
	@inlinable
	public static var empty: Self { .init() }
}

// MARK: - RemoveAll

extension String.Casification.TokensProcessors {
	public struct RemoveAll: String.Casification.TokensProcessor {
		public init() {}

		@inlinable
		public func processTokens(
			_ tokens: ArraySlice<String.Casification.Token>
		) -> ArraySlice<String.Casification.Token> {
			[]
		}
	}
}

extension String.Casification.TokensProcessor
where Self == String.Casification.TokensProcessors.RemoveAll {
	@inlinable
	public static var removeAll: Self { .init() }
}

// MARK: - Filter

extension String.Casification.TokensProcessors {
	public struct Filter: String.Casification.TokensProcessor {
		@usableFromInline
		internal let predicate: (String.Casification.Token) -> Bool

		public init(_ predicate: @escaping (String.Casification.Token) -> Bool) {
			self.predicate = predicate
		}

		@inlinable
		public func processTokens(
			_ tokens: ArraySlice<String.Casification.Token>
		) -> ArraySlice<String.Casification.Token> {
			tokens.filter(predicate)[...]
		}
	}
}

extension String.Casification.TokensProcessor
where Self == String.Casification.TokensProcessors.Filter {
	@inlinable
	public static func filter(
		_ predicate: @escaping (String.Casification.Token) -> Bool
	) -> Self { .init(predicate) }
}

// MARK: - ReduceValues

extension String.Casification.TokensProcessors {
	public struct ReduceValues: String.Casification.TokensProcessor {
		@usableFromInline
		internal let initialResult: Substring

		@usableFromInline
		internal let kind: String.Casification.Token.Kind

		@usableFromInline
		internal let process: (inout Substring, String.Casification.Token) -> Void

		public init(
			into initialResult: Substring = "",
			kind: String.Casification.Token.Kind,
			_ process: @escaping (inout Substring, String.Casification.Token) -> Void
		) {
			self.initialResult = initialResult
			self.kind = kind
			self.process = process
		}

		@inlinable
		public func processTokens(
			_ tokens: ArraySlice<String.Casification.Token>
		) -> ArraySlice<String.Casification.Token> {
			return [
				.init(tokens.reduce(into: initialResult, process), kind: kind)
			]
		}
	}
}

extension String.Casification.TokensProcessor
where Self == String.Casification.TokensProcessors.ReduceValues {
	@inlinable
	public static func reduceValues(
		into initialResult: Substring = "",
		kind: String.Casification.Token.Kind,
		_ process: @escaping (inout Substring, String.Casification.Token) -> Void
	) -> Self {
		.init(
			into: initialResult,
			kind: kind,
			process
		)
	}
}

// MARK: - Combine

extension String.Casification.TokensProcessors {
	public struct Combine<
		First: String.Casification.TokensProcessor,
		Second: String.Casification.TokensProcessor
	>: String.Casification.TokensProcessor {
		@usableFromInline
		internal let first: First

		@usableFromInline
		internal let second: Second

		public init(
			_ first: First,
			_ second: Second
		) {
			self.first = first
			self.second = second
		}

		public func processTokens(
			_ tokens: ArraySlice<String.Casification.Token>
		) -> ArraySlice<String.Casification.Token> {
			second.processTokens(first.processTokens(tokens))
		}
	}
}

extension String.Casification.TokensProcessor {
	@inlinable
	public func combined<Other: String.Casification.TokensProcessor>(
		with other: Other
	) -> some String.Casification.TokensProcessor {
		String.Casification.TokensProcessors.Combine(self, other)
	}
}
