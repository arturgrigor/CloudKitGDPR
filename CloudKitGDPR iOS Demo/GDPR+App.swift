//
//  GDPR+App.swift
//  CloudKitGDPR iOS Demo
//
//  Created by Artur Grigor on 02.05.2018.
//  Copyright © 2018 Artur Grigor. All rights reserved.
//

import CloudKitGDPR
import CloudKit

//
//  # Extension
//

extension GDPR {
    
    // MARK: - Singleton -
    
    static let defaultContainer = CKContainer(identifier: "iCloud.com.example.myexampleapp")
    
    /// Singleton.
    static let shared = GDPR(metadata: [
        defaultContainer: ["SomeRecordType"],
    ], containerNameMapping: [
        defaultContainer: "default",
    ])
    
}
