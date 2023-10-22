// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Iatheto",
  products: [
    .library(
      name: "Iatheto",
      targets: ["Iatheto"]
    ),
  ],
  targets: [
    .target(
      name: "Iatheto",
      dependencies: []
    ),
    .testTarget(
      name: "IathetoTests",
      dependencies: ["Iatheto"]
    ),
  ]
)
