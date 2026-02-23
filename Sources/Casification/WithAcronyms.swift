import Foundation
import IssueReporting
import ConcurrencyExtras

let acronymsPrepared: LockIsolated<Bool> = .init(false)

/// Prepares default acronyms for the lifetime of your application.
///
/// This can be used to set up the initial default acronyms for your application in the entry point
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
///     prepareAcronyms(
///       Set.standardAcronyms
///         .union(["uml", "Uml", "UML"])
///         .union(["rx", "Rx", "RX"])
///     )
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
///     prepareAcronyms(
///       Set.standardAcronyms
///         .union(["uml", "Uml", "UML"])
///         .union(["rx", "Rx", "RX"])
///     )
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
/// > Note: It is technically possible to use ``prepareAcronyms(_:fileID:filePath:line:column:)->()`` in tests:
/// >
/// >```swift
/// >@Suite struct FeatureTests {
/// >  init() {
/// >    prepareAcronyms(["test"])
/// >  }
/// >
/// >  // ...
/// >}
/// >```
/// >
/// > However, ``prepareAcronyms(_:fileID:filePath:line:column:)->()``
/// > is not compatible with running tests repeatedly or
/// > parameterized tests, and so you may not want to use it for testing.
///
/// - Parameters:
///   - newDefaultValues: New default values for acronyms for the lifetime of your application.
public func prepareAcronyms(
	_ newDefaultValues: Set<Substring>,
	fileID: StaticString = #fileID,
	filePath: StaticString = #filePath,
	line: UInt = #line,
	column: UInt = #column
) {
	prepareAcronyms(
		{ $0 = newDefaultValues },
		fileID: fileID,
		filePath: filePath,
		line: line,
		column: column
	)
}

/// Prepares default acronyms for the lifetime of your application.
///
/// This can be used to set up the initial default acronyms for your application in the entry point
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
///     prepareAcronyms { $0
///       .formUnion(["uml", "Uml", "UML"])
///       .formUnion(["rx", "Rx", "RX"])
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
///     prepareAcronyms { $0
///       .formUnion(["uml", "Uml", "UML"])
///       .formUnion(["rx", "Rx", "RX"])
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
/// > Note: It is technically possible to use ``prepareCamelCase(_:fileID:filePath:line:column:)->_``  in tests:
/// >
/// >```swift
/// >@Suite struct FeatureTests {
/// >  init() {
/// >    prepareAcronyms(["test"])
/// >  }
/// >
/// >  // ...
/// >}
/// >```
/// >
/// > However, ``prepareCamelCase(_:fileID:filePath:line:column:)->_``
/// > is not compatible with running tests repeatedly or
/// > parameterized tests, and so you may not want to use it for testing.
///
/// - Parameters:
///   - updateValues: A closure for updating the current default values for acronyms for the lifetime of your application.
public func prepareAcronyms<R>(
	_ updateValues: @Sendable (inout Set<Substring>) throws -> R,
	fileID: StaticString = #fileID,
	filePath: StaticString = #filePath,
	line: UInt = #line,
	column: UInt = #column
) rethrows -> R {
	acronymsPrepared.withValue { flag in
		#if DEBUG
		if flag {
			reportIssue(
				"""
				Acronyms have already been prepared.
				
				Global default for acronyms can only be prepared a single time and cannot be \
				accessed beforehand. Prepare acronyms as early as possible in the \
				lifecycle of your application.
				
				To temporarily override acronyms in your application, use \
				'withAcronyms' to do so in a well-defined scope.
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

	var acronyms = String.Casification._defaultAcronyms.value
	let result = try updateValues(&acronyms)
	let updatedAcronyms = acronyms
	String.Casification._defaultAcronyms.withValue { $0 = updatedAcronyms }
	return result
}

/// Updates the current acronyms for the duration of a synchronous operation.
///
/// Any mutations made to acronyms inside `updateValuesForOperation` will be visible to
/// everything executed in the operation.
///
/// ```swift
/// withAcronyms(["uml", "Uml", "UML"]) {
///   // Tokenization will use updated acronyms here
/// }
///
/// // Tokenization will use default (or prepared) acronyms here
/// ```
///
/// - Parameters:
///   - valuesForOperation: Default acronyms for the duration of the operation.
///   - operation: An operation to perform wherein acronyms have been overridden.
///
/// - Returns: The result returned from `operation`.
@discardableResult
public func withAcronyms<R>(
	_ valuesForOperation: Set<Substring>,
	operation: () throws -> R
) rethrows -> R {
	try withAcronyms({ $0 = valuesForOperation }, operation: operation)
}

/// Updates the current acronyms for the duration of a synchronous operation.
///
/// Any mutations made to acronyms inside `updateValuesForOperation` will be visible to
/// everything executed in the operation.
///
/// ```swift
/// withAcronyms { $0
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
///   - updateValuesForOperation: A closure for updating current acronyms for the
///     duration of the operation.
///   - operation: An operation to perform wherein acronyms have been overridden.
///
/// - Returns: The result returned from `operation`.
@discardableResult
public func withAcronyms<R>(
	_ updateValuesForOperation: (inout Set<Substring>) throws -> Void,
	operation: () throws -> R
) rethrows -> R {
	var acronyms = String.Casification.acronyms.value
	try updateValuesForOperation(&acronyms)
	let updatedAcronyms = acronyms
	return try String.Casification.$acronyms.withValue(.init(updatedAcronyms)) {
		try operation()
	}
}

#if compiler(>=6)
/// Updates the current acronyms for the duration of an asynchronous operation.
///
/// Any mutations made to acronyms inside `updateValuesForOperation` will be visible to
/// everything executed in the operation.
///
/// ```swift
/// withAcronyms(["uml", "Uml", "UML"]) {
///   // Tokenization will use updated acronyms here
/// }
///
/// // Tokenization will use default (or prepared) acronyms here
/// ```
///
/// - Parameters:
///   - isolation: The isolation associated with the operation.
///   - valuesForOperation: Default acronyms for the duration of the operation.
///   - operation: An operation to perform wherein acronyms have been overridden.
///
/// - Returns: The result returned from `operation`.
@discardableResult
public func withAcronyms<R>(
	isolation: isolated (any Actor)? = #isolation,
	_ valuesForOperation: Set<Substring>,
	operation: () async throws -> R
) async rethrows -> R {
	try await withAcronyms({ $0 = valuesForOperation }, operation: operation)
}

/// Updates the current acronyms for the duration of an asynchronous operation.
///
/// Any mutations made to acronyms inside `updateValuesForOperation` will be visible to
/// everything executed in the operation.
///
/// ```swift
/// withAcronyms { $0
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
///   - updateValuesForOperation: A closure for updating current acronyms for the
///     duration of the operation.
///   - operation: An operation to perform wherein acronyms have been overridden.
///
/// - Returns: The result returned from `operation`.
@discardableResult
public func withAcronyms<R>(
	isolation: isolated (any Actor)? = #isolation,
	_ updateValuesForOperation: (inout Set<Substring>) async throws -> Void,
	operation: () async throws -> R
) async rethrows -> R {
	var acronyms = String.Casification.acronyms.value
	try await updateValuesForOperation(&acronyms)
	let updatedAcronyms = acronyms
	return try await String.Casification.$acronyms.withValue(.init(updatedAcronyms)) {
		try await operation()
	}
}
#else
/// Updates the current acronyms for the duration of an asynchronous operation.
///
/// Any mutations made to acronyms inside `updateValuesForOperation` will be visible to
/// everything executed in the operation.
///
/// ```swift
/// withAcronyms(["uml", "Uml", "UML"]) {
///   // Tokenization will use updated acronyms here
/// }
///
/// // Tokenization will use default (or prepared) acronyms here
/// ```
///
/// - Parameters:
///   - valuesForOperation: Default acronyms for the duration of the operation.
///   - operation: An operation to perform wherein acronyms have been overridden.
///
/// - Returns: The result returned from `operation`.
@_unsafeInheritExecutor
@discardableResult
public func withAcronyms<R>(
	_ valuesForOperation: Set<Substring>,
	operation: () async throws -> R
) async rethrows -> R {
	try await withAcronyms({ $0 = valuesForOperation }, operation: operation)
}

/// Updates the current acronyms for the duration of an asynchronous operation.
///
/// Any mutations made to acronyms inside `updateValuesForOperation` will be visible to
/// everything executed in the operation.
///
/// ```swift
/// withAcronyms { $0
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
///   - updateValuesForOperation: A closure for updating current acronyms for the
///     duration of the operation.
///   - operation: An operation to perform wherein acronyms have been overridden.
///
/// - Returns: The result returned from `operation`.
@_unsafeInheritExecutor
@discardableResult
public func withAcronyms<R>(
	_ updateValuesForOperation: (inout Set<Substring>) async throws -> Void,
	operation: () async throws -> R
) async rethrows -> R {
	var acronyms = String.Casification.acronyms.value
	try await updateValuesForOperation(&acronyms)
	let updatedAcronyms = acronyms
	return try await String.Casification.$acronyms.withValue(.init(updatedAcronyms)) {
		try await operation()
	}
}
#endif
