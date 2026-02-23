// swift-tools-version: 6.0

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
			url: "https://github.com/pointfreeco/xctest-dynamic-overlay.git",
			.upToNextMajor(from: "1.9.0")
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
					package: "xctest-dynamic-overlay"
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
