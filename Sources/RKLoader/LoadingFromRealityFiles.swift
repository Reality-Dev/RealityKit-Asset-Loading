//
//  LoadingFromRealityFiles.swift
//  RealityKit-Asset-Loading
//
//  Created by Grant Jarvis on 11/6/21.
//

import Combine
import Foundation
import RealityKit

// MARK: - Async-Await
@available(iOS 15.0, *)
public extension RKLoader {
    @MainActor static func loadRealitySceneAsync(filename: String,
                                      bundle: Bundle? = nil) async throws -> (Entity & HasAnchoring)
    {
        return try await Entity.loadAnchorAsync(named: filename, in: bundle).eraseToAnyPublisher().async()
    }
    
    static func loadRealitySceneAsync(realityFileSceneURL: URL) async throws -> (Entity & HasAnchoring)
    {
        guard FileManager.default.fileExists(atPath: realityFileSceneURL.path) else {
            print("No file exists at path \(realityFileSceneURL.path)")
            throw URLError(.fileDoesNotExist)
        }
        return try await Entity.loadAnchorAsync(contentsOf: realityFileSceneURL).eraseToAnyPublisher().async()
    }
    
    /// Use this function to access a particular scene from within a .reality file.
    static func loadRealitySceneAsync(filename: String,
                                      fileExtension: String = "reality",
                                      sceneName: String) async throws -> (Entity & HasAnchoring)
    {
        guard let realityFileSceneURL = RKLoader.createRealityURL(filename: filename, fileExtension: fileExtension, sceneName: sceneName) else {
            print("Error: Unable to find specified file in application bundle")
            throw URLError(.badURL)
        }
        
        return try await loadRealitySceneAsync(realityFileSceneURL: realityFileSceneURL)
    }
}

// MARK: - Completion Closures
public extension RKLoader {
    
    // This code came from:
    // https://developer.apple.com/documentation/realitykit/creating_3d_content_with_reality_composer/loading_reality_composer_files_manually_without_generated_code
    static func createRealityURL(filename: String,
                                 fileExtension: String,
                                 sceneName: String) -> URL?
    {
        // Create a URL that points to the specified Reality file.
        guard let realityFileURL = Bundle.main.url(forResource: filename,
                                                   withExtension: fileExtension)
        else {
            print("Error finding Reality file \(filename).\(fileExtension)")
            return nil
        }

        // Append the scene name to the URL to point to
        // a single scene within the file.
        let realityFileSceneURL = realityFileURL.appendingPathComponent(sceneName,
                                                                        isDirectory: false)
        return realityFileSceneURL
    }

    static func loadRealitySceneAsync(filename: String,
                                      bundle: Bundle? = nil,
                                      errorHandler: RKErrorHandler? = nil,
                                      completion: @escaping RKCompletionHandler<Entity & HasAnchoring>)
    {
        Entity.loadAnchorAsync(named: filename, in: bundle)
            .sinkAndStore(receiveValue: completion,
                  errorHandler: errorHandler
            )
    }

    /// Use this function to access a particular scene from within a .reality file.
    static func loadRealitySceneAsync(filename: String,
                                      fileExtension: String = "reality",
                                      sceneName: String,
                                      errorHandler: RKErrorHandler? = nil,
                                      completion: @escaping RKCompletionHandler<Entity & HasAnchoring>)
    {
        guard let realityFileSceneURL = RKLoader.createRealityURL(filename: filename, fileExtension: fileExtension, sceneName: sceneName) else {
            print("Error: Unable to find specified file in application bundle")
            return
        }
        loadRealitySceneAsync(realityFileSceneURL: realityFileSceneURL,
                              errorHandler: errorHandler,
                              completion: completion)
    }

    static func loadRealitySceneAsync(realityFileSceneURL: URL,
                                      errorHandler: RKErrorHandler? = nil,
                                      completion: @escaping RKCompletionHandler<Entity & HasAnchoring>)
    {
        guard FileManager.default.fileExists(atPath: realityFileSceneURL.path) else {
            print("No file exists at path \(realityFileSceneURL.path)")
            return
        }
        Entity.loadAnchorAsync(contentsOf: realityFileSceneURL)
            .sinkAndStore(receiveValue: completion,
                  errorHandler: errorHandler
            )
    }
}
