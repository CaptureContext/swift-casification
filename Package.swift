// swift-tools-version: 6.0

import PackageDescription

// Match Point-Free's package identity for this compiler's compatibility manifests.
#if compiler(>=6.4)
let issueReportingPackage: String = "swift-issue-reporting"
let issueReportingVersion: Version = "2.0.0"
#else
let issueReportingPackage: String = "xctest-dynamic-overlay"
// 1.5 retains Swift 5.9 support; newer compilers can resolve newer 1.x releases.
let issueReportingVersion: Version = "1.5.0"
#endif

let package = Package(
	name: "swift-casification",
	platforms: [
		.macOS(.v10_15),
		.macCatalyst(.v13),
		.iOS(.v13),
		.tvOS(.v13),
		.watchOS(.v6)
	],
	products: [
		.library(
			name: "Casification",
			targets: ["Casification"]
		),
	],
	dependencies: [
		.package(
			url: "https://github.com/pointfreeco/swift-concurrency-extras.git",
			.upToNextMajor(from: "1.3.0")
		),
		.package(
			url: "https://github.com/pointfreeco/\(issueReportingPackage).git",
			.upToNextMajor(from: issueReportingVersion)
		),
		.package(
			url: "https://github.com/capturecontext/swift-keypaths-extensions.git",
			.upToNextMinor(from: "0.2.0")
		),
	],
	targets: [
		.target(
			name: "Casification",
			dependencies: [
				.product(
					name: "ConcurrencyExtras",
					package: "swift-concurrency-extras"
				),
				.product(
					name: "IssueReporting",
					package: issueReportingPackage
				),
				.product(
					name: "KeyPathsExtensions",
					package: "swift-keypaths-extensions"
				),
			]
		),
		.testTarget(
			name: "CasificationTests",
			dependencies: [
				.target(name: "Casification"),
			]
		),
	],
	swiftLanguageModes: [.v6]
)
