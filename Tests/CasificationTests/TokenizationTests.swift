import Testing
@testable import Casification

@Suite
struct TokenizationTests {
	@Test
	func basic() async throws {
		#expect("lowercase"._tokenize() == ["lowercase".asToken(.word)])
		#expect("Capitalize"._tokenize() == ["Capitalize".asToken(.word)])
		#expect("UPPERCASE"._tokenize() == ["UPPERCASE".asToken(.word)])

		#expect("CamelCaseString1"._tokenize() == [
			"Camel".asToken(.word),
			"".asToken(.separator),
			"Case".asToken(.word),
			"".asToken(.separator),
			"String".asToken(.word),
			"".asToken(.separator),
			"1".asToken(.word)
		])

		#expect("snake_case"._tokenize() == [
			"snake".asToken(.word),
			"_".asToken(.separator),
			"case".asToken(.word)
		])

		#expect("kebab-case"._tokenize() == [
			"kebab".asToken(.word),
			"-".asToken(.separator),
			"case".asToken(.word)
		])

		#expect("trailingSymbol$"._tokenize() == [
			"trailing".asToken(.word),
			"".asToken(.separator),
			"Symbol".asToken(.word),
			"$".asToken(.separator),
		])

		#expect("mixEd-case_example"._tokenize() == [
			"mix".asToken(.word),
			"".asToken(.separator),
			"Ed".asToken(.word),
			"-".asToken(.separator),
			"case".asToken(.word),
			"_".asToken(.separator),
			"example".asToken(.word),
		])

		#expect("$_prefixedThing"._tokenize() == [
			"$_".asToken(.separator),
			"prefixed".asToken(.word),
			"".asToken(.separator),
			"Thing".asToken(.word)
		])
	}

	@Test
	func withAcronyms() async throws {
		#expect("UUIDJSON"._tokenize() == [
			"UUID".asToken(.word),
			"".asToken(.separator),
			"JSON".asToken(.word),
		])

		#expect("UUIDString"._tokenize() == [
			"UUID".asToken(.word),
			"".asToken(.separator),
			"String".asToken(.word),
		])

		// Does not detect hidden acronyms
		#expect("hasuuidacronym"._tokenize() == [
			"hasuuidacronym".asToken(.word)
		])

		#expect("hasUUIDacronym"._tokenize() == [
			"has".asToken(.word),
			"".asToken(.separator),
			"UUID".asToken(.word),
			"".asToken(.separator),
			"acronym".asToken(.word),
		])

		#expect("HAS,uuid acronym"._tokenize() == [
			"HAS".asToken(.word),
			",".asToken(.separator),
			"uuid".asToken(.word),
			" ".asToken(.separator),
			"acronym".asToken(.word),
		])

		#expect(
			"__iduuidIdentifierSome_random-stringOf.Cases.1.23.idfaUuid"._tokenize() == [
				"__".asToken(.separator),
				"id".asToken(.word),
				"".asToken(.separator),
				"uuid".asToken(.word),
				"".asToken(.separator),
				"Identifier".asToken(.word),
				"".asToken(.separator),
				"Some".asToken(.word),
				"_".asToken(.separator),
				"random".asToken(.word),
				"-".asToken(.separator),
				"string".asToken(.word),
				"".asToken(.separator),
				"Of".asToken(.word),
				".".asToken(.separator),
				"Cases".asToken(.word),
				".".asToken(.separator),
				"1".asToken(.word),
				".".asToken(.separator),
				"23".asToken(.word),
				".".asToken(.separator),
				"idfa".asToken(.word),
				"".asToken(.separator),
				"Uuid".asToken(.word),
			]
		)
	}
}

extension String {
	func _tokenize() -> [Casification.Token] {
		tokenize(using: .default())
	}
}

extension String {
	func asToken(_ kind: Casification.Token.Kind) -> Casification.Token {
		return .init(self[...], kind: kind)
	}
}
