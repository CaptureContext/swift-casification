import ConcurrencyExtras

extension String.Casification.Configuration {
	@_spi(Internals)
	public struct _Storage: Sendable {
		public var values: [ObjectIdentifier: any Sendable]

		public init() {
			self.init(values: [:])
		}

		private init(values: [ObjectIdentifier: any Sendable]) {
			self.values = values
		}

		public subscript<T: String.Casification.ConfigurationKey>(
			key: T.Type
		) -> T.Value {
			get {
				let _key = ObjectIdentifier(key)
				return (values[_key] as? T.Value) ?? T.default
			}
			set {
				self.values[ObjectIdentifier(key)] = newValue
			}
		}
	}
}
