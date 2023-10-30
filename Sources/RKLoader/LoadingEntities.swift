//
//  RealityKitAssetLoader.swift
//  RealityKitAssetLoader
//
//  Created by Grant Jarvis.
//

import Combine
import Foundation
import RealityKit

public enum RKLoader {
    static var cancellables = Set<AnyCancellable>()
    
}

@available(iOS 15.0, *)
public extension RKLoader {
    // MARK: - Async-Await
    
    /// This loads the entity asynchronously from a file. Uses asynchronous loading to avoid stalling the main thread and freezing frames.
    /// - Parameters:
    ///   - path: The URL of the file locally on disk.
    ///   - name: A unique name to assign to the loaded resource, for use in network synchronization.
    ///   - completion: A completion block that passes the loaded asset as a parameter. Access the prepared asset here.
    static func loadEntityAsync(path: URL, named name: String? = nil) async throws -> Entity {
        guard FileManager.default.fileExists(atPath: path.path) else {
            print("No file exists at path \(path)")
            throw URLError(.fileDoesNotExist)
        }
        
        return try await Entity.loadAsync(contentsOf: path, withName: name).eraseToAnyPublisher().async()
    }
    
    @MainActor private static func loadEntityAsync(named name: String) async throws -> Entity {
        return try await loadEntityAsync(named: name, in: nil)
    }
    
    /// This loads the entity asynchronously from a file. Uses asynchronous loading to avoid stalling the main thread and freezing frames.
    /// - Parameters:
    ///   - name: The name of the file to load, OMITTING the file extension (which is ".usdz").
    ///   - bundle: The bundle containing the file. Use nil to search the app’s main bundle.
    ///   - completion: A completion block that passes the loaded asset as a parameter. Access the prepared asset here.
    @MainActor static func loadEntityAsync(named name: String, in bundle: Bundle? = nil) async throws -> Entity {
        return try await Entity.loadAsync(named: name, in: bundle).eraseToAnyPublisher().async()
    }
    
    /// For use with loading two or more entities at a time using the fileName and bundle. You may load as many as you would like. Entities must be in the same bundle.
    /// - Parameters:
    ///   - bundle: The bundle containing the file. Use nil or omit this parameter to search the app’s main bundle.
    ///   - entityNames: The file names of the entities to load, without the ".usdz" file extension.
    ///   - completion: Once the entities are done loading, they are passed as an array parameter into this closure.
    @MainActor static func loadEntitiesAsync(bundle: Bundle? = nil,
                                             entityNames: [String]) async throws -> [Entity]
    {
        var loadedEntities: [Entity] = []
        
        try await withThrowingTaskGroup(of: Entity.self) { group in
            for entityName in entityNames {
                group.addTask {
                    return try await loadEntityAsync(named: entityName)
                }
                
                for try await result in group {
                    loadedEntities.append(result)
                }
            }
        }
        return loadedEntities
    }
    
    /// For use with loading two or more entities at a time using the URL of the file on disk. You may load as many as you would like.
    /// - Parameters:
    ///   - entities: A variable number of tuples, each containing a url (on disk) and name (optional) of an entity to load.
    ///   - completion: Once the entities are done loading, they are passed as an array parameter into this closure.
    @MainActor static func loadEntitiesAsync(entities: [(path: URL, name: String?)]) async throws -> [Entity]
    {
        var loadedEntities: [Entity] = []
        
        try await withThrowingTaskGroup(of: Entity.self) { group in
            for entityData in entities {
                group.addTask {
                    return try await loadEntityAsync(path: entityData.path, named: entityData.name)
                }
                
                for try await result in group {
                    loadedEntities.append(result)
                }
            }
        }
        return loadedEntities
    }
}


// MARK: - Completion Closures
public extension RKLoader {
    
    /// This loads the entity asynchronously from a file. Uses asynchronous loading to avoid stalling the main thread and freezing frames.
    /// - Parameters:
    ///   - path: The URL of the file locally on disk.
    ///   - name: A unique name to assign to the loaded resource, for use in network synchronization.
    ///   - completion: A completion block that passes the loaded asset as a parameter. Access the prepared asset here.
    static func loadEntityAsync(path: URL, named name: String? = nil,
                                errorHandler: RKErrorHandler? = nil,
                                completion: @escaping RKCompletionHandler<Entity>) {
        guard FileManager.default.fileExists(atPath: path.path) else {
            print("No file exists at path \(path)")
            return
        }

        Entity.loadAsync(contentsOf: path, withName: name)
            .sink(receiveValue: completion,
                  errorHandler: errorHandler
            ).store(in: &RKLoader.cancellables)
    }

    /// This loads the entity asynchronously from a file. Uses asynchronous loading to avoid stalling the main thread and freezing frames.
    /// - Parameters:
    ///   - name: The name of the file to load, OMITTING the file extension (which is ".usdz").
    ///   - bundle: The bundle containing the file. Use nil to search the app’s main bundle.
    ///   - completion: A completion block that passes the loaded asset as a parameter. Access the prepared asset here.
    static func loadEntityAsync(named name: String,
                                in bundle: Bundle? = nil,
                                errorHandler: RKErrorHandler? = nil,
                                completion: @escaping RKCompletionHandler<Entity>) {
        Entity.loadAsync(named: name, in: bundle)
            .sink(receiveValue: completion,
                  errorHandler: errorHandler
            ).store(in: &RKLoader.cancellables)
    }

    /// For use with loading two or more entities at a time using the URL of the file on disk. You may load as many as you would like.
    /// - Parameters:
    ///   - entities: A variable number of tuples, each containing a url (on disk) and name (optional) of an entity to load.
    ///   - completion: Once the entities are done loading, they are passed as an array parameter into this closure.
    static func loadEntitiesAsync(entities: [(path: URL, name: String?)],
                                  errorHandler: RKErrorHandler? = nil,
                                  completion: @escaping RKCompletionHandler<[Entity]>)
                                  
    {
        let loadPublishers = entities.map{Entity.loadAsync(contentsOf: $0.path, withName: $0.name)}
        
        loadMany(requests: loadPublishers,
                 completion: completion,
                 errorHandler: errorHandler)
    }

    /// For use with loading two or more entities at a time using the fileName and bundle. You may load as many as you would like. Entities must be in the same bundle.
    /// - Parameters:
    ///   - bundle: The bundle containing the file. Use nil or omit this parameter to search the app’s main bundle.
    ///   - entityNames: The file names of the entities to load, without the ".usdz" file extension.
    ///   - completion: Once the entities are done loading, they are passed as an array parameter into this closure.
    static func loadEntitiesAsync(bundle: Bundle? = nil,
                                  entityNames: [String],
                                  errorHandler: RKErrorHandler? = nil,
                                  completion: @escaping RKCompletionHandler<[Entity]>)
    {
        let loadPublishers = entityNames.map{Entity.loadAsync(named: $0, in: bundle)}
        
        loadMany(requests: loadPublishers,
                 completion: completion,
                 errorHandler: errorHandler)
    }
}
