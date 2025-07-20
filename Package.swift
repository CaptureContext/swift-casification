// swift-tools-version: 6.2

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
	targets: [
		.target(
			name: "Casification"
		),
		.testTarget(
			name: "CasificationTests",
			dependencies: [
				.target(name: "Casification"),
			]
		),
	]
)
