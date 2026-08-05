// swift-tools-version: 5.9

import PackageDescription

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
			url: "https://github.com/pointfreeco/swift-issue-reporting.git",
			.upToNextMajor(from: "2.0.0")
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
					package: "swift-issue-reporting"
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
	]
)
