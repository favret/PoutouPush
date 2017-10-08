import PackageDescription

let package = Package(
  name: "PoutouPush",
  dependencies: [
    .package(url: "https://github.com/IBM-Swift/CCurl.git", from:"0.4.1")
  ]
)
