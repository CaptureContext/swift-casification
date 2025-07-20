import Testing
@testable import Casification

@Suite
struct BasicCaseModifiersTests {
	@Test
	func upper() async throws {
		#expect("".case(.upper) == "")
		#expect("hello, world!".case(.upper) == "HELLO, WORLD!")
		#expect("Hello, World!".case(.upper) == "HELLO, WORLD!")
		#expect("HELLO, WORLD!".case(.upper) == "HELLO, WORLD!")
	}

	@Test
	func lower() async throws {
		#expect("".case(.lower) == "")
		#expect("hello, world!".case(.lower) == "hello, world!")
		#expect("Hello, World!".case(.lower) == "hello, world!")
		#expect("HELLO, WORLD!".case(.lower) == "hello, world!")
	}

	@Test
	func upperFirst() async throws {
		#expect("".case(.upperFirst) == "")
		#expect("hello, world!".case(.upperFirst) == "Hello, world!")
		#expect("Hello, World!".case(.upperFirst) == "Hello, World!")
		#expect("HELLO, WORLD!".case(.upperFirst) == "HELLO, WORLD!")
	}

	@Test
	func lowerFirst() async throws {
		#expect("".case(.lowerFirst) == "")
		#expect("hello, world!".case(.lowerFirst) == "hello, world!")
		#expect("Hello, World!".case(.lowerFirst) == "hello, World!")
		#expect("HELLO, WORLD!".case(.lowerFirst) == "hELLO, WORLD!")
	}

	@Test
	func capital() async throws {
		#expect("".case(.capital) == "")
		#expect("hello, world!".case(.capital) == "Hello, World!")
		#expect("Hello, World!".case(.capital) == "Hello, World!")
		#expect("HELLO, WORLD!".case(.capital) == "Hello, World!")
	}

	@Test
	func swap() async throws {
		#expect("".case(.swap) == "")
		#expect("hello, world!".case(.swap) == "HELLO, WORLD!")
		#expect("Hello, World!".case(.swap) == "hELLO, wORLD!")
		#expect("HELLO, WORLD!".case(.swap) == "hello, world!")
	}

	@Test
	func combine() async throws {
		// The second modifier should be applied after the first one

		#expect("hello, world!".case(.lower.combined(with: .upperFirst)) == "Hello, world!")
		#expect("Hello, World!".case(.lower.combined(with: .upperFirst)) == "Hello, world!")
		#expect("HELLO, WORLD!".case(.lower.combined(with: .upperFirst)) == "Hello, world!")

		#expect("hello, world!".case(.upper.combined(with: .lowerFirst)) == "hELLO, WORLD!")
		#expect("Hello, World!".case(.upper.combined(with: .lowerFirst)) == "hELLO, WORLD!")
		#expect("HELLO, WORLD!".case(.upper.combined(with: .lowerFirst)) == "hELLO, WORLD!")

		#expect("hello, world!".case(.upper.combined(with: .lower)) == "hello, world!")
		#expect("Hello, World!".case(.upper.combined(with: .lower)) == "hello, world!")
		#expect("HELLO, WORLD!".case(.upper.combined(with: .lower)) == "hello, world!")

		#expect("hello, world!".case(.lower.combined(with: .upper)) == "HELLO, WORLD!")
		#expect("Hello, World!".case(.lower.combined(with: .upper)) == "HELLO, WORLD!")
		#expect("HELLO, WORLD!".case(.lower.combined(with: .upper)) == "HELLO, WORLD!")
	}
}
