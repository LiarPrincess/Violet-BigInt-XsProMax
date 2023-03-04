// swift-tools-version:5.0

import PackageDescription

let package = Package(
  name: "BigIntXsProMax",
  platforms: [
    .macOS(.v10_11)
  ],
  products: [
    .executable(name: "Main", targets: ["Main"]),
    .library(name: "BigInt", targets: ["BigInt"]),
  ],
  targets: [
    .target(name: "BigInt", path: "Sources"),
    .target(name: "Main", dependencies: ["BigInt"], path: "Main"),
    .testTarget(name: "BigIntTests", dependencies: ["BigInt"], path: "Tests"),
  ]
)
