import Testing
@testable import Casification

@Suite
struct CamelCaseModifierTests {
	@Test
	func automatic() async throws {
		#expect("".case(.camel()) == "")
		#expect("u".case(.camel()) == "u")
		#expect("lowercase".case(.camel()) == "lowercase")
		#expect("UPPERCASE".case(.camel()) == "Uppercase")
		#expect("normalCamelCase".case(.camel()) == "normalCamelCase")
		#expect("_normalCamelCase".case(.camel()) == "_normalCamelCase")
		#expect("_normalCamelCase".case(.camel()) == "_normalCamelCase")
		#expect("Almost.Correct.Case".case(.camel()) == "AlmostCorrectCase")
		#expect("NumericSeparator.1.0".case(.camel()) == "NumericSeparator_1_0")
		#expect("URLAcronym".case(.camel()) == "URLAcronym")
		#expect("uuidAcronym".case(.camel()) == "uuidAcronym")
		#expect("suffix-acronym-id".case(.camel()) == "suffixAcronymID")
		#expect("infix-id-acronym".case(.camel()) == "infixIDAcronym")
		#expect("WordWithAcronym_Identifier".case(.camel()) == "WordWithAcronymIdentifier")
		#expect("UUIDIdentifier-combinedAcronyms".case(.camel()) == "UUIDIdentifierCombinedAcronyms")
		#expect("1numbered".case(.camel()) == "1_numbered")
		#expect("1Numbered".case(.camel()) == "1_Numbered")
		#expect("_unknown.symbols<>_found".case(.camel()) == "_unknownSymbolsFound")
		#expect(
			"__iduuidIdentifierSome_random-stringOf.Cases.1.23.idfaUuid".case(.camel())
			== "__idUUIDIdentifierSomeRandomStringOfCases_1_23_idfaUUID"
		)

		do { // numbers
			#expect("numbers_1.23.in-a-sentence".case(.camel()) == "numbers_1_23_inASentence")
			#expect("Numbers_1.23.in-a-Sentence".case(.camel()) == "Numbers_1_23_InASentence")
			#expect("grid1x1".case(.camel()) == "grid_1x1")
			#expect("Grid1x1".case(.camel()) == "Grid_1x1")
			#expect("lens1x".case(.camel()) == "lens_1x")
		}
	}

	@Test
	func camel() async throws {
		#expect("".case(.camel) == "")
		#expect("u".case(.camel) == "u")
		#expect("lowercase".case(.camel) == "lowercase")
		#expect("UPPERCASE".case(.camel) == "uppercase")
		#expect("normalCamelCase".case(.camel) == "normalCamelCase")
		#expect("_normalCamelCase".case(.camel) == "_normalCamelCase")
		#expect("_normalCamelCase".case(.camel) == "_normalCamelCase")
		#expect("Almost.Correct.Case".case(.camel) == "almostCorrectCase")
		#expect("NumericSeparator.1.0".case(.camel) == "numericSeparator_1_0")
		#expect("URLAcronym".case(.camel) == "urlAcronym")
		#expect("uuidAcronym".case(.camel) == "uuidAcronym")
		#expect("suffix-acronym-id".case(.camel) == "suffixAcronymID")
		#expect("infix-id-acronym".case(.camel) == "infixIDAcronym")
		#expect("WordWithAcronym_Identifier".case(.camel) == "wordWithAcronymIdentifier")
		#expect("UUIDIdentifier-combinedAcronyms".case(.camel) == "uuidIdentifierCombinedAcronyms")
		#expect("1numbered".case(.camel) == "1_numbered")
		#expect("1Numbered".case(.camel) == "1_numbered")
		#expect("_unknown.symbols<>_found".case(.camel) == "_unknownSymbolsFound")
		#expect(
			"__iduuidIdentifierSome_random-stringOf.Cases.1.23.idfaUuid".case(.camel)
			== "__idUUIDIdentifierSomeRandomStringOfCases_1_23_idfaUUID"
		)

		do { // numbers
			#expect("numbers_1.23.in-a-sentence".case(.camel) == "numbers_1_23_inASentence")
			#expect("grid1x1".case(.camel) == "grid_1x1")
			#expect("lens1x".case(.camel) == "lens_1x")
		}
	}

	@Test
	func pascal() async throws {
		#expect("".case(.pascal) == "")
		#expect("u".case(.pascal) == "U")
		#expect("lowercase".case(.pascal) == "Lowercase")
		#expect("UPPERCASE".case(.pascal) == "Uppercase")
		#expect("normalCamelCase".case(.pascal) == "NormalCamelCase")
		#expect("_normalCamelCase".case(.pascal) == "_NormalCamelCase")
		#expect("_normalCamelCase".case(.pascal) == "_NormalCamelCase")
		#expect("Almost.Correct.Case".case(.pascal) == "AlmostCorrectCase")
		#expect("NumericSeparator.1.0".case(.pascal) == "NumericSeparator_1_0")
		#expect("URLAcronym".case(.pascal) == "URLAcronym")
		#expect("uuidAcronym".case(.pascal) == "UUIDAcronym")
		#expect("suffix-acronym-id".case(.pascal) == "SuffixAcronymID")
		#expect("infix-id-acronym".case(.pascal) == "InfixIDAcronym")
		#expect("WordWithAcronym_Identifier".case(.pascal) == "WordWithAcronymIdentifier")
		#expect("UUIDIdentifier-combinedAcronyms".case(.pascal) == "UUIDIdentifierCombinedAcronyms")
		#expect("1numbered".case(.pascal) == "1_Numbered")
		#expect("1Numbered".case(.pascal) == "1_Numbered")
		#expect("_unknown.symbols<>_found".case(.pascal) == "_UnknownSymbolsFound")
		#expect(
			"__iduuidIdentifierSome_random-stringOf.Cases.1.23.idfaUuid".case(.pascal)
			== "__IDUUIDIdentifierSomeRandomStringOfCases_1_23_IDFAUUID"
		)
	}

	@Test
	func alternativeAcronymProcessing() {
		// NOTE: It uses `CamelCaseConfig.Mode.camel`

		do { // default
			// NOTE: Doesn't override `.camel` mode, first token is lowercased
			#expect("url-ID-Uri-uuid".case(.alternativeCamel(.default)) == "urlIDURIUUID")
			#expect("URL-ID-Uri-uuid".case(.alternativeCamel(.default)) == "urlIDURIUUID")
			#expect("Url-ID-Uri-uuid".case(.alternativeCamel(.default)) == "urlIDURIUUID")
		}

		do { // alwaysMatchCase (default)
			// NOTE: Doesn't override `.camel` mode, first token is lowercased
			#expect("url-ID-Uri-uuid".case(.alternativeCamel(.alwaysMatchCase)) == "urlIDURIUUID")
			#expect("URL-ID-Uri-uuid".case(.alternativeCamel(.alwaysMatchCase)) == "urlIDURIUUID")
			#expect("Url-ID-Uri-uuid".case(.alternativeCamel(.alwaysMatchCase)) == "urlIDURIUUID")
		}

		do { // alwaysCapitalize
			// NOTE: Overrides `.camel` mode, first token is capitalized as well as the rest of tokens
			#expect("url-ID-Uri-uuid".case(.alternativeCamel(.alwaysCapitalize)) == "UrlIdUriUuid")
			#expect("URL-ID-Uri-uuid".case(.alternativeCamel(.alwaysCapitalize)) == "UrlIdUriUuid")
			#expect("Url-ID-Uri-uuid".case(.alternativeCamel(.alwaysCapitalize)) == "UrlIdUriUuid")
		}

		do { // conditionalCapitalization
			// NOTE: Doesn't override `.camel` mode, first token is lowercased
			#expect("url-ID-Uri-uuid".case(.alternativeCamel(.conditionalCapitalization)) == "urlIdUriUuid")
			#expect("URL-ID-Uri-uuid".case(.alternativeCamel(.conditionalCapitalization)) == "urlIdUriUuid")
			#expect("Url-ID-Uri-uuid".case(.alternativeCamel(.conditionalCapitalization)) == "urlIdUriUuid")
		}

		do { // preserve
			// NOTE: Overrides `.camel` mode, first token is preserved as well as the rest of tokens
			#expect("url-ID-Uri-uuid".case(.alternativeCamel(.preserve)) == "urlIDUriuuid")
			#expect("URL-ID-Uri-uuid".case(.alternativeCamel(.preserve)) == "URLIDUriuuid")
			#expect("Url-ID-Uri-uuid".case(.alternativeCamel(.preserve)) == "UrlIDUriuuid")
		}
	}
}

extension String.Casification.Modifier where Self == String.Casification.Modifiers.Camel<
	String.Casification.PrefixPredicates.AllowedCharacters
> {
	typealias Policy = String.Casification.Modifiers.CamelCaseConfig.Acronyms.ProcessingPolicy
	static func alternativeCamel(_ policy: Policy) -> Self {
		.camel(.camel, acronyms: .init(processingPolicy: policy))
	}
}
