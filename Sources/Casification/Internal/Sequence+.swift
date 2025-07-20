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
