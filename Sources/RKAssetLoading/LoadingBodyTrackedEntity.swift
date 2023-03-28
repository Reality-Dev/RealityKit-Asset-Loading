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
    public extension RKAssetLoader {
        /// Asynchronously loads the 3D character.
        ///
        /// Asynchronous loading prevents our app from freezing while waiting for the loading task to complete.
        /// See the example project in ARSUIViewBodyTrackedEntity for an example of how to use this.
        /// - Parameters:
        ///   - name: The name of the usdz file in the main bundle.
        ///   - completionHandler: Once the asset is done loading, the BodyTrackedEntity is passed in as a parameter to this closure.
        static func loadBodyTrackedEntityAsync(named name: String, completionHandler: @escaping ((_ character: BodyTrackedEntity) -> Void)) {
            Entity.loadBodyTrackedAsync(named: name).sink(
                receiveValue: { bodyTrackedEntity in
                    completionHandler(bodyTrackedEntity)
                }).store(in: &RKAssetLoader.cancellables)
        }

        /// Loads a body-tracked entity from a file URL asynchronously.
        /// - Parameters:
        ///   - url: A file URL representing the file to load.
        ///   - resourceName: A unique name to assign to the loaded resource, for use in network synchronization.
        ///   - completionHandler: Once the asset is done loading, the BodyTrackedEntity is passed in as a parameter to this closure.
        static func loadBodyTrackedEntityAsync(contentsOf url: URL, withName resourceName: String? = nil, completionHandler: @escaping ((_ character: BodyTrackedEntity) -> Void)) {
            guard FileManager.default.fileExists(atPath: url.path) else {
                print("No file exists at path \(url.path)")
                return
            }
            Entity.loadBodyTrackedAsync(contentsOf: url, withName: resourceName)
                .sink(receiveValue: { bodyTrackedEntity in
                    completionHandler(bodyTrackedEntity)
                }).store(in: &RKAssetLoader.cancellables)
        }
    }
#endif
