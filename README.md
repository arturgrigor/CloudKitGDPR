[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Build Status](https://travis-ci.org/arturgrigor/CloudKitGDPR.svg?branch=master)](https://travis-ci.org/arturgrigor/CloudKitGDPR)
[![Twitter](https://img.shields.io/badge/twitter-@arturgrigor-blue.svg?style=flat)](http://twitter.com/arturgrigor)

# CloudKitGDPR

Swift framework for allowing users to manage data stored in iCloud. This project is based on the [sample code](https://developer.apple.com/support/allowing-users-to-manage-data) provided by Apple.

## Requirements

- iOS 8.0+ / macOS 10.10+ / tvOS 9.0+ / watchOS 3.0+
- Xcode 9.0+
- Swift 4.1+

## Installation

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate CloudKitGDPR into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "arturgrigor/CloudKitGDPR" ~> 1.0
```

Run `carthage update` to build the framework and drag the built `CloudKitGDPR.framework` into your Xcode project.

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. It is in early development, but CloudKitGDPR does support its use on supported platforms. 

Once you have your Swift package set up, adding CloudKitGDPR as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .Package(url: "https://github.com/arturgrigor/CloudKitGDPR.git", majorVersion: 1)
]
```

## Usage

### Create the instance ###

```swift
import CloudKitGDPR

let defaultContainer = CKContainer.default()
let documents = CKContainer(identifier: "iCloud.com.example.myexampleapp.documents")
let settings = CKContainer(identifier: "iCloud.com.example.myexampleapp.settings")

let metadata: GDPR.RecordTypesByContainer = [
  defaultContainer: ["log", "verboseLog"],
  documents: ["textDocument", "spreadsheet"],
  settings: ["preference", "profile"]
]

let maping: GDPR.ContainerNameMapping = [
  defaultContainer: "default",
  documents: "docs",
  settings: "settings"
]

let gdpr = GDPR(metadata: metadata, containerNameMapping: maping)
```

### Export Data ###

Export all user's private data as JSON files.
```swift
gdpr.exportData(usingTransformer: JSONDataTransformer.default) { result in
  switch result {
    case .failure(let error):
      print("GDPR export data error: \(error)")
	
    case .success(let value):
      print("User's private data: \(value)")
  }
}
```

### Delete All Data ###

```swift
gdpr.deleteData { result in
  switch result {
    case .failure(let error):
      print("GDPR delete data error: \(error)")

    case .success(_):
      // TODO: Maybe cleanup the local data too
      print("All user's private data deleted.")
    }
}
```

# Contact

- [GitHub](http://github.com/arturgrigor)
- [Twitter](http://twitter.com/arturgrigor)

Let me know if you're using or enjoying this product.
