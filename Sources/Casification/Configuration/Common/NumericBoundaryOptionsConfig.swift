extension String.Casification.Configuration {
	public struct NumericBoundaryOptions: OptionSet, Equatable, Sendable {
		public var rawValue: UInt

		public init(rawValue: UInt) {
			self.rawValue = rawValue
		}

		public static var disableSeparators: Self { .init(rawValue: 1 << 0) }
		public static var disableTokenProcessing: Self { .init(rawValue: 1 << 1) }
	}
}
