//
//  CKDatabase+AllRecords.swift
//  CloudKitGDPR
//
//  Created by Artur Grigor on 02.05.2018.
//  Copyright © 2018 Artur Grigor. All rights reserved.
//

import CloudKit

//
//  # Extension
//

public extension CKDatabase {
    
    // MARK: - Methods -
    
    /// Searches the specified zone asynchronously for **all** records that match the query parameters.
    ///
    /// - Parameters:
    ///   - query: The query object containing the parameters for the search.
    ///   - zoneID: The ID of the zone to search. Search results are limited to records in the specified zone. Specify `nil` to search the default zone of the database.
    ///   - completion: A closure that will be called upon completion.
    func allRecords(forQuery query: CKQuery, inZoneWith zoneID: CKRecordZone.ID?, completion: @escaping ([CKRecord]?, Error?) -> Void) {
        var result: [CKRecord] = []
        let operation = CKQueryOperation(query: query)
        operation.resultsLimit = CKQueryOperation.maximumResults
        operation.zoneID = zoneID
        operation.recordFetchedBlock = { record in
            result.append(record)
        }
        operation.queryCompletionBlock = self.queryCompletionBlock(forInitialOperation: operation) { error in
            if let error = error {
                completion(nil, error)
            } else {
                completion(result, nil)
            }
        }
        self.add(operation)
    }
    
    // MARK: - Helpers -
    
    /// `CKQueryOperation.queryCompletionBlock` builder.
    ///
    /// - Parameters:
    ///   - initialOperation: The initial operation.
    ///   - completion: A closure that will be called after fetching all data.
    fileprivate func queryCompletionBlock(forInitialOperation initialOperation: CKQueryOperation, completion: @escaping (Error?) -> Void) -> ((CKQueryOperation.Cursor?, Error?) -> Void) {
        return { cursor, error in
            if let error = error {
                completion(error)
                return
            }
            
            if let cursor = cursor {
                let newOperation = CKQueryOperation(cursor: cursor)
                newOperation.resultsLimit = initialOperation.resultsLimit
                newOperation.zoneID = initialOperation.zoneID
                newOperation.recordFetchedBlock = initialOperation.recordFetchedBlock
                newOperation.queryCompletionBlock = self.queryCompletionBlock(forInitialOperation: newOperation, completion: completion)
                self.add(newOperation)
            } else {
                completion(nil)
            }
        }
    }
    
}
