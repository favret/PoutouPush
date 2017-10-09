// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PoutouPush",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "PoutouPush",
            targets: ["PoutouPush"]
        )
    ],
    dependencies: [
      .package(url: "https://github.com/IBM-Swift/CCurl.git", from: "0.4.1")
    ],
    targets: [
        .target(name: "PoutouPush",
        dependencies: [])
    ]
)
