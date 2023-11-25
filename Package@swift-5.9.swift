// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

var dependencies: [Package.Dependency] = []

#if swift(>=5.9)
typealias PackageDep = PackageDescription.Package.Dependency
func appleUrl(_ name: String) -> String {
  "https://github.com/apple/\(name).git"
}
func applePackDep(_ name: String, _ version: Version) -> PackageDep {
  packDep(appleUrl(name), version)
}
func applePackDep(_ name: String, commit: String) -> PackageDep {
  return .package(url: appleUrl(name), revision: commit)
}

func packDep(_ url: String, _ version: Version) -> PackageDep {
  let patch = version.patch + 1
  let range = version ..< Version(version.major, version.minor, patch)
  return .package(url: url, range)
}
dependencies.append(contentsOf: [
  // not 5.3.1, 5.9.1
  // git rev-list -n 1 "swift-5.9.1-RELEASE"
  applePackDep(
    "indexstore-db",
    commit: "89ec16c2ac1bb271614e734a2ee792224809eb20"),
    //.init(5, 9, 1)), // 5.3.1? swift-5.9.1-RELEASE
  applePackDep("swift-tools-support-core", .init(0, 6, 1)), // main -> 9/18/23
  packDep("https://github.com/jpsim/Yams.git", .init(2, 0, 0)),
  applePackDep("swift-syntax", .init(509, 0, 2)),
  applePackDep("swift-argument-parser", .init(1, 2, 3)),
])

#else
dependencies.append(
  .package(url: "https://github.com/apple/swift-argument-parser.git", 
    .exact("0.3.2"))
  .package(name: "IndexStoreDB", url: "https://github.com/apple/indexstore-db.git", .branch("release/5.3")),
  .package(name: "swift-tools-support-core", url: "https://github.com/apple/swift-tools-support-core.git", .branch("main")),
  .package(url: "https://github.com/jpsim/Yams.git", from: "2.0.0"),
  ]
)
#if swift(>=5.5)
dependencies.append(
    .package(
        name: "SwiftSyntax",
        url: "https://github.com/apple/swift-syntax",
        .exact("0.50500.0")
    )
)
#elseif swift(>=5.4)
dependencies.append(
    .package(
        name: "SwiftSyntax",
        url: "https://github.com/apple/swift-syntax",
        .exact("0.50400.0")
    )
)
#elseif swift(>=5.3)
dependencies.append(
    .package(
        name: "SwiftSyntax",
        url: "https://github.com/apple/swift-syntax",
        .exact("0.50300.0")
    )
)
#else
fatalError("This version of Periphery does not support Swift <= 5.2.")
#endif
#endif

let package = Package(
    name: "pecker",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "pecker", targets: ["Pecker"])
    ],
    dependencies: dependencies,
    targets: [
        .executableTarget(
            name: "Pecker",
            dependencies: [
                "PeckerKit",
                .product(name: "SwiftToolsSupport-auto", package: "swift-tools-support-core"),
                .product(name: "ArgumentParser", package: "swift-argument-parser")]
        ),
        .target(
            name: "PeckerKit",
            dependencies: [
              .product(name: "SwiftSyntax", package: "swift-syntax"),
              .product(name: "SwiftParser", package: "swift-syntax"),
              .product(name: "IndexStoreDB", package: "indexstore-db"),
                //"SwiftSyntax",
                //"IndexStoreDB",
                .product(name: "SwiftToolsSupport-auto", package: "swift-tools-support-core"),
                "Yams"
            ]
        ),
        .testTarget(
            name: "PeckerTests",
            dependencies: ["Pecker"]),
    ]
)
