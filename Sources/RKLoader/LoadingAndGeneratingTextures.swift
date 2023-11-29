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
public extension RKLoader {
    
    // - Generating or Loading Multiple -
    
    @MainActor static func generateTexturesAsync(textures: [TexDefFromCGImage]) async throws -> [TextureResource]
    {
        let tasks = textures.map { texture in
            { try await generateTextureAsync(from: texture.cgImage, withName: texture.resourceName, options: texture.createOptions)
            }
        }
            
        return try await loadMany(tasks: tasks)
    }
    
    @MainActor static func loadTexturesAsync(bundle: Bundle? = nil, textures: [TexDefFromName]) async throws -> [TextureResource]
    {
        let tasks = textures.map { texture in
            { try await loadTextureAsync(named: texture.resourceName, options: texture.createOptions)
            }
        }
            
        return try await loadMany(tasks: tasks)
    }
    
    @MainActor static func loadTexturesAsync(bundle: Bundle? = nil, textures: [TexDefFromURL]) async throws -> [TextureResource]
    {
        
        let tasks = textures.map { texture in
            { try await loadTextureAsync(contentsOf: texture.url, named: texture.resourceName, options: texture.createOptions)
            }
        }
            
        return try await loadMany(tasks: tasks)
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
public extension RKLoader {
    
    class TextureDefinition {
        
        var createOptions: TextureResource.CreateOptions = .init(semantic: nil)
        
        init(createOptions: TextureResource.CreateOptions?) {
            if let createOptions {
                self.createOptions = createOptions
            }
        }
    }
    
    class TexDefFromCGImage: TextureDefinition {
        
        var resourceName: String?
        
        var cgImage: CGImage
        
        public init(cgImage: CGImage,
             resourceName: String? = nil,
             createOptions: TextureResource.CreateOptions?) {
            self.resourceName = resourceName
            self.cgImage = cgImage
            super.init(createOptions: createOptions)
        }
    }
    
    class TexDefFromName: TextureDefinition {
        var resourceName: String
        
        public init(resourceName: String,
             createOptions: TextureResource.CreateOptions?) {
            self.resourceName = resourceName
            super.init(createOptions: createOptions)
        }
    }
    
    class TexDefFromURL: TexDefFromName {
        var url: URL
        
        public init(url: URL,
             resourceName: String,
                  createOptions: TextureResource.CreateOptions?) {
            self.url = url
            super.init(resourceName: resourceName,
                       createOptions: createOptions)
        }
    }
    
    // - Generating or Loading Multiple -
    
    static func generateTexturesAsync(bundle: Bundle? = nil, textures: [TexDefFromCGImage],
                                      errorHandler: RKErrorHandler? = nil,
                                      completion: @escaping RKCompletionHandler<[TextureResource]>)
    {
        let loadPublishers = textures.map{TextureResource.generateAsync(from: $0.cgImage,
                                                                        withName: $0.resourceName,
                                                                               options: $0.createOptions)}
        loadMany(requests: loadPublishers,
                 completion: completion,
                 errorHandler: errorHandler)
    }
    
    static func loadTexturesAsync(bundle: Bundle? = nil,
                                  textures: [TexDefFromName],
                                  errorHandler: RKErrorHandler? = nil,
                                  completion: @escaping RKCompletionHandler<[TextureResource]>)
    {
        let loadPublishers = textures.map{TextureResource.loadAsync(named: $0.resourceName,
                                                                            in: bundle,
                                                                    options: $0.createOptions)}
        
        loadMany(requests: loadPublishers,
                 completion: completion,
                 errorHandler: errorHandler)
    }
    
    static func loadTexturesAsync(bundle: Bundle? = nil,
                                  textures: [TexDefFromURL],
                                  errorHandler: RKErrorHandler? = nil,
                                  completion: @escaping RKCompletionHandler<[TextureResource]>)
    {
        let loadPublishers = textures.map{TextureResource.loadAsync(contentsOf: $0.url,
                                                                    withName: $0.resourceName,
                                                                    options: $0.createOptions)}
        
        loadMany(requests: loadPublishers,
                 completion: completion,
                 errorHandler: errorHandler)
    }
    
    
    // - Generating or Loading Singular -
    
    static func generateTextureAsync(from cgImage: CGImage,
                                     withName resourceName: String? = nil,
                                     options: TextureResource.CreateOptions = .init(semantic: .color),
                                     errorHandler: RKErrorHandler? = nil,
                                     completion: @escaping RKCompletionHandler<TextureResource>)
    {
        TextureResource.generateAsync(from: cgImage,
                                      withName: resourceName,
                                      options: options)
            .sinkAndStore(
                receiveValue: completion,
                errorHandler: errorHandler
            )
    }

    static func loadTextureAsync(named resourceName: String,
                                 in bundle: Bundle? = nil,
                                 options: TextureResource.CreateOptions = .init(semantic: .color),
                                 errorHandler: RKErrorHandler? = nil,
                                 completion: @escaping RKCompletionHandler<TextureResource>)
    {
        TextureResource.loadAsync(named: resourceName,
                                  in: bundle,
                                  options: options)
        .sinkAndStore(
            receiveValue: completion,
            errorHandler: errorHandler
        )
    }

    static func loadTextureAsync(contentsOf url: URL,
                                 named resourceName: String,
                                 options: TextureResource.CreateOptions = .init(semantic: .color),
                                 errorHandler: RKErrorHandler? = nil,
                                 completion: @escaping RKCompletionHandler<TextureResource>)
    {
        TextureResource.loadAsync(contentsOf: url,
                                  withName: resourceName,
                                  options: options)
        .sinkAndStore(
            receiveValue: completion,
            errorHandler: errorHandler
        )
    }
}
