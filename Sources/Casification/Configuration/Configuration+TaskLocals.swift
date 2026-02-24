import IssueReporting
import ConcurrencyExtras

extension String.Casification {
	@_spi(Internals)
	public static let _defaultConfiguration: LockIsolated<Configuration> = .init(.init())
}

extension String.Casification.Configuration {
	@TaskLocal
	@_spi(Internals)
	public static var _current: LockIsolated<Self> = String.Casification._defaultConfiguration
	public static var current: Self { _current.value }
}

extension String.Casification {
	private static let isConfigurationPrepared: LockIsolated<Bool> = .init(false)

	/// Prepares default configuration for casification for the lifetime of your application.
	///
	/// This can be used to set up the initial default configuration for your application in the entry point
	/// of your app, or for Xcode previews. It is best to call this as early as possible in the lifetime
	/// of your app.
	///
	/// For example, in a SwiftUI entry point, it is appropriate to call this in the initializer of
	/// your `App` conformance:
	///
	/// ```swift
	/// @main
	/// struct MyApp: App {
	///   init() {
	///     String.Casification.prepareConfiguration(.init(
	///       camelCase: .standard,
	///       singleLetterBoundaryOptions: .standard,
	///       acronyms: .defaultAcronyms
	///         .union(["uml", "Uml", "UML"])
	///         .union(["rx", "Rx", "RX"])
	///     ))
	///   }
	///
	///   // ...
	/// }
	/// ```
	///
	/// Or in an app delegate entry point, you can invoke it from `didFinishLaunchingWithOptions`:
	///
	/// ```swift
	/// @main
	/// class AppDelegate: UIResponder, UIApplicationDelegate {
	///   func application(
	///     _ application: UIApplication,
	///     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
	///   ) -> Bool {
	///     String.Casification.prepareConfiguration(.init(
	///       camelCase: .standard,
	///       singleLetterBoundaryOptions: .standard,
	///       acronyms: .defaultAcronyms
	///         .union(["uml", "Uml", "UML"])
	///         .union(["rx", "Rx", "RX"])
	///     ))
	///     // Override point for customization after application launch.
	///     return true
	///   }
	///
	///   // ...
	/// }
	/// ```
	///
	/// > Important: Preparation should be performed at most a single time, and should be prepared
	/// > before it has been accessed. If you attempt to prepare acronyms multiple times a runtime warning will be emitted.
	///
	/// > Note: It is technically possible to use
	/// > ``String.Casification.prepareConfiguration(_:fileID:filePath:line:column:)->()``
	/// > in tests:
	/// >
	/// >```swift
	/// >@Suite struct FeatureTests {
	/// >  init() {
	/// >    String.Casification.prepareConfiguration(.someCustomConfiguration)
	/// >  }
	/// >
	/// >  // ...
	/// >}
	/// >```
	/// >
	/// > However, ``String.Casification.prepareConfiguration(_:fileID:filePath:line:column:)->()``
	/// > is not compatible with running tests repeatedly or
	/// > parameterized tests, and so you may not want to use it for testing.
	///
	/// - Parameters:
	///   - newConfiguration: New configuration for the lifetime of your application.
	public static func prepareConfiguration(
		_ newConfiguration: Configuration,
		fileID: StaticString = #fileID,
		filePath: StaticString = #filePath,
		line: UInt = #line,
		column: UInt = #column
	) {
		prepareConfiguration(
			{ $0 = newConfiguration },
			fileID: fileID,
			filePath: filePath,
			line: line,
			column: column,
		)
	}

	/// Prepares default configuration for casification for the lifetime of your application.
	///
	/// This can be used to set up the initial default configuration for your application in the entry point
	/// of your app, or for Xcode previews. It is best to call this as early as possible in the lifetime
	/// of your app.
	///
	/// For example, in a SwiftUI entry point, it is appropriate to call this in the initializer of
	/// your `App` conformance:
	///
	/// ```swift
	/// @main
	/// struct MyApp: App {
	///   init() {
	///     String.Casification.prepareConfiguration {
	///       $0.acronyms = .defaultAcronyms
	///         .union(["uml", "Uml", "UML"])
	///         .union(["rx", "Rx", "RX"])
	///     }
	///   }
	///
	///   // ...
	/// }
	/// ```
	///
	/// Or in an app delegate entry point, you can invoke it from `didFinishLaunchingWithOptions`:
	///
	/// ```swift
	/// @main
	/// class AppDelegate: UIResponder, UIApplicationDelegate {
	///   func application(
	///     _ application: UIApplication,
	///     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
	///   ) -> Bool {
	///     String.Casification.prepareConfiguration {
	///       $0.acronyms = .defaultAcronyms
	///         .union(["uml", "Uml", "UML"])
	///         .union(["rx", "Rx", "RX"])
	///     }
	///     // Override point for customization after application launch.
	///     return true
	///   }
	///
	///   // ...
	/// }
	/// ```
	///
	/// > Important: Preparation should be performed at most a single time, and should be prepared
	/// > before it has been accessed. If you attempt to prepare acronyms multiple times a runtime warning will be emitted.
	///
	/// > Note: It is technically possible to use
	/// > ``String.Casification.prepareConfiguration(_:fileID:filePath:line:column:)->_``
	/// > in tests:
	/// >
	/// >```swift
	/// >@Suite struct FeatureTests {
	/// >  init() {
	/// >    String.Casification.prepareConfiguration { $0.acronyms = [] }
	/// >  }
	/// >
	/// >  // ...
	/// >}
	/// >```
	/// >
	/// > However, ``String.Casification.prepareConfiguration(_:fileID:filePath:line:column:)->_``
	/// > is not compatible with running tests repeatedly or
	/// > parameterized tests, and so you may not want to use it for testing.
	///
	/// - Parameters:
	///   - updateValues: A closure for updating the current default values for acronyms for the lifetime of your application.
	public static func prepareConfiguration<R>(
		_ updateValues: @Sendable (inout Configuration) throws -> R,
		fileID: StaticString = #fileID,
		filePath: StaticString = #filePath,
		line: UInt = #line,
		column: UInt = #column
	) rethrows -> R {
		isConfigurationPrepared.withValue { flag in
			#if DEBUG
			if flag {
				reportIssue(
					"""
					Configuration have already been prepared.
					
					Global default for the configuration can only be prepared a single time and \
					shouldn't be accessed beforehand. Prepare acronyms as early as possible in the \
					lifecycle of your application.
					
					To temporarily override configuration in your application, use \
					'withCasification' to do so in a well-defined scope.
					""",
					fileID: fileID,
					filePath: filePath,
					line: line,
					column: column
				)
			}
			#endif
			flag = true
		}

		var configuration = String.Casification._defaultConfiguration.value
		let result = try updateValues(&configuration)
		let updatedConfiguration = configuration
		String.Casification._defaultConfiguration.setValue(updatedConfiguration)
		return result
	}
}

/// Updates the current configuration for the duration of a synchronous operation.
///
/// New configuration will be visible to
/// everything executed in the operation.
///
/// ```swift
/// withCasification(.customConfiguration) {
///   // Casification helpers will use your configuration here
/// }
///
/// // Casification helpers will use default (or prepared) configuration here
/// ```
///
/// - Parameters:
///   - configurationForOperation: Default configuration for the duration of the operation.
///   - operation: An operation to perform wherein configuration has been overridden.
///
/// - Returns: The result returned from `operation`.
@discardableResult
public func withCasification<R>(
	_ configurationForOperation: String.Casification.Configuration,
	operation: () throws -> R
) rethrows -> R {
	try withCasification({ $0 = configurationForOperation }, operation: operation)
}

/// Updates the current configuration for the duration of a synchronous operation.
///
/// Any mutations made to configuration inside `updateConfigurationForOperation` will be visible to
/// everything executed in the operation.
///
/// ```swift
/// withCasification { $0
///   .acronyms
///   .formUnion(["uml", "Uml", "UML"])
///   .formUnion(["rx", "Rx", "RX"])
/// } operation: {
///   // Tokenization will use updated acronyms here
/// }
///
/// // Tokenization will use default (or prepared) acronyms here
/// ```
///
/// - Parameters:
///   - updateConfigurationForOperation: A closure for updating current configuration for the
///     duration of the operation.
///   - operation: An operation to perform wherein configuration has been overridden.
///
/// - Returns: The result returned from `operation`.
@discardableResult
public func withCasification<R>(
	_ updateConfigurationForOperation: (inout String.Casification.Configuration) throws -> Void,
	operation: () throws -> R
) rethrows -> R {
	var configuration = String.Casification.Configuration.current
	try updateConfigurationForOperation(&configuration)
	let updatedConfiguration = configuration
	return try String.Casification.Configuration.$_current.withValue(.init(updatedConfiguration)) {
		try operation()
	}
}

#if compiler(>=6)
/// Updates the current configuration for the duration of an asynchronous operation.
///
/// New configuration will be visible to
/// everything executed in the operation.
///
/// ```swift
/// withCasification(.customConfiguration) {
///   // Casification helpers will use your configuration here
/// }
///
/// // Casification helpers will use default (or prepared) configuration here
/// ```
///
/// - Parameters:
///   - isolation: The isolation associated with the operation.
///   - configurationForOperation: Default configuration for the duration of the operation.
///   - operation: An operation to perform wherein configuration has been overridden.
///
/// - Returns: The result returned from `operation`.
@discardableResult
public func withCasification<R>(
	isolation: isolated (any Actor)? = #isolation,
	_ configurationForOperation: String.Casification.Configuration,
	operation: () async throws -> R
) async rethrows -> R {
	try await withCasification({ $0 = configurationForOperation }, operation: operation)
}

/// Updates the current acronyms for the duration of an asynchronous operation.
///
/// Any mutations made to configuration inside `updateConfigurationForOperation` will be visible to
/// everything executed in the operation.
///
/// ```swift
/// withCasification { $0
///   .acronyms
///   .formUnion(["uml", "Uml", "UML"])
///   .formUnion(["rx", "Rx", "RX"])
/// } operation: {
///   // Tokenization will use updated acronyms here
/// }
///
/// // Tokenization will use default (or prepared) acronyms here
/// ```
///
/// - Parameters:
///   - isolation: The isolation associated with the operation.
///   - updateConfigurationForOperation: A closure for updating current configuration for the
///     duration of the operation.
///   - operation: An operation to perform wherein configuration has been overridden.
///
/// - Returns: The result returned from `operation`.
@discardableResult
public func withCasification<R>(
	isolation: isolated (any Actor)? = #isolation,
	_ updateConfigurationForOperation: (inout String.Casification.Configuration) async throws -> Void,
	operation: () async throws -> R
) async rethrows -> R {
	var configuration = String.Casification.Configuration.current
	try await updateConfigurationForOperation(&configuration)
	let updatedConfiguration = configuration
	return try await String.Casification.Configuration.$_current.withValue(.init(updatedConfiguration)) {
		try await operation()
	}
}
#else
/// Updates the current configuration for the duration of an asynchronous operation.
///
/// New configuration will be visible to
/// everything executed in the operation.
///
/// ```swift
/// withCasification(.customConfiguration) {
///   // Casification helpers will use your configuration here
/// }
///
/// // Casification helpers will use default (or prepared) configuration here
/// ```
///
/// - Parameters:
///   - configurationForOperation: Default configuration for the duration of the operation.
///   - operation: An operation to perform wherein configuration has been overridden.
///
/// - Returns: The result returned from `operation`.
@_unsafeInheritExecutor
@discardableResult
public func withCasification<R>(
	_ configurationForOperation: Set<Substring>,
	operation: () async throws -> R
) async rethrows -> R {
	try await withCasification({ $0 = configurationForOperation }, operation: operation)
}

/// Updates the current acronyms for the duration of an asynchronous operation.
///
/// Any mutations made to configuration inside `updateConfigurationForOperation` will be visible to
/// everything executed in the operation.
///
/// ```swift
/// withCasification { $0
///   .acronyms
///   .formUnion(["uml", "Uml", "UML"])
///   .formUnion(["rx", "Rx", "RX"])
/// } operation: {
///   // Tokenization will use updated acronyms here
/// }
///
/// // Tokenization will use default (or prepared) acronyms here
/// ```
///
/// - Parameters:
///   - updateConfigurationForOperation: A closure for updating current configuration for the
///     duration of the operation.
///   - operation: An operation to perform wherein configuration has been overridden.
///
/// - Returns: The result returned from `operation`.
@_unsafeInheritExecutor
@discardableResult
public func withCasification<R>(
	_ updateConfigurationForOperation: (inout Set<Substring>) async throws -> Void,
	operation: () async throws -> R
) async rethrows -> R {
	var configuration = String.Casification.Configuration.current
	try await updateConfigurationForOperation(&configuration)
	let updatedConfiguration = configuration
	return try await String.Casification.Configuration.$_current.withValue(.init(updatedConfiguration)) {
		try await operation()
	}
}
#endif
