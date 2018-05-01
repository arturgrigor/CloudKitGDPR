//
//  DataTransformer.swift
//  CloudKitGDPR
//
//  Created by Artur Grigor on 02.05.2018.
//  Copyright © 2018 Artur Grigor. All rights reserved.
//

import Foundation

//
//  # Protocol
//

public protocol DataTransformer {
    associatedtype Result
    
    /// Transform data.
    ///
    /// - Parameters:
    ///   - data: Input data.
    ///   - containerNameMapping: Container name mapping.
    ///   - completion: A closure that will be called upon completion.
    func transformData(_ data: GDPR.RecordsByRecordTypeByContainer, withContainerNameMapping containerNameMapping: GDPR.ContainerNameMapping, completion: @escaping (GDPR.Result<Result>) -> Void)
}
