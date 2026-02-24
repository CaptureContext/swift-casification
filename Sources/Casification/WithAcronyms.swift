import Foundation
import IssueReporting
import ConcurrencyExtras

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
	try withCasification(
		{ try updateValuesForOperation(&$0.common.acronyms) },
		operation: operation
	)
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
	try await withCasification(
		{ try await updateValuesForOperation(&$0.common.acronyms) },
		operation: operation
	)
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
	try await withCasification(
		{ try await updateValuesForOperation(&$0.acronyms) },
		operation: operation
	)
}
#endif
