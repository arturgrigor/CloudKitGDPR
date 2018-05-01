//
//  ZeroDataTransformer.swift
//  CloudKitGDPR
//
//  Created by Artur Grigor on 02.05.2018.
//  Copyright © 2018 Artur Grigor. All rights reserved.
//

import Foundation

//
//  # Class
//

/// Data transformer that doesn't do anything but returning the data as is.
open class ZeroDataTransformer: DataTransformer {
    public typealias Result = GDPR.RecordsByRecordTypeByContainer
    
    /// Transform data.
    ///
    /// - Parameters:
    ///   - data: Input data.
    ///   - containerNameMapping: Container name mapping.
    ///   - completion: A closure that will be called upon completion.
    open func transformData(_ data: GDPR.RecordsByRecordTypeByContainer, withContainerNameMapping containerNameMapping: GDPR.ContainerNameMapping, completion: @escaping (GDPR.Result<Result>) -> Void) {
        completion(GDPR.Result<Result>.success(data))
    }
    
}
