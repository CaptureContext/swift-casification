import Testing
@testable import Casification

@Suite
struct SeparatorBasedModifiersTests {
	@Test
	func snake() async throws {
		#expect("".case(.snake) == "")
		#expect("a".case(.snake) == "a")
		#expect("<<<$helloWorld".case(.snake) == "$hello_world")
		#expect("Hello, World!".case(.snake) == "hello_world")
		#expect("Hello, World!".case(.snake(tokenModifier: .empty, prefixPredicate: .const(false))) == "Hello_World")
	}

	@Test
	func kebab() async throws {
		#expect("".case(.kebab) == "")
		#expect("a".case(.kebab) == "a")
		#expect("<<<$helloWorld".case(.kebab) == "$hello-world")
		#expect("Hello, World!".case(.kebab) == "hello-world")
		#expect("$Hello, World!".case(.kebab(tokenModifier: .empty, prefixPredicate: .const(false))) == "Hello-World")
	}

	@Test
	func dot() async throws {
		#expect("".case(.dot) == "")
		#expect("a".case(.dot) == "a")
		#expect("<<<$helloWorld".case(.dot) == "$hello.world")
		#expect("Hello, World!".case(.dot) == "hello.world")
		#expect("$Hello, World!".case(.dot(tokenModifier: .empty, prefixPredicate: .const(false))) == "Hello.World")
	}
}
