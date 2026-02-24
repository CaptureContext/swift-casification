import ConcurrencyExtras

extension String.Casification {
	public struct Configuration: Sendable {
		/// Alias for `String.Casification.Configuration`
		///
		/// Intended for internal use by nested types
		public typealias _Configuration = Self

		@_spi(Internals)
		public var _storage: _Storage

		public init() {
			self.init(storage: .init())
		}

		@_spi(Internals)
		public init(storage: _Storage) {
			self._storage = storage
		}

		@_spi(Internals)
		public func merging(_ other: Self) -> Self {
			var value = self
			value._storage.values.merge(other._storage.values, uniquingKeysWith: { $1 })
			return value
		}

		public subscript<T: String.Casification.ConfigurationKey>(
			key: T.Type
		) -> T.Value {
			get { _storage[key] }
			set { _storage[key] = newValue }
		}
	}
}
