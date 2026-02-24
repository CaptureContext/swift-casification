import Testing
@testable import Casification

@Suite
struct SeparatorBasedModifiersTests {
	@Test
	func temp() async throws {
		withCasification({ $0.common.numbers.allowedDelimeters = [".", ","] }) {
			#expect("1.23 in a Sentence 12,000.5".case(.pascal) == "1.23_InASentence_12,000.5")
		}
	}

	@Test
	func snake() async throws {
		#expect("".case(.snake) == "")
		#expect("a".case(.snake) == "a")
		#expect("lens1x".case(.snake) == "lens_1x")
		#expect("grid1x1".case(.snake) == "grid_1x1")
		#expect("<<<$helloWorld".case(.snake) == "$hello_world")
		#expect("Hello, World!".case(.snake) == "hello_world")
		#expect("Hello, World!".case(.snake(tokenModifier: .empty, prefixPredicate: .const(false))) == "Hello_World")
	}

	@Test
	func kebab() async throws {
		#expect("".case(.kebab) == "")
		#expect("a".case(.kebab) == "a")
		#expect("lens 1x".case(.kebab) == "lens-1x")
		#expect("grid1x1".case(.kebab) == "grid-1x1")
		#expect("<<<$helloWorld".case(.kebab) == "$hello-world")
		#expect("Hello, World!".case(.kebab) == "hello-world")
		#expect("$Hello, World!".case(.kebab(tokenModifier: .empty, prefixPredicate: .const(false))) == "Hello-World")
	}

	@Test
	func dot() async throws {
		#expect("".case(.dot) == "")
		#expect("a".case(.dot) == "a")
		#expect("lens1x".case(.dot) == "lens.1x")
		#expect("grid1x1".case(.dot) == "grid.1x1")
		#expect("<<<$helloWorld".case(.dot) == "$hello.world")
		#expect("Hello, World!".case(.dot) == "hello.world")
		#expect("$Hello, World!".case(.dot(tokenModifier: .empty, prefixPredicate: .const(false))) == "Hello.World")
	}
}
