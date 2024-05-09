// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StoryboardUtil",
    platforms: [.iOS("13.0")],
    products: [
        .library(
            name: "StoryboardUtil",
            targets: ["StoryboardUtil"]),
    ],
    dependencies: [ ],
    targets: [
        .target(
            name: "StoryboardUtil",
            dependencies: [],
            path: "StoryboardUtil"),
    ]
)
