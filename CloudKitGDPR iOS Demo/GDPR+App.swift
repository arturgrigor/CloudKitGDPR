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
    
    /// Singleton.
    static let shared = GDPR(metadata: [
        CKContainer.default(): ["someRecordType"],
    ], containerNameMapping: [
        CKContainer.default(): "default",
    ])
    
}
