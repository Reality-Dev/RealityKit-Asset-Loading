//
//  RealityKitAssetLoader.swift
//  RealityKitAssetLoader
//
//  Created by Grant Jarvis.
//

import RealityKit
import Combine
import Foundation


public struct RKAssetLoader {

    
    ///This loads the entity asynchronously from a file. Uses asynchronous loading to avoid stalling the main thread and freezing frames.
    /// - Parameters:
    ///   - path: The URL of the file locally on disk.
    ///   - name: A unique name to assign to the loaded resource, for use in network synchronization.
    ///   - completion: A completion block that passes the loaded asset as a parameter. Access the prepared asset here.
    public static func loadEntityAsync(path: URL, named name: String? = nil, completion: @escaping ((Entity) -> Void)){
        DispatchQueue.main.async {
        guard FileManager.default.fileExists(atPath: path.path) else {
            print("No file exists at path \(path)")
            return
        }
        var cancellable: AnyCancellable? = nil
        cancellable = Entity.loadAsync(contentsOf: path, withName: name)
        
        //There was an error loading the model.
            .sink(receiveCompletion: { error in
                print("Unable to load the model")
                if let error = error as? Error {
                    print(error.localizedDescription)
                }
                cancellable?.cancel()
        //The model loaded successfully.
            }, receiveValue: { (loadedEntity: Entity) in
                //Now we can make use of it.
                completion(loadedEntity)
                cancellable?.cancel()
            })
        }
    }
    
    
    
    ///This loads the entity asynchronously from a file. Uses asynchronous loading to avoid stalling the main thread and freezing frames.
    /// - Parameters:
    ///   - name: The name of the file to load, OMITTING the file extension (which is ".usdz").
    ///   - bundle: The bundle containing the file. Use nil to search the app’s main bundle.
    ///   - completionHandler: A completion block that passes the loaded asset as a parameter. Access the prepared asset here.
    public static func loadEntityAsync(named name: String, in bundle: Bundle? = nil, completion: @escaping ((Entity) -> Void)){
            DispatchQueue.main.async {

            var cancellable: AnyCancellable? = nil
            cancellable = Entity.loadAsync(named: name, in: bundle)
            
            //There was an error loading the model.
                .sink(receiveCompletion: { error in
                    print("Unable to load the model")
                    if let error = error as? Error {
                        print(error.localizedDescription)
                    }
                    cancellable?.cancel()
            //The model loaded successfully.
                }, receiveValue: { (loadedEntity: Entity) in
                    //Now we can make use of it.
                    completion(loadedEntity)
                    cancellable?.cancel()
                })
            }
    }
    
    

    
    
    
    
    /// For use with loading two or more entities at a time using the URL of the file on disk. You may load as many as you would like.
    /// - Parameters:
    ///   - entities: A variable number of tuples, each containing a url (on disk) and name (optional) of an entity to load.
    ///   - completion: Once the entities are done loading, they are passed as an array parameter into this closure.
    public static func loadEntitiesAsync(entities: (path: URL, name: String?)...,
                                         completion: @escaping (([Entity]) -> Void)){
        guard entities.count > 1,
              let firstEntity = entities.first
        else {return}
        guard FileManager.default.fileExists(atPath: firstEntity.path.path) else {
            print("No file exists at path \(firstEntity.path)")
            return
        }
        DispatchQueue.main.async {
            var cancellable: AnyCancellable? = nil
            var anyPublisher: AnyPublisher<Entity, Error>? = nil
            let firstPublisher = Entity.loadAsync(contentsOf: firstEntity.path, withName: firstEntity.name)
            for i in 1..<entities.count {
                
                let entity = entities[i]
                guard FileManager.default.fileExists(atPath: entity.path.path) else {
                    print("No file exists at path \(entity.path)")
                    continue
                }
                
                if i == 1 {
                    anyPublisher = firstPublisher.append(Entity.loadAsync(contentsOf: entity.path, withName: entity.name))
                        .tryMap { resource in
                            return resource
                        }
                        .eraseToAnyPublisher()
                } else {
                    anyPublisher = anyPublisher!.append(Entity.loadAsync(contentsOf: entity.path, withName: entity.name))
                        .tryMap { resource in
                            return resource
                        }
                        .eraseToAnyPublisher()
                }

            }
            cancellable = anyPublisher!
                .collect()
            //There was an error loading the model.
                .sink(receiveCompletion: { error in
                    print("Unable to load the model")
                    if let error = error as? Error {
                        print(error.localizedDescription)
                    }
                    cancellable?.cancel()
            //The model loaded successfully.
                }, receiveValue: { loadedEntities in
                    //Now we can make use of it.
                    completion(loadedEntities)
                    cancellable?.cancel()
                })
        }
    }
    
    /// For use with loading two or more entities at a time using the fileName and bundle. You may load as many as you would like. Entities must be in the same bundle.
    /// - Parameters:
    ///   - bundle: The bundle containing the file. Use nil or omit this parameter to search the app’s main bundle.
    ///   - entityNames: The file names of the entities to load, without the ".usdz" file extension.
    ///   - completion: Once the entities are done loading, they are passed as an array parameter into this closure.
    public static func loadEntitiesAsync(bundle: Bundle? = nil, entityNames: String...,
                                         completion: @escaping (([Entity]) -> Void)){
        guard entityNames.count > 1,
              let firstEntityName = entityNames.first
        else {return}
        DispatchQueue.main.async {
            var cancellable: AnyCancellable? = nil
            var anyPublisher: AnyPublisher<Entity, Error>? = nil
            let firstPublisher = Entity.loadAsync(named: firstEntityName, in: bundle)
            for i in 1..<entityNames.count {
                let entityName = entityNames[i]
                if i == 1 {
                    anyPublisher = firstPublisher.append(Entity.loadAsync(named: entityName, in: bundle))
                        .tryMap { resource in
                            return resource
                        }
                        .eraseToAnyPublisher()
                } else {
                    anyPublisher = anyPublisher!.append(Entity.loadAsync(named: entityName, in: bundle))
                        .tryMap { resource in
                            return resource
                        }
                        .eraseToAnyPublisher()
                }

            }
            cancellable = anyPublisher!
                .collect()
            //There was an error loading the model.
                .sink(receiveCompletion: { error in
                    print("Unable to load the model")
                    if let error = error as? Error {
                        print(error.localizedDescription)
                    }
                    cancellable?.cancel()
            //The model loaded successfully.
                }, receiveValue: { loadedEntities in
                    //Now we can make use of it.
                    completion(loadedEntities)
                    cancellable?.cancel()
                })
        }
    }
}
