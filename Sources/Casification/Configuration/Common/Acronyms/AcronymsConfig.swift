extension Set where Element == Substring {
	public static var currentAcronyms: Self { String.Casification.Configuration.current.common.acronyms }
	public static let defaultAcronyms: Self = [
		"uri", "Uri", "URI",
		"url", "Url", "URL",
		"spm", "Spm", "SPM",
		"npm", "Npm", "NPM",
		"id", "Id", "ID", // todo: add more common acronyms like SQL
		"uuid", "Uuid", "UUID",
		"ulid", "Ulid", "ULID",
		"usid", "Usid", "USID",
		"idfa", "Idfa", "IDFA",
		"void", "Void", "VOID",
		"json", "Json", "JSON",
		"xml", "Xml", "XML",
		"yaml", "Yaml", "YAML", // todo: add more extensions
		"sf", "SF",
		"ns", "NS",
		"ui", "UI",
		"ux", "UX",
		"sk", "SK" // todo: add more system prefixes
	]
}

// MARK: - ConfigurationKey

extension String.Casification.Configuration.Common {
	private enum AcronymsKey: String.Casification.ConfigurationKey {
		static var `default`: Set<Substring> { .defaultAcronyms }
	}

	public var acronyms: Set<Substring> {
		get { self[AcronymsKey.self] }
		set { self[AcronymsKey.self] = newValue }
	}
}

extension String.Casification.Configuration {
	/// Alias for `common.acronyms`
	public var acronyms: Set<Substring> {
		get { common.acronyms }
		set { common.acronyms = newValue }
	}
}
