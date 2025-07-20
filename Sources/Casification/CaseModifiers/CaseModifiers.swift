extension String {
	public protocol Transformer {
		@inlinable
		func transform(_ input: Swift.Substring) -> Substring
	}
}

extension String.Casification {
	public enum Modifiers {}
	public typealias Modifier = String.Transformer
}

extension String {
	@inlinable
	public func `case`<Modifier: Casification.Modifier>(_ modifier: Modifier) -> String {
		return modifier.transform(self)
	}
}

extension Substring {
	@inlinable
	public func `case`<Modifier: String.Casification.Modifier>(_ modifier: Modifier) -> Substring {
		return modifier.transform(self)
	}
}

extension String.Transformer {
	@inlinable
	public func transform(_ input: String) -> String {
		String(transform(input[...]))
	}
}

// MARK: - Combine

extension String.Casification.Modifiers {
	public struct Combine<
		First: String.Transformer,
		Second: String.Transformer
	>: String.Transformer {
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

		public func transform(_ input: Substring) -> Substring {
			second.transform(first.transform(input))
		}
	}
}

extension String.Transformer {
	public func combined<Other: String.Transformer>(
		with other: Other
	) -> some String.Transformer {
		return String.Casification.Modifiers.Combine(self, other)
	}
}
