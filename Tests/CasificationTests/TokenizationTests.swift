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
			"1".asToken(.number)
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
	func tricky() async throws {
		#expect("Midlane"._tokenize() == [
			"Midlane".asToken(.word),
		])

		#expect("MIDlane"._tokenize() == [
			"MIDlane".asToken(.word),
		])

		#expect("MIDLane"._tokenize() == [
			"MIDLane".asToken(.word),
		])

		#expect("MIDLANE"._tokenize() == [
			"MIDLANE".asToken(.word),
		])

		#expect("identity"._tokenize() == [
			"identity".asToken(.word),
		])

		#expect("IDENTITY"._tokenize() == [
			"IDENTITY".asToken(.word),
		])

		#expect("UUIDstring"._tokenize() == [
			"UUID".asToken(.acronym),
			"".asToken(.separator),
			"string".asToken(.word),
		])

		#expect("UUIDString"._tokenize() == [
			"UUID".asToken(.acronym),
			"".asToken(.separator),
			"String".asToken(.word),
		])

		#expect("UUIDSTRING"._tokenize() == [
			"UUIDSTRING".asToken(.word),
		])

		#expect("uuidstring"._tokenize() == [
			"uuidstring".asToken(.word)
		])

		#expect("uuidString"._tokenize() == [
			"uuid".asToken(.acronym),
			"".asToken(.separator),
			"String".asToken(.word),
		])

		#expect("uuidSTRING"._tokenize() == [
			"uuid".asToken(.acronym),
			"".asToken(.separator),
			"STRING".asToken(.word),
		])

		#expect("UUIDjson"._tokenize() == [
			"UUID".asToken(.acronym),
			"".asToken(.separator),
			"json".asToken(.acronym),
		])

		#expect("UUIDJson"._tokenize() == [
			"UUID".asToken(.acronym),
			"".asToken(.separator),
			"Json".asToken(.acronym),
		])

		#expect("UUIDJSON"._tokenize() == [
			"UUID".asToken(.acronym),
			"".asToken(.separator),
			"JSON".asToken(.acronym),
		])

		#expect("uuidjson"._tokenize() == [
			"uuid".asToken(.acronym),
			"".asToken(.separator),
			"json".asToken(.acronym),
		])

		#expect("uuidJson"._tokenize() == [
			"uuid".asToken(.acronym),
			"".asToken(.separator),
			"Json".asToken(.acronym),
		])

		#expect("uuidJSON"._tokenize() == [
			"uuid".asToken(.acronym),
			"".asToken(.separator),
			"JSON".asToken(.acronym),
		])
	}

	@Test
	func withAcronyms() async throws {
		#expect("UUIDJSON"._tokenize() == [
			"UUID".asToken(.acronym),
			"".asToken(.separator),
			"JSON".asToken(.acronym),
		])

		#expect("UUIDString"._tokenize() == [
			"UUID".asToken(.acronym),
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
			"UUID".asToken(.acronym),
			"".asToken(.separator),
			"acronym".asToken(.word),
		])

		#expect("HAS,uuid acronym"._tokenize() == [
			"HAS".asToken(.word),
			",".asToken(.separator),
			"uuid".asToken(.acronym),
			" ".asToken(.separator),
			"acronym".asToken(.word),
		])

		#expect(
			"__iduuidIdentifierSome_random-stringOf.Cases.1.23.idfaUuid"._tokenize() == [
				"__".asToken(.separator),
				"id".asToken(.acronym),
				"".asToken(.separator),
				"uuid".asToken(.acronym),
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
				"1".asToken(.number),
				".".asToken(.separator),
				"23".asToken(.number),
				".".asToken(.separator),
				"idfa".asToken(.acronym),
				"".asToken(.separator),
				"Uuid".asToken(.acronym),
			]
		)

		#expect(
			"AaaaAaaa"._tokenize() == [
				"Aaaa".asToken(.word),
				"".asToken(.separator),
				"Aaaa".asToken(.word),
			]
		)

		#expect("identity"._tokenize() == [
			"identity".asToken(.word),
		])

		#expect(
			"grid1x1"._tokenize() == [
				"grid".asToken(.word),
				"".asToken(.separator),
				"1".asToken(.number),
				"".asToken(.separator),
				"x".asToken(.word),
				"".asToken(.separator),
				"1".asToken(.number),
			]
		)

		#expect(
			"lens1x"._tokenize() == [
				"lens".asToken(.word),
				"".asToken(.separator),
				"1".asToken(.number),
				"".asToken(.separator),
				"x".asToken(.word),
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
