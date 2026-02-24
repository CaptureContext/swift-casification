import ConcurrencyExtras

extension String.Casification.Configuration {
	public struct Common: Sendable {
		/// Alias for `String.Casification.Configuration.Common`
		///
		/// Intended for internal use by nested types
		public typealias _CommonConfiguration = Self

		@_spi(Internals)
		public var _storage: _Storage = .init()

		public init() {}

		public subscript<T: String.Casification.ConfigurationKey>(
			key: T.Type
		) -> T.Value {
			get { _storage[key] }
			set { _storage[key] = newValue }
		}
	}
}

extension String.Casification.Configuration {
	private enum CommonKey: String.Casification.ConfigurationKey {
		static var `default`: Common { .init() }
	}

	public var common: Common {
		get { self[CommonKey.self] }
		set { self[CommonKey.self] = newValue }
	}
}
