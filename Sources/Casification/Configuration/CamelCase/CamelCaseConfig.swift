extension String.Casification.Configuration {
	public struct CamelCase: Equatable, Sendable {
		public static var current: Self { .init() }
		public static let `default`: Self = .init(
		 numbers: .default,
		 acronyms: .default
	 )

		public var numbers: Numbers
		public var acronyms: Acronyms

		public init(
			numbers: Numbers = _Configuration.current.camelCase.numbers,
			acronyms: Acronyms = _Configuration.current.camelCase.acronyms
		) {
			self.numbers = numbers
			self.acronyms = acronyms
		}

		public enum Mode: Equatable, Sendable {
			public static let `default`: Self = .automatic

			case automatic
			case camel
			case pascal
		}

		public struct Numbers: Equatable, Sendable {
			public static var current: Self { .init() }
			public static let `default`: Self = .init(
				nextTokenMode: .default,
				separator: "_"
			)

			public var nextTokenMode: NextTokenMode
			public var separator: Substring

			public init(
				nextTokenMode: NextTokenMode = .current,
				separator: Substring = CamelCase.current.numbers.separator
			) {
				self.nextTokenMode = nextTokenMode
				self.separator = separator
			}

			public enum NextTokenMode: Equatable, Sendable {
				public static var current: Self { CamelCase.current.numbers.nextTokenMode }
				public static let `default`: Self = .inherit

				case inherit
				case override(Mode = .automatic)

				public var overridenValue: Mode? {
					switch self {
					case let .override(mode): mode
					default: nil
					}
				}
			}
		}

		public struct Acronyms: Equatable, Sendable {
			public static var current: Self { .init() }
			public static let `default`: Self = .init(processingPolicy: .default)

			@usableFromInline
			var processingPolicy: ProcessingPolicy

			public init(
				processingPolicy: ProcessingPolicy = .current
			) {
				self.processingPolicy = processingPolicy
			}

			public enum ProcessingPolicy: Equatable, Sendable {
				public static var current: Self { CamelCase.current.acronyms.processingPolicy }
				public static let `default`: Self = .alwaysMatchCase

				/// Keep acronyms as parsed
				///
				/// Examples:
				/// - `"ID"` → `"ID"`
				/// - `"Id"` → `"Id"`
				/// - `"id"` → `"id"`
				///
				/// - Warning: Overrides camel case mode  when the first token is acronym
				///
				/// Examples:
				/// - `"someString"` → `"someString"`
				/// - `"uuidString"` → `"uuidString"`
				/// - `"UuidString"` → `"UuidString"`
				/// - `"UUIDString"` → `"UUIDString"`
				case preserve

				/// Always uppercase or lowercase acronyms
				///
				/// **Standard processing policy**
				///
				/// Examples:
				/// - `"ID"` → `"ID"`, or `"id"` if first token in camel case
				/// - `"Id"` → `"ID"`, or `"id"` if first token in camel case
				/// - `"id"` → `"ID"`, or `"id"` if first token in camel case
				case alwaysMatchCase

				/// Always capitalize acronyms
				///
				/// Examples:
				/// - `"ID"` → `"Id"`
				/// - `"Id"` → `"Id"`
				/// - `"id"` → `"Id"`
				///
				/// - Warning: Overrides `Mode.camel` when the first token is acronym
				///
				/// Examples:
				/// - `"someString"` → `"someString"`
				/// - `"uuidString"` → `"UuidString"`
				case alwaysCapitalize

				/// Always capitalize acronyms
				///
				/// First token behaves like `.alwaysMatchCase`, rest tokens are processed like `.alwaysCapitalize`
				///
				/// Examples:
				/// - `"ID"` → `"Id"`, or `"id"` if first token in camel case
				/// - `"Id"` → `"Id"`, or `"id"` if first token in camel case
				/// - `"id"` → `"Id"`, or `"id"` if first token in camel case
				case conditionalCapitalization
			}
		}
	}
}

// MARK: - ConfigurationKey

extension String.Casification.Configuration {
	private enum CamelCaseKey: String.Casification.ConfigurationKey {
		static var `default`: CamelCase { .default }
	}

	public var camelCase: CamelCase {
		get { self[CamelCaseKey.self] }
		set { self[CamelCaseKey.self] = newValue }
	}
}
