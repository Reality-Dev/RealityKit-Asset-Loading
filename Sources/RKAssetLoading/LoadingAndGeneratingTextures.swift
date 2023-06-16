//
//  LoadingAndGeneratingTextures.swift
//  RealityKit-Asset-Loading
//
//  Created by Grant Jarvis on 11/19/21.
//

import Combine
import CoreGraphics
import Foundation
import RealityKit

// MARK: - Async-Await
@available(iOS 15.0, macOS 12.0, *)
public extension RKAssetLoader {
    
    // - Generating or Loading Multiple -
    
    @MainActor static func generateTexturesAsync(bundle: Bundle? = nil, textures: [TexDefFromCGImage]) async throws -> [TextureResource]
    {
        var loadedEntities: [TextureResource] = []
        
        try await withThrowingTaskGroup(of: TextureResource.self) { group in
            for texture in textures {
                group.addTask {
                    return try await generateTextureAsync(from: texture.cgImage, withName: texture.resourceName, options: texture.createOptions)
                }
                
                for try await result in group {
                    loadedEntities.append(result)
                }
            }
        }
        return loadedEntities
    }
    
    @MainActor static func loadTexturesAsync(bundle: Bundle? = nil, textures: [TexDefFromName]) async throws -> [TextureResource]
    {
        var loadedEntities: [TextureResource] = []
        
        try await withThrowingTaskGroup(of: TextureResource.self) { group in
            for texture in textures {
                group.addTask {
                    return try await loadTextureAsync(named: texture.resourceName, options: texture.createOptions)
                }
                
                for try await result in group {
                    loadedEntities.append(result)
                }
            }
        }
        return loadedEntities
    }
    
    @MainActor static func loadTexturesAsync(bundle: Bundle? = nil, textures: [TexDefFromURL]) async throws -> [TextureResource]
    {
        var loadedEntities: [TextureResource] = []
        
        try await withThrowingTaskGroup(of: TextureResource.self) { group in
            for texture in textures {
                group.addTask {
                    return try await loadTextureAsync(contentsOf: texture.url, named: texture.resourceName, options: texture.createOptions)
                }
                
                for try await result in group {
                    loadedEntities.append(result)
                }
            }
        }
        return loadedEntities
    }
    
    // - Generating or Loading Singluar -
    
    static func generateTextureAsync(from cgImage: CGImage,
                                     withName resourceName: String? = nil,
                                     options: TextureResource.CreateOptions = .init(semantic: .color)) async throws -> TextureResource {
        return try await TextureResource.generateAsync(from: cgImage,
                                      withName: resourceName,
                                      options: options).eraseToAnyPublisher().async()
        
    }
    
    ///Loads a texture resource by name asynchronously.
    @MainActor static func loadTextureAsync(named resourceName: String,
                                 options: TextureResource.CreateOptions = .init(semantic: .color)) async throws -> TextureResource {
        return try await TextureResource.loadAsync(named: resourceName,
                                  options: options).eraseToAnyPublisher().async()
    }
    

    static func loadTextureAsync(contentsOf url: URL,
    named resourceName: String,
    options: TextureResource.CreateOptions = .init(semantic: .color)) async throws -> TextureResource {

        return try await TextureResource.loadAsync(contentsOf: url,
                                                   withName: resourceName,
                                                   options: options).eraseToAnyPublisher().async()
    }
}

// MARK: - Completion Closures
@available(macOS 12.0, iOS 15.0, *)
public extension RKAssetLoader {
    
    class TextureDefinition {
        
        var createOptions: TextureResource.CreateOptions = .init(semantic: .color)
        
        init(createOptions: TextureResource.CreateOptions?) {
            if let createOptions {
                self.createOptions = createOptions
            }
        }
    }
    
    class TexDefFromCGImage: TextureDefinition {
        
        var resourceName: String?
        
        var cgImage: CGImage
        
        init(cgImage: CGImage,
             resourceName: String? = nil,
             createOptions: TextureResource.CreateOptions?) {
            self.resourceName = resourceName
            self.cgImage = cgImage
            super.init(createOptions: createOptions)
        }
    }
    
    class TexDefFromName: TextureDefinition {
        var resourceName: String
        
        init(resourceName: String,
             createOptions: TextureResource.CreateOptions?) {
            self.resourceName = resourceName
            super.init(createOptions: createOptions)
        }
    }
    
    class TexDefFromURL: TexDefFromName {
        var url: URL
        
        init(url: URL,
             resourceName: String,
                  createOptions: TextureResource.CreateOptions?) {
            self.url = url
            super.init(resourceName: resourceName,
                       createOptions: createOptions)
        }
    }
    
    // - Generating or Loading Multiple -
    
    static func generateTexturesAsync(bundle: Bundle? = nil, textures: [TexDefFromCGImage],
                                  completion: @escaping (([TextureResource]) -> Void))
    {
        let loadPublishers = textures.map{TextureResource.generateAsync(from: $0.cgImage,
                                                                        withName: $0.resourceName,
                                                                               options: $0.createOptions)}
        
        loadMany(requests: loadPublishers, completion: completion)
    }
    
    static func loadTexturesAsync(bundle: Bundle? = nil,
                                  textures: [TexDefFromName],
                                  completion: @escaping (([TextureResource]) -> Void))
    {
        let loadPublishers = textures.map{TextureResource.loadAsync(named: $0.resourceName,
                                                                            in: bundle,
                                                                    options: $0.createOptions)}
        
        loadMany(requests: loadPublishers, completion: completion)
    }
    
    static func loadTexturesAsync(bundle: Bundle? = nil,
                                  textures: [TexDefFromURL],
                                  completion: @escaping (([TextureResource]) -> Void))
    {
        let loadPublishers = textures.map{TextureResource.loadAsync(contentsOf: $0.url,
                                                                    withName: $0.resourceName,
                                                                    options: $0.createOptions)}
        
        loadMany(requests: loadPublishers, completion: completion)
    }
    
    
    // - Generating or Loading Singular -
    
    static func generateTextureAsync(from cgImage: CGImage,
                                     withName resourceName: String? = nil,
                                     options: TextureResource.CreateOptions = .init(semantic: .color),
                                     completionHandler: @escaping ((_ texture: TextureResource) -> Void))
    {
        TextureResource.generateAsync(from: cgImage,
                                      withName: resourceName,
                                      options: options)
            .sink(receiveValue: { texture in
                completionHandler(texture)

            }).store(in: &RKAssetLoader.cancellables)
    }

    static func loadTextureAsync(named resourceName: String,
                                 in bundle: Bundle? = nil,
                                 options: TextureResource.CreateOptions = .init(semantic: .color),
                                 completionHandler: @escaping ((_ texture: TextureResource) -> Void))
    {
        TextureResource.loadAsync(named: resourceName,
                                  in: bundle,
                                  options: options)
            .sink(receiveValue: { texture in
                completionHandler(texture)

            }).store(in: &RKAssetLoader.cancellables)
    }

    static func loadTextureAsync(contentsOf url: URL,
                                 named resourceName: String,
                                 options: TextureResource.CreateOptions = .init(semantic: .color),
                                 completionHandler: @escaping ((_ texture: TextureResource) -> Void))
    {
        TextureResource.loadAsync(contentsOf: url,
                                  withName: resourceName,
                                  options: options)
            .sink(receiveValue: { texture in
                completionHandler(texture)

            }).store(in: &RKAssetLoader.cancellables)
    }
}
