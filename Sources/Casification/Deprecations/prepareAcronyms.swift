@available(*, deprecated, renamed: "String.Casification.prepareConfiguration")
public func prepareAcronyms(
	_ newValues: Set<Substring>,
	fileID: StaticString = #fileID,
	filePath: StaticString = #filePath,
	line: UInt = #line,
	column: UInt = #column
) {
	String.Casification.prepareConfiguration(
		{ $0.common.acronyms = newValues },
		fileID: fileID,
		filePath: filePath,
		line: line,
		column: column
	)
}

@available(*, deprecated, renamed: "String.Casification.prepareConfiguration")
public func prepareAcronyms<R>(
	_ updateValues: @Sendable (inout Set<Substring>) throws -> R,
	fileID: StaticString = #fileID,
	filePath: StaticString = #filePath,
	line: UInt = #line,
	column: UInt = #column
) rethrows -> R {
	var acronyms: Set<Substring> = .defaultAcronyms
	let result = try updateValues(&acronyms)
	let updatedAcronyms = acronyms
	String.Casification.prepareConfiguration(
		{ $0.common.acronyms = updatedAcronyms },
		fileID: fileID,
		filePath: filePath,
		line: line,
		column: column
	)
	return result
}
