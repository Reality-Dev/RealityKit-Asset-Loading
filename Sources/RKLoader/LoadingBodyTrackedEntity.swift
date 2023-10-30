//
//  BodyTrackedEntity.swift
//  RealityKit-Asset-Loading
//
//  Created by Grant Jarvis on 11/6/21.
//

import Combine
import Foundation
import RealityKit


#if os(iOS)

// MARK: - Async-Await
@available(iOS 15.0, *)
public extension RKLoader {
    
    /// Asynchronously loads the 3D character.
    ///
    /// Asynchronous loading prevents our app from freezing while waiting for the loading task to complete.
    /// See the example project in ARSUIViewBodyTrackedEntity for an example of how to use this.
    /// - Parameters:
    ///   - name: The name of the usdz file in the main bundle.
    ///   - completion: Once the asset is done loading, the BodyTrackedEntity is passed in as a parameter to this closure.
    @MainActor static func loadBodyTrackedEntityAsync(named name: String) async throws -> BodyTrackedEntity {
        
        return try await Entity.loadBodyTrackedAsync(named: name).eraseToAnyPublisher().async()
    }
    
    /// Loads a body-tracked entity from a file URL asynchronously.
    /// - Parameters:
    ///   - url: A file URL representing the file to load.
    ///   - resourceName: A unique name to assign to the loaded resource, for use in network synchronization.
    ///   - completion: Once the asset is done loading, the BodyTrackedEntity is passed in as a parameter to this closure.
    static func loadBodyTrackedEntityAsync(contentsOf url: URL, withName resourceName: String? = nil) async throws -> BodyTrackedEntity {
        
        return try await Entity.loadBodyTrackedAsync(contentsOf: url, withName: resourceName).eraseToAnyPublisher().async()
    }
}

// MARK: - Completion Closures
    public extension RKLoader {
        /// Asynchronously loads the 3D character.
        ///
        /// Asynchronous loading prevents our app from freezing while waiting for the loading task to complete.
        /// See the example project in ARSUIViewBodyTrackedEntity for an example of how to use this.
        /// - Parameters:
        ///   - name: The name of the usdz file in the main bundle.
        ///   - completion: Once the asset is done loading, the BodyTrackedEntity is passed in as a parameter to this closure.
        static func loadBodyTrackedEntityAsync(named name: String,
                                               errorHandler: RKErrorHandler? = nil,
                                               completion: @escaping RKCompletionHandler<BodyTrackedEntity>) {
            Entity.loadBodyTrackedAsync(named: name)
                .sink(receiveValue: completion,
                      errorHandler: errorHandler
                ).store(in: &RKLoader.cancellables)
        }

        /// Loads a body-tracked entity from a file URL asynchronously.
        /// - Parameters:
        ///   - url: A file URL representing the file to load.
        ///   - resourceName: A unique name to assign to the loaded resource, for use in network synchronization.
        ///   - completion: Once the asset is done loading, the BodyTrackedEntity is passed in as a parameter to this closure.
        static func loadBodyTrackedEntityAsync(contentsOf url: URL, withName resourceName: String? = nil,
                                               errorHandler: RKErrorHandler? = nil,
                                               completion: @escaping RKCompletionHandler<BodyTrackedEntity>) {
            guard FileManager.default.fileExists(atPath: url.path) else {
                print("No file exists at path \(url.path)")
                return
            }
            Entity.loadBodyTrackedAsync(contentsOf: url, withName: resourceName)
                .sink(receiveValue: completion,
                      errorHandler: errorHandler
                ).store(in: &RKLoader.cancellables)
        }
    }

#endif
