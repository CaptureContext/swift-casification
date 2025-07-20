@usableFromInline
internal func reduce<Value>(
	_ value: Value,
	_ transform: (inout Value) -> Void
) -> Value {
	var copy = value
	transform(&copy)
	return copy
}
