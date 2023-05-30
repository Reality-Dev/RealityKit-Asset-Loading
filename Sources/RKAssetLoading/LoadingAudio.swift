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
    }
    
    //VARIADIC VERSION
    /// If an AudioFile's url is non-nil, it will be loaded from that url, otherwise it will be loaded from the resourceName and bundle provided.
    ///
    /// This function requires two or more audio files to load. If you would like to load one audio file, use `loadAudioAsync` instead.
    static func loadAudioFilesAsync(in bundle: Bundle? = nil,
                                    audioFiles: AudioFile...,
                                    completion: @escaping (_ audioFileResources: [AudioFileResource]) -> Void)
    {
        loadAudioFilesAsync(in: bundle, audioFiles: audioFiles, completion: completion)
    }

    //ARRAY VERSION
    /// If an AudioFile's url is non-nil, it will be loaded from that url, otherwise it will be loaded from the resourceName and bundle provided.
    ///
    /// This function requires two or more audio files to load. If you would like to load one audio file, use `loadAudioAsync` instead.
    static func loadAudioFilesAsync(in bundle: Bundle? = nil,
                                    audioFiles: [AudioFile],
                                    completion: @escaping (_ audioFileResources: [AudioFileResource]) -> Void)
    {
        assert(audioFiles.count > 1, "loadAudioFilesAsync must use 2 or more audio files. To load just one file, use loadAudioAsync() instead.")

        guard audioFiles.count > 1,
              let firstFile = audioFiles.first
        else { return }

        var anyPublisher: AnyPublisher<AudioFileResource, Error>?
        var firstPublisher: LoadRequest<AudioFileResource>
        if let firstURL = firstFile.url {
            firstPublisher = AudioFileResource.loadAsync(contentsOf: firstURL, withName: firstFile.resourceName, inputMode: firstFile.inputMode, loadingStrategy: firstFile.loadingStrategy, shouldLoop: firstFile.shouldLoop)
        } else {
            firstPublisher = AudioFileResource.loadAsync(named: firstFile.resourceName, in: bundle, inputMode: firstFile.inputMode, loadingStrategy: firstFile.loadingStrategy, shouldLoop: firstFile.shouldLoop)
        }

        for i in 1 ..< audioFiles.count {
            let audioFile = audioFiles[i]
            if i == 1 {
                var localPublisher: LoadRequest<AudioFileResource>
                if let fileURL = audioFile.url {
                    localPublisher = AudioFileResource.loadAsync(contentsOf: fileURL, withName: audioFile.resourceName, inputMode: audioFile.inputMode, loadingStrategy: audioFile.loadingStrategy, shouldLoop: audioFile.shouldLoop)
                } else {
                    localPublisher = AudioFileResource.loadAsync(named: audioFile.resourceName, in: bundle, inputMode: audioFile.inputMode, loadingStrategy: audioFile.loadingStrategy, shouldLoop: audioFile.shouldLoop)
                }
                anyPublisher = firstPublisher.append(localPublisher)
                    .tryMap { resource in
                        resource
                    }
                    .eraseToAnyPublisher()
            } else {
                var localPublisher: LoadRequest<AudioFileResource>
                if let fileURL = audioFile.url {
                    localPublisher = AudioFileResource.loadAsync(contentsOf: fileURL, withName: audioFile.resourceName, inputMode: audioFile.inputMode, loadingStrategy: audioFile.loadingStrategy, shouldLoop: audioFile.shouldLoop)
                } else {
                    localPublisher = AudioFileResource.loadAsync(named: audioFile.resourceName, in: bundle, inputMode: audioFile.inputMode, loadingStrategy: audioFile.loadingStrategy, shouldLoop: audioFile.shouldLoop)
                }
                anyPublisher = anyPublisher?.append(localPublisher)
                    .tryMap { resource in
                        resource
                    }
                    .eraseToAnyPublisher()
            }
        }
        anyPublisher!
            .collect()
            .sink(receiveValue: { loadedEntities in
                // The model loaded successfully.
                // Now we can make use of it.
                completion(loadedEntities)

            }).store(in: &RKAssetLoader.cancellables)
    }

    static func loadAudioAsync(audioFile: AudioFile,
                               in bundle: Bundle? = nil,
                               completionHandler: @escaping (_ audioFileResource: AudioFileResource) -> Void)
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
                                         completionHandler: completionHandler)
            return
        }

        AudioFileResource.loadAsync(named: audioFile.resourceName,
                                    in: bundle,
                                    inputMode: audioFile.inputMode,
                                    loadingStrategy: audioFile.loadingStrategy,
                                    shouldLoop: audioFile.shouldLoop)
            .sink(receiveValue: { audioFileResource in
                completionHandler(audioFileResource)
            }).store(in: &RKAssetLoader.cancellables)
    }

    private static func loadAudioAsync(contentsOf url: URL,
                                       withName resourceName: String? = nil,
                                       inputMode: AudioResource.InputMode = .spatial,
                                       loadingStrategy: AudioFileResource.LoadingStrategy = .preload,
                                       shouldLoop: Bool = false,
                                       completionHandler: @escaping (_ audioFileResource: AudioFileResource) -> Void)
    {
        AudioFileResource.loadAsync(contentsOf: url,
                                           withName: resourceName,
                                           inputMode: inputMode,
                                           loadingStrategy: loadingStrategy,
                                           shouldLoop: shouldLoop)
            .sink(receiveValue: { audioFileResource in
                completionHandler(audioFileResource)

            }).store(in: &RKAssetLoader.cancellables)
    }
}
