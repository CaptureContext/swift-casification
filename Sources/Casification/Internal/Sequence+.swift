extension Collection {
	@usableFromInline
	internal var isNotEmpty: Bool { !isEmpty }
}

extension MutableCollection {
	/// - Complexity: *O(1)*
	@usableFromInline
	internal subscript(safe index: Index?) -> Element? {
		get {
			guard let index = index else { return nil }
			return self[safe: index]
		}
		set {
			guard let index = index else { return }
			self[safe: index] = newValue
		}
	}

	/// - Complexity: *O(1)*
	@usableFromInline
	internal subscript(safe index: Index) -> Element? {
		get {
			guard indices.contains(index)
			else { return nil }
			return self[index]
		}
		set {
			guard
				indices.contains(index),
				let value = newValue
			else { return }
			return self[index] = value
		}
	}
}

extension Collection {
	/// - Complexity: *O(1)*
	@usableFromInline
	internal subscript(safe index: Index?) -> Element? {
		get {
			guard let index = index else { return nil }
			return self[safe: index]
		}
	}

	/// - Complexity: *O(1)*
	@usableFromInline
	internal subscript(safe index: Index) -> Element? {
		get {
			guard indices.contains(index)
			else { return nil }
			return self[index]
		}
	}
}

extension Collection where SubSequence: ExpressibleByArrayLiteral {
	@usableFromInline
	internal subscript(safe range: Range<Index>) -> SubSequence {
		get {
			guard
				let first = indices.first(where: { $0 >= range.lowerBound }),
				let last = indices.reversed().first(where: { $0 < range.upperBound })
			else { return [] }
			return self[first...last]
		}
	}

	@usableFromInline
	internal subscript(safe range: ClosedRange<Index>) -> SubSequence {
		get {
			guard
				let first = indices.first(where: { $0 >= range.lowerBound }),
				let last = indices.reversed().first(where: { $0 <= range.upperBound })
			else { return [] }
			return self[first...last]
		}
	}

	@usableFromInline
	internal subscript(safe range: PartialRangeFrom<Index>) -> SubSequence {
		get {
			guard
				let first = indices.first(where: { $0 >= range.lowerBound })
			else { return [] }
			return self[first...]
		}
	}

	@usableFromInline
	internal subscript(safe range: PartialRangeUpTo<Index>) -> SubSequence {
		get {
			guard
				let last = indices.reversed().first(where: { $0 < range.upperBound })
			else { return [] }
			return self[...last]
		}
	}

	@usableFromInline
	internal subscript(safe range: PartialRangeThrough<Index>) -> SubSequence {
		get {
			guard
				let last = indices.reversed().first(where: { $0 <= range.upperBound })
			else { return [] }
			return self[...last]
		}
	}
}
