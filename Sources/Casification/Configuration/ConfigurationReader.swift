extension String.Casification {
	@propertyWrapper
	public struct ConfigurationReader<T>: Sendable {
		@usableFromInline
		internal var cachedConfiguration: Configuration = .current

		let keyPath: SendableKeyPath<Configuration, T>

		public init(_ keyPath: KeyPath<Configuration, T> & Sendable) {
			self.keyPath = keyPath
		}

		public var wrappedValue: T {
			let configuration = cachedConfiguration.merging(.current)
			return Configuration.$_current.withValue(.init(configuration)) {
				Configuration.current[keyPath: keyPath]
			}
		}

		public var projectedValue: Configuration.Common {
			let configuration = cachedConfiguration.merging(.current)
			return Configuration.$_current.withValue(.init(configuration)) {
				Configuration.current.common
			}
		}
	}
}
