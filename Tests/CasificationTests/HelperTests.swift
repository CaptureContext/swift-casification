import Testing
@testable import Casification

@Suite
struct HelperTests {
	@Suite
	struct CollectionSubscripts {
		@Test
		func element() async throws {
			do { // first
				var s: [Int] = [0, 1, 2, 3]
				#expect(s[safe: 0] == 0)

				s[safe: 0] = 1
				#expect(s == [1, 1, 2, 3])
			}

			do { // last
				var s: [Int] = [0, 1, 2, 3]
				#expect(s[safe: 3] == 3)

				s[safe: 3] = 1
				#expect(s == [0, 1, 2, 1])
			}

			do { // out of bounds
				var s: [Int] = [0, 1, 2, 3]
				#expect(s[safe: 4] == nil)

				s[safe: 4] = 1
				#expect(s == [0, 1, 2, 3])
			}
		}

		@Test
		func range() async throws {
			do { // full
				let s: [Int] = [0, 1, 2, 3]
				#expect(s[safe: 0..<4] == [0, 1, 2, 3])
			}

			do { // partial in the start
				let s: [Int] = [0, 1, 2, 3]
				#expect(s[safe: 0..<2] == [0, 1])
			}

			do { // partial in the middle
				let s: [Int] = [0, 1, 2, 3]
				#expect(s[safe: 1..<3] == [1, 2])
			}

			do { // partial in the end
				let s: [Int] = [0, 1, 2, 3]
				#expect(s[safe: 2..<4] == [2, 3])
			}

			do { // partial overflow in the start
				let s: [Int] = [0, 1, 2, 3]
				#expect(s[safe: -1..<2] == [0, 1])
			}

			do { // partial overflow in the end
				let s: [Int] = [0, 1, 2, 3]
				#expect(s[safe: 3..<5] == [3])
			}

			do { // partial overflow in both sides
				let s: [Int] = [0, 1, 2, 3]
				#expect(s[safe: -1..<5] == [0, 1, 2, 3])
			}

			do { // full overflow in the start
				let s: [Int] = [0, 1, 2, 3]
				#expect(s[safe: -4..<0] == [])
			}

			do { // full overflow in the end
				let s: [Int] = [0, 1, 2, 3]
				#expect(s[safe: 5..<8] == [])
			}
		}

		@Test
		func closedRange() async throws {
			do { // full
				let s: [Int] = [0, 1, 2, 3]
				#expect(s[safe: 0...3] == [0, 1, 2, 3])
			}

			do { // partial in the start
				let s: [Int] = [0, 1, 2, 3]
				#expect(s[safe: 0...1] == [0, 1])
			}

			do { // partial in the middle
				let s: [Int] = [0, 1, 2, 3]
				#expect(s[safe: 1...2] == [1, 2])
			}

			do { // partial in the end
				let s: [Int] = [0, 1, 2, 3]
				#expect(s[safe: 2...3] == [2, 3])
			}

			do { // partial overflow in the start
				let s: [Int] = [0, 1, 2, 3]
				#expect(s[safe: -1...1] == [0, 1])
			}

			do { // partial overflow in the end
				let s: [Int] = [0, 1, 2, 3]
				#expect(s[safe: 3...4] == [3])
			}

			do { // partial overflow in both sides
				let s: [Int] = [0, 1, 2, 3]
				#expect(s[safe: -1...4] == [0, 1, 2, 3])
			}

			do { // full overflow in the start
				let s: [Int] = [0, 1, 2, 3]
				#expect(s[safe: -4...(-1)] == [])
			}

			do { // full overflow in the end
				let s: [Int] = [0, 1, 2, 3]
				#expect(s[safe: 5...7] == [])
			}
		}

		@Test
		func partialRangeFrom() async throws {
			do { // full
				let s: [Int] = [0, 1, 2, 3]
				#expect(s[safe: 0...] == [0, 1, 2, 3])
			}

			do { // partial in the middle
				let s: [Int] = [0, 1, 2, 3]
				#expect(s[safe: 2...] == [2, 3])
			}

			do { // partial in the end
				let s: [Int] = [0, 1, 2, 3]
				#expect(s[safe: 3...] == [3])
			}

			do { // overflow in the start
				let s: [Int] = [0, 1, 2, 3]
				#expect(s[safe: ((-1)...)] == [0, 1, 2, 3])
			}

			do { // overflow in the end
				let s: [Int] = [0, 1, 2, 3]
				#expect(s[safe: 4...] == [])
			}
		}

		@Test
		func partialRangeUpTo() async throws {
			do { // full
				let s: [Int] = [0, 1, 2, 3]
				#expect(s[safe: ..<4] == [0, 1, 2, 3])
			}

			do { // partial in the middle
				let s: [Int] = [0, 1, 2, 3]
				#expect(s[safe: ..<2] == [0, 1])
			}

			do { // partial in the start
				let s: [Int] = [0, 1, 2, 3]
				#expect(s[safe: ..<1] == [0])
			}

			do { // overflow in the start
				let s: [Int] = [0, 1, 2, 3]
				#expect(s[safe: (..<(-1))] == [])
			}

			do { // overflow in the end
				let s: [Int] = [0, 1, 2, 3]
				#expect(s[safe: ..<7] == [0, 1, 2, 3])
			}
		}

		@Test
		func partialRangeThrough() async throws {
			do { // full
				let s: [Int] = [0, 1, 2, 3]
				#expect(s[safe: ...3] == [0, 1, 2, 3])
			}

			do { // partial in the middle
				let s: [Int] = [0, 1, 2, 3]
				#expect(s[safe: ...1] == [0, 1])
			}

			do { // partial in the start
				let s: [Int] = [0, 1, 2, 3]
				#expect(s[safe: ...0] == [0])
			}

			do { // overflow in the start
				let s: [Int] = [0, 1, 2, 3]
				#expect(s[safe: (...(-1))] == [])
			}

			do { // overflow in the end
				let s: [Int] = [0, 1, 2, 3]
				#expect(s[safe: ...7] == [0, 1, 2, 3])
			}
		}
	}
}
