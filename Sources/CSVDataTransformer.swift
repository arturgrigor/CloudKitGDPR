//
//  CSVDataTransformer.swift
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
    
/// CSV data transformer.
/// - Note: This data transformer will give you a list of CSV files.
open class CSVDataTransformer: DataTransformer {
    public typealias FileName = String
    public typealias FileContents = String
    public typealias Result = [FileName: FileContents]
    
    // MARK: - Properties -
    
    /// Dispatch queue.
    public let dispatchQueue: DispatchQueue
    
    // MARK: - Initialization -
    
    /// Default initialization
    ///
    /// - Parameter dispatchQueue: Dispatch queue.
    public init(dispatchQueue: DispatchQueue) {
        self.dispatchQueue = dispatchQueue
    }
    
    // MARK: - Constructors -
    
    /// Default instance.
    public static let `default` = CSVDataTransformer(dispatchQueue: DispatchQueue(label: "GDPR.CSVExporter"))
    
    // MARK: - GDPRExporter Methods -
    
    /// Transform data.
    ///
    /// - Parameters:
    ///   - data: Input data.
    ///   - containerNameMapping: Container name mapping.
    ///   - completion: A closure that will be called upon completion.
    open func transformData(_ data: GDPR.RecordsByRecordTypeByContainer, withContainerNameMapping containerNameMapping: GDPR.ContainerNameMapping, completion: @escaping (GDPR.Result<Result>) -> Void) {
        self.dispatchQueue.async {
            var result: Result = [:]
            for (container, recordsByRecordType) in data {
                for (recordType, records) in recordsByRecordType {
                    var csv = ""
                    
                    /*
                     `CKRecord.allKeys` returns only the keys for which the record has any data so we'll
                     iterate through all records in order to build the header.
                     */
                    var columns: Set<String> = []
                    records.forEach {
                        columns.formUnion($0.allKeys())
                    }
                    
                    // Header
                    csv += columns.map({ "\"\($0)\"" }).joined(separator: ",") + "\n"
                    
                    // Data
                    records.map({
                        let header = Array(columns)
                        var result = Array<String>(repeating: "", count: columns.count)
                        for key in $0.allKeys() {
                            if let position = header.firstIndex(of: key) {
                                result[position] = "\"\($0[key]?.description ?? "")\""
                            }
                        }
                        return result.joined(separator: ",") + "\n"
                    }).forEach({
                        csv += $0
                    })
                    
                    let containerName = containerNameMapping[container] ?? UUID().uuidString
                    result["\(containerName)_\(recordType).csv"] = csv
                }
            }
            
            // Finish
            DispatchQueue.main.async {
                completion(GDPR.Result<Result>.success(result))
            }
        }
    }
    
}
