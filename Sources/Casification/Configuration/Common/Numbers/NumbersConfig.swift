extension String.Casification.Configuration.Common {
	public struct Numbers: Sendable {
		public typealias NumericBoundaryOptions = String.Casification.Configuration.NumericBoundaryOptions

		public static var current: Self { .init() }
		public static let `default`: Self = .init(
			allowedDelimeters: [],
			boundaryOptions: [.singleLetter([
				.disableSeparators,
				.disableNextTokenProcessing
			])]
		)

		public var allowedDelimeters: Set<Character>
		public var boundaryOptions: Set<BoundaryOption>

		init(
			allowedDelimeters: Set<Character> =
			String.Casification.Configuration.current.common.numbers.allowedDelimeters,

			boundaryOptions: Set<BoundaryOption> =
			String.Casification.Configuration.current.common.numbers.boundaryOptions
		) {
			self.allowedDelimeters = allowedDelimeters
			self.boundaryOptions = boundaryOptions
		}

		public struct BoundaryOption: Sendable, Hashable {
			public static func singleLetter(
				_ options: NumericBoundaryOptions
			) -> Self {
				.init(
					id: "single_letter",
					predicate: { $0.count == 1 && $0.allSatisfy(\.isLetter) },
					options: options
				)
			}

			public let id: any Hashable & Sendable
			public let predicate: @Sendable (Substring) -> Bool
			public let options: String.Casification.Configuration.NumericBoundaryOptions

			public init(
				id: any Hashable & Sendable,
				predicate: @Sendable @escaping (Substring) -> Bool,
				options: String.Casification.Configuration.NumericBoundaryOptions
			) {
				self.id = id
				self.predicate = predicate
				self.options = options
			}

			public static func == (lhs: Self, rhs: Self) -> Bool {
				lhs.id._casification_isEqual(to: rhs.id)
			}

			public func hash(into hasher: inout Hasher) {
				id.hash(into: &hasher)
			}
		}
	}
}

extension String.Casification.Configuration.Common {
	private struct NumbersKey: String.Casification.ConfigurationKey {
		static var `default`: Numbers { .default }
	}

	public var numbers: Numbers {
		get { self[NumbersKey.self] }
		set { self[NumbersKey.self] = newValue }
	}
}

extension Equatable {
	fileprivate func _casification_isEqual(to other: any Equatable) -> Bool {
		guard let other = other as? Self else { return false }
		return self == other
	}
}
