extension String.Casification.Configuration.Common {
	public struct Numbers: Sendable {
		public typealias NumericBoundaryOptions = String.Casification.Configuration.NumericBoundaryOptions

		public static var current: Self { .init() }
		public static let `default`: Self = .init(
			allowedDelimeters: [],
			boundaryOptions: [
				.endingNumber([
					.disableSeparators,
				]),
				.singleLetter([
					.disableSeparators,
					.disableTokenProcessing,
				])
			]
		)

		public var allowedDelimeters: Set<Character>
		public var boundaryOptions: Set<BoundaryOption>

		public init(
			allowedDelimeters: Set<Character> =
			String.Casification.Configuration.current.common.numbers.allowedDelimeters,

			boundaryOptions: Set<BoundaryOption> =
			String.Casification.Configuration.current.common.numbers.boundaryOptions
		) {
			self.allowedDelimeters = allowedDelimeters
			self.boundaryOptions = boundaryOptions
		}

		public struct BoundaryOption: Sendable, Hashable {
			public static func endingNumber(
				_ options: NumericBoundaryOptions
			) -> Self {
				.init(
					id: "ending_number",
					predicate: { index, tokens in
						guard
							index == tokens.indices.last,
							let token = tokens[safe: index]
						else { return false }

						let afterNonNumeric: Bool = tokens[safe: ..<index]
							.last(where: { $0.kind != .separator })?.value.last?.isNumber != true

						return afterNonNumeric && token.value.first?.isNumber == true
					},
					options: options
				)
			}

			public static func singleLetter(
				_ options: NumericBoundaryOptions
			) -> Self {
				.init(
					id: "single_letter",
					predicate: { index, tokens in
						guard let token = tokens[safe: index] else { return false }

						let afterNumeric: Bool = tokens[safe: ..<index]
							.last(where: { $0.kind != .separator })?.value.last?.isNumber == true

						let beforeNumeric: Bool = tokens[safe: (index+1)...]
							.first(where: { $0.kind != .separator })?.value.first?.isNumber == true

						return (afterNumeric || beforeNumeric) && token.isSingleLetter
					},
					options: options
				)
			}

			public let id: any Hashable & Sendable
			public let predicate: @Sendable (Int, ArraySlice<String.Casification.Token>) -> Bool
			public let options: String.Casification.Configuration.NumericBoundaryOptions

			public init(
				id: any Hashable & Sendable,
				predicate: @escaping @Sendable (Int, ArraySlice<String.Casification.Token>) -> Bool,
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
