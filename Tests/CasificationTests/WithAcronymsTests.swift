import Testing
@_spi(Internals) import Casification

@Suite
struct WithAcronymsTests {
	@Test
	func acronymsOverrdie() async throws {
		// `prepareConfiguration` should only be called once and even though
		// it's technically possible to use it in tests, it overrides
		// global default and breaks other tests that rely on it
		//
		// String.Casification.prepareConfiguration { $0.acronyms = ["test"] }
		//
		// #expect("test_id"._tokenize() == [
		// 	"test".asToken(.acronym),
		// 	"_".asToken(.separator),
		// 	"id".asToken(.word),
		// ])

		withAcronyms { $0
			.formUnion(["test", "id"])
		} operation: {
			#expect("test_id"._tokenize() == [
				"test".asToken(.acronym),
				"_".asToken(.separator),
				"id".asToken(.acronym),
			])

			withAcronyms(["id"]) {
				#expect("test_id"._tokenize() == [
					"test".asToken(.word),
					"_".asToken(.separator),
					"id".asToken(.acronym),
				])
			}
		}
	}
}
