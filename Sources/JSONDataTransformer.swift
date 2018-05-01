//
//  JSONDataTransformer.swift
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
    
/// JSON data transformer.
/// - Note: This data transformer will give you an array of CSV file contents.
open class JSONDataTransformer: DataTransformer {
    public typealias FileName = String
    public typealias FileContents = String
    public typealias Result = [FileName: FileContents]
    
    // MARK: - Properties -
    
    /// Dispatch queue.
    open let dispatchQueue: DispatchQueue
    
    // MARK: - Initialization -
    
    /// Default initialization
    ///
    /// - Parameter dispatchQueue: Dispatch queue.
    public init(dispatchQueue: DispatchQueue) {
        self.dispatchQueue = dispatchQueue
    }
    
    // MARK: - Constructors -
    
    /// Default instance.
    open static let `default` = JSONDataTransformer(dispatchQueue: DispatchQueue(label: "GDPR.JSONExporter"))
    
    // MARK: - GDPRExporter Methods -
    
    /// Transform data.
    ///
    /// - Parameters:
    ///   - data: Input data.
    ///   - containerNameMapping: Container name mapping.
    ///   - completion: A closure that will be called upon completion.
    open func transformData(_ data: GDPR.RecordsByRecordTypeByContainer, withContainerNameMapping containerNameMapping: GDPR.ContainerNameMapping, completion: @escaping (GDPR.Result<Result>) -> Void) {
        self.dispatchQueue.async {
            let ret: GDPR.Result<Result>
            do {
                var result: Result = [:]
                for (container, recordsByRecordType) in data {
                    for (recordType, records) in recordsByRecordType {
                        let rows: [[String: String]] = records.map({
                            var result: [String: String] = [:]
                            for key in $0.allKeys() {
                                result[key] = $0[key]?.description ?? ""
                            }
                            return result
                        })
                        
                        let jsonData = try JSONSerialization.data(withJSONObject: rows, options: JSONSerialization.WritingOptions.prettyPrinted)
                        let jsonString = String(data: jsonData, encoding: .utf8)
                        
                        let containerName = containerNameMapping[container] ?? UUID().uuidString
                        result["\(containerName)_\(recordType).json"] = jsonString
                    }
                }
                
                ret = GDPR.Result<Result>.success(result)
            } catch {
                ret = GDPR.Result<Result>.failure(error)
            }
            
            defer {
                DispatchQueue.main.async {
                    completion(ret)
                }
            }
        }
    }
    
}
