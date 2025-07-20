import Foundation

// MARK: - Any

extension String.Casification.Modifiers {
	public struct AnyModifier: String.Casification.Modifier {
		@usableFromInline
		internal let _transform: (Substring) -> Substring

		@inlinable
		public init<Modifier: String.Casification.Modifier>(
			_ modifier: Modifier
		) {
			self.init(modifier.transform)
		}

		public init(
			_ transform: @escaping (Substring) -> Substring
		) {
			self._transform = transform
		}

		@inlinable
		public func transform(_ input: Substring) -> Substring {
			_transform(input)
		}
	}
}

// MARK: - Upper

extension String.Casification.Modifiers {
	public struct Empty: String.Casification.Modifier {
		public init() {}

		@inlinable
		public func transform(_ input: Substring) -> Substring {
			return input
		}
	}
}

extension String.Casification.Modifier where Self == String.Casification.Modifiers.Empty {
	@inlinable
	public static var empty: Self { .init() }
}

// MARK: - Upper

extension String.Casification.Modifiers {
	public struct Upper: String.Casification.Modifier {
		public init() {}

		@inlinable
		public func transform(_ input: Substring) -> Substring {
			input.uppercased()[...]
		}
	}
}

extension String.Casification.Modifier where Self == String.Casification.Modifiers.Upper {
	@inlinable
	public static var upper: Self { .init() }
}

// MARK: - Lower

extension String.Casification.Modifiers {
	public struct Lower: String.Casification.Modifier {
		public init() {}

		@inlinable
		public func transform(_ input: Substring) -> Substring {
			input.lowercased()[...]
		}
	}
}

extension String.Casification.Modifier where Self == String.Casification.Modifiers.Lower {
	@inlinable
	public static var lower: Self { .init() }
}

// MARK: - UpperFirst

extension String.Casification.Modifiers {
	public struct UpperFirst: String.Casification.Modifier {
		public init() {}

		@inlinable
		public func transform(_ input: Substring) -> Substring {
			input.prefix(1).uppercased() + input.dropFirst()
		}
	}
}

extension String.Casification.Modifier where Self == String.Casification.Modifiers.UpperFirst {
	@inlinable
	public static var upperFirst: Self { .init() }
}

// MARK: - LowerFirst

extension String.Casification.Modifiers {
	public struct LowerFirst: String.Casification.Modifier {
		public init() {}

		@inlinable
		public func transform(_ input: Substring) -> Substring {
			input.prefix(1).lowercased() + input.dropFirst()
		}
	}
}

extension String.Casification.Modifier where Self == String.Casification.Modifiers.LowerFirst {
	@inlinable
	public static var lowerFirst: Self { .init() }
}

// MARK: - Capital

extension String.Casification.Modifiers {
	public struct Capital: String.Casification.Modifier {
		public init() {}

		@inlinable
		public func transform(_ input: Substring) -> Substring {
			input.capitalized[...]
		}
	}
}

extension String.Casification.Modifier where Self == String.Casification.Modifiers.Capital {
	@inlinable
	public static var capital: Self { .init() }
}

// MARK: - Swap

extension String.Casification.Modifiers {
	public struct Swap: String.Casification.Modifier {
		public init() {}

		@inlinable
		public func transform(_ input: Substring) -> Substring {
			input
				.map {
					if $0.isUppercase { $0.lowercased() }
					else if $0.isLowercase { $0.uppercased() }
					else { .init($0) }
				}
				.joined()[...]
		}
	}
}

extension String.Casification.Modifier where Self == String.Casification.Modifiers.Swap {
	@inlinable
	public static var swap: Self { .init() }
}
