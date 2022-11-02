//
//  GDPR.swift
//  CloudKitGDPR
//
//  Created by Artur Grigor on 02.05.2018.
//  Copyright © 2018 Artur Grigor. All rights reserved.
//

import Foundation
import CloudKit

//
//  # Class
//

/// Utility for allowing users to manage data stored in iCloud.
/// - Note: This project is based on the [sample code](https://developer.apple.com/support/allowing-users-to-manage-data) provided by Apple.
open class GDPR {
    
    // MARK: - Types -
    
    /// Record Types by Containers.
    public typealias RecordTypesByContainer = [CKContainer: [String]]
    /// Records by Record Types by Containers.
    public typealias RecordsByRecordTypeByContainer = [CKContainer: [String: [CKRecord]]]
    /// Record Zone IDs by Containers.
    public typealias RecordsZoneIDsByContainer = [CKContainer: [CKRecordZone.ID]]
    /// Container name mapping.
    public typealias ContainerNameMapping = [CKContainer: String]
    
    /// GDPR Error type.
    public enum Error: Swift.Error {
        case noZones(CKContainer)
    }
    
    /// Result type.
    public enum Result<T> {
        case success(T)
        case failure(Swift.Error)
    }
    
    // MARK: - Properties -
    
    /// Record Types by Containers.
    public let metadata: RecordTypesByContainer
    
    /// Container name mapping.
    public let containerNameMapping: ContainerNameMapping
    
    // MARK: - Initialization -
    
    /// Default initialization.
    /// ## Usage
    /// ```
    /// let defaultContainer = CKContainer.default()
    /// let documents = CKContainer(identifier: "iCloud.com.example.myexampleapp.documents")
    /// let settings = CKContainer(identifier: "iCloud.com.example.myexampleapp.settings")
    ///
    /// let metadata: RecordTypesByContainer = [
    ///     defaultContainer: ["log", "verboseLog"],
    ///     documents: ["textDocument", "spreadsheet"],
    ///     settings: ["preference", "profile"]
    /// ]
    ///
    /// let maping: ContainerNameMapping = [
    ///     defaultContainer: "default",
    ///     documents: "docs",
    ///     settings: "settings"
    /// ]
    ///
    /// let gdpr = GDPR(metadata: metadata, containerNameMapping: maping)
    /// ```
    /// - Parameters:
    ///   - metadata: List all the Containers and the Record Types inside each one to determine which records will be exported.
    ///   - containerNameMapping: Give names/aliases to the containers. This mapping is used for computing file names for the exported files. The file name format is *"name_recordType.ext"*. **Note**: If the name is not defined for a container then a UUID is used instead.
    public init(metadata: RecordTypesByContainer, containerNameMapping: ContainerNameMapping = [:]) {
        self.metadata = metadata
        self.containerNameMapping = containerNameMapping
    }
    
    // MARK: - Methods -
    
    /// Export user's private data.
    ///
    /// - Parameters:
    ///   - transformer: Data transformer.
    ///   - completion: A closure that will be called upon completion.
    open func exportData<T: DataTransformer>(usingTransformer transformer: T, _ completion: @escaping (Result<T.Result>) -> Void) {
        var failure: Swift.Error? = nil
        let dispatchGroup = DispatchGroup()
        var result: RecordsByRecordTypeByContainer = [:]
        
        for (container, recordTypes) in self.metadata {
            guard failure == nil else {
                return
            }
            
            // User data should be stored in the private database.
            let database = container.privateCloudDatabase
            
            dispatchGroup.enter()
            database.fetchAllRecordZones { zones, error in
                defer {
                    dispatchGroup.leave()
                }
                
                if let error = error {
                    failure = error
                    return
                }
                guard let zones = zones else {
                    failure = Error.noZones(container)
                    return
                }
                
                // The true predicate represents a query for all records.
                let alwaysTrue = NSPredicate(value: true)
                for zone in zones {
                    for recordType in recordTypes {
                        dispatchGroup.enter()
                        let query = CKQuery(recordType: recordType, predicate: alwaysTrue)
                        database.allRecords(forQuery: query, inZoneWith: zone.zoneID, completion: { records, error in
                            defer {
                                dispatchGroup.leave()
                            }
                            
                            if let error = error {
                                failure = error
                                return
                            }
                            
                            let records = records ?? []
                            result[container, default: [:]][recordType] = records
                        })
                    }
                }
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) {
            if let error = failure {
                completion(Result<T.Result>.failure(error))
            } else {
                transformer.transformData(result, withContainerNameMapping: self.containerNameMapping, completion: completion)
            }
        }
    }
    
    /// Delete user's private data.
    ///
    /// - Parameter completion: A closure that will be called upon completion.
    open func deleteData(_ completion: @escaping (Result<RecordsZoneIDsByContainer>) -> Void) {
        var failure: Swift.Error? = nil
        let dispatchGroup = DispatchGroup()
        let containers = self.metadata.keys
        var result: RecordsZoneIDsByContainer = [:]
        var zonesDeleted: [CKRecordZone.ID] = []
        
        for container in containers {
            guard failure == nil else {
                return
            }
            
            // User data should be stored in the private database.
            let database = container.privateCloudDatabase
            
            dispatchGroup.enter()
            database.fetchAllRecordZones { zones, error in
                defer {
                    dispatchGroup.leave()
                }
                
                if let error = error {
                    failure = error
                    return
                }
                guard let zones = zones else {
                    failure = Error.noZones(container)
                    return
                }
                
                let zoneIDs = zones.map { $0.zoneID }
                let deletionOperation = CKModifyRecordZonesOperation(recordZonesToSave: nil, recordZoneIDsToDelete: zoneIDs)
                
                dispatchGroup.enter()
                
                deletionOperation.perRecordZoneDeleteBlock = { zoneId, result in
                    switch result {
                    case .success(_):
                        zonesDeleted.append(zoneId)
                    case .failure(let error):
                        failure = error
                    }
                }
                
                deletionOperation.modifyRecordZonesResultBlock = { zoneResult in
                    defer {
                        dispatchGroup.leave()
                    }
                    switch zoneResult {
                    case .success(_):
                        let deletedZones = zonesDeleted
                        result[container] = deletedZones
                    case .failure(let error):
                        failure = error
                        return
                    }
                }
                
                database.add(deletionOperation)
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) {
            if let error = failure {
                completion(Result<RecordsZoneIDsByContainer>.failure(error))
            } else {
                completion(Result<RecordsZoneIDsByContainer>.success(result))
            }
        }
    }
    
}
