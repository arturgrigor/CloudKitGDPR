[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Build Status](https://travis-ci.org/arturgrigor/CloudKitGDPR.svg?branch=master)](https://travis-ci.org/arturgrigor/CloudKitGDPR)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/CloudKitGDPR.svg)](https://img.shields.io/cocoapods/v/CloudKitGDPR.svg)
[![Platform](https://img.shields.io/cocoapods/p/CloudKitGDPR.svg?style=flat)](http://cocoadocs.org/docsets/CloudKitGDPR)
[![Twitter](https://img.shields.io/badge/twitter-@arturgrigor-blue.svg?style=flat)](http://twitter.com/arturgrigor)

# CloudKitGDPR

Swift framework for allowing users to manage data stored in iCloud. This project is based on the [sample code](https://developer.apple.com/support/allowing-users-to-manage-data) provided by Apple.

## Requirements

- iOS 8.0+ / macOS 10.10+ / tvOS 9.0+ / watchOS 3.0+
- Xcode 10.2+
- Swift 5.0+

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
github "arturgrigor/CloudKitGDPR" ~> 2.1
```

Run `carthage update` to build the framework and drag the built `CloudKitGDPR.framework` into your Xcode project.

❗️ Please note that since version 1.2 this is a *Static Framework* and it does not need to be included in the **carthage copy-frameworks** Build Phase. For more information please consult the [Build static frameworks to speed up your app’s launch times](https://github.com/Carthage/Carthage#carthage-0300-or-higher) section.

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 1.1.0+ is required.

To integrate CloudKitGDPR into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'CloudKitGDPR', '~> 2.1'
end
```

Then, run the following command:

```bash
$ pod install
```

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. It is in early development, but CloudKitGDPR does support its use on supported platforms.

Once you have your Swift package set up, adding CloudKitGDPR as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .Package(url: "https://github.com/arturgrigor/CloudKitGDPR.git", majorVersion: 2)
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

Supported transformers
- `ZeroDataTransformer`: This will give you the CloudKit records directly without any other transformation.
- `CSVDataTransformer`: This will give you a list of CSV files.
- `JSONDataTransformer`: This will give you a list of JSON files.

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

## Advanced Usage

### iOS

Export data as JSON files in a ZIP archive using the [ZIPFoundation](https://github.com/weichsel/ZIPFoundation) framework.

```swift
import CloudKitGDPR
import ZIPFoundation

lazy var applicationCachesDirectory: URL = {
  let urls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
  return urls[urls.count-1]
}()

gdpr.exportData(usingTransformer: JSONDataTransformer.default) { result in
  switch result {
    case .failure(let error):
      print("GDPR export data error: \(error)")

    case .success(let value):
      DispatchQueue.global(qos: .background).async {
        let url = self.applicationCachesDirectory.appendingPathComponent("data.zip")
        let archive = Archive(url: url, accessMode: .create)
        for (fileName, csvContents) in value {
          let data = Data(bytes: Array(csvContents.utf8))
          try? archive?.addEntry(with: fileName, type: .file, uncompressedSize: UInt32(data.count), provider: { data[$0..<$0+$1] })
        }

        DispatchQueue.main.async {
          let viewController = UIActivityViewController(activityItems: [url], applicationActivities: [])
          viewController.popoverPresentationController?.sourceView = self.exportDataCell
          viewController.completionWithItemsHandler = { _, _, _, _ in
            try? FileManager.default.removeItem(at: url)
          }

          self.present(viewController, animated: true, completion: nil)
        }
      }
  }
}
```

## Notes

### iOS Demo Prerequisites
- Change the identifier for the `defaultContainer` in the `GDPR+App.swift` file to one that's accessible to you.
- Replace the `"SomeRecordType"` record type in the same file with one that's actually used in that container.
- Use the same container identifier for the `com.apple.developer.icloud-container-identifiers` key in the `Demo.entitlements` file.

# Contact

- [GitHub](https://github.com/arturgrigor)
- [Twitter](https://twitter.com/arturgrigor)

Let me know if you're using or enjoying this product.
