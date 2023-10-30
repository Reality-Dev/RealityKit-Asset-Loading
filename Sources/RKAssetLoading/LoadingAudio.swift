//
//  RealityKit-Audio-Loading.swift
//  RealityKit-Asset-Loading
//
//  Created by Grant Jarvis on 11/6/21.
//

import Combine
import Foundation
import RealityKit

// MARK: - Async-Await
@available(iOS 15.0, *)
public extension RKAssetLoader {
    @MainActor static func loadAudioAsync(audioFile: AudioFile) async throws -> AudioFileResource {
        return try await loadAudioAsync(audioFile: audioFile, in: nil)
    }
    
    @MainActor static func loadAudioAsync(audioFile: AudioFile,
                               in bundle: Bundle? = nil) async throws -> AudioFileResource {
        if let url = audioFile.url {
            guard FileManager.default.fileExists(atPath: url.path) else {
                print("No file exists at path \(url.path)")
                throw AsyncError.finishedWithoutValue
            }
            return try await AudioFileResource.loadAsync(contentsOf: url,
                                                         withName: audioFile.resourceName,
                                                         inputMode: audioFile.inputMode,
                                                         loadingStrategy: audioFile.loadingStrategy,
                                                         shouldLoop: audioFile.shouldLoop).eraseToAnyPublisher().async()
        }
        return try await AudioFileResource.loadAsync(named: audioFile.resourceName,
                                    in: bundle,
                                    inputMode: audioFile.inputMode,
                                    loadingStrategy: audioFile.loadingStrategy,
                                    shouldLoop: audioFile.shouldLoop).eraseToAnyPublisher().async()
    }
    
    //ARRAY VERSION
    /// If an AudioFile's url is non-nil, it will be loaded from that url, otherwise it will be loaded from the resourceName and the main bundle.
    @MainActor static func loadAudioFilesAsync(audioFiles: [AudioFile]) async throws -> [AudioFileResource] {
        
        var loadedResources: [AudioFileResource] = []
        
        try await withThrowingTaskGroup(of: AudioFileResource.self) { group in
            for audioFile in audioFiles {
                group.addTask {
                    return try await loadAudioAsync(audioFile: audioFile)
                }
                
                for try await result in group {
                    loadedResources.append(result)
                }
            }
        }
        return loadedResources
    }
}



// MARK: - Completion Closures
public extension RKAssetLoader {
    struct AudioFile {
        var resourceName: String
        var url: URL?
        var inputMode: AudioResource.InputMode = .spatial
        var loadingStrategy: AudioFileResource.LoadingStrategy = .preload
        var shouldLoop: Bool
        
        public init(resourceName: String,
                    url: URL? = nil,
                    inputMode: AudioResource.InputMode = .spatial,
                    loadingStrategy: AudioFileResource.LoadingStrategy = .preload,
                    shouldLoop: Bool)
        {
            self.resourceName = resourceName
            self.url = url
            self.inputMode = inputMode
            self.loadingStrategy = loadingStrategy
            self.shouldLoop = shouldLoop
        }
        
        // If an AudioFile's url is non-nil, it will be loaded from that url, otherwise it will be loaded from the resourceName and bundle provided.
        func publisher(bundle: Bundle? = nil) -> LoadRequest<AudioFileResource> {
            if let url = url {
                return AudioFileResource.loadAsync(contentsOf: url,
                                                   withName: resourceName,
                                                   inputMode: inputMode,
                                                   loadingStrategy: loadingStrategy, shouldLoop: shouldLoop)
            } else {
                return AudioFileResource.loadAsync(named: resourceName, in: bundle, inputMode: inputMode, loadingStrategy: loadingStrategy, shouldLoop: shouldLoop)
            }
        }
    }

    /// If an AudioFile's url is non-nil, it will be loaded from that url, otherwise it will be loaded from the resourceName and bundle provided.
    ///
    /// This function requires two or more audio files to load. If you would like to load one audio file, use `loadAudioAsync` instead.
    static func loadAudioFilesAsync(in bundle: Bundle? = nil,
                                    audioFiles: [AudioFile],
                                    errorHandler: RKErrorHandler? = nil,
                                    completion: @escaping RKCompletionHandler<[AudioFileResource]>)
    {
        let loadPublishers = audioFiles.map{$0.publisher(bundle: bundle)}
        
        loadMany(requests: loadPublishers,
                 completion: completion,
                 errorHandler: errorHandler)
    }

    static func loadAudioAsync(audioFile: AudioFile,
                               in bundle: Bundle? = nil,
                               errorHandler: RKErrorHandler? = nil,
                               completion: @escaping RKCompletionHandler<AudioFileResource>)
    {
        if let url = audioFile.url {
            guard FileManager.default.fileExists(atPath: url.path) else {
                print("No file exists at path \(url.path)")
                return
            }
            RKAssetLoader.loadAudioAsync(contentsOf: url,
                                         withName: audioFile.resourceName,
                                         inputMode: audioFile.inputMode,
                                         loadingStrategy: audioFile.loadingStrategy,
                                         shouldLoop: audioFile.shouldLoop,
                                         errorHandler: errorHandler,
                                         completion: completion)
        } else {
            
            AudioFileResource.loadAsync(named: audioFile.resourceName,
                                        in: bundle,
                                        inputMode: audioFile.inputMode,
                                        loadingStrategy: audioFile.loadingStrategy,
                                        shouldLoop: audioFile.shouldLoop)
            .sink(receiveValue: completion,
                  errorHandler: errorHandler
            ).store(in: &RKAssetLoader.cancellables)
        }
    }

    private static func loadAudioAsync(contentsOf url: URL,
                                       withName resourceName: String? = nil,
                                       inputMode: AudioResource.InputMode = .spatial,
                                       loadingStrategy: AudioFileResource.LoadingStrategy = .preload,
                                       shouldLoop: Bool = false,
                                       errorHandler: RKErrorHandler? = nil,
                                       completion: @escaping RKCompletionHandler<AudioFileResource>)
    {
        AudioFileResource.loadAsync(contentsOf: url,
                                           withName: resourceName,
                                           inputMode: inputMode,
                                           loadingStrategy: loadingStrategy,
                                           shouldLoop: shouldLoop)
        .sink(receiveValue: completion,
              errorHandler: errorHandler
        ).store(in: &RKAssetLoader.cancellables)
    }
}
