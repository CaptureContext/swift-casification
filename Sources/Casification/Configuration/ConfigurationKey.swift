extension String.Casification {
	public protocol ConfigurationKey: Sendable {
		associatedtype Value: Sendable = Self
		static var `default`: Value { get }
	}
}
