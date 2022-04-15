//
//  RealityKit-Audio-Loading.swift
//  RealityKit-Asset-Loading
//
//  Created by Grant Jarvis on 11/6/21.
//

import RealityKit
import Foundation
import Combine

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
                    shouldLoop: Bool) {
            self.resourceName = resourceName
            self.url = url
            self.inputMode = inputMode
            self.loadingStrategy = loadingStrategy
            self.shouldLoop = shouldLoop
        }
    }
    
    
    ///If an AudioFile's url is non-nil, it will be loaded from that url, otherwise it will be loaded from the resourceName and bundle provided.
    ///
    ///This function requires two or more audio files to load. If you would like to load one audio file, use `loadAudioAsync` instead.
     static func loadAudioFilesAsync(in bundle: Bundle? = nil,
                                     audioFiles: AudioFile...,
                                     completion: @escaping (_ audioFileResources: [AudioFileResource]) -> ()){
         assert(audioFiles.count > 1, "loadAudioFilesAsync must use 2 or more audio files. To load just one file, use loadAudioAsync() instead.")
         
         guard audioFiles.count > 1,
               let firstFile = audioFiles.first
         else {return}
          
         var anyPublisher: AnyPublisher<AudioFileResource, Error>? = nil
         var firstPublisher: LoadRequest<AudioFileResource>
         if let firstURL = firstFile.url {
             firstPublisher = AudioFileResource.loadAsync(contentsOf: firstURL, withName: firstFile.resourceName,  inputMode: firstFile.inputMode, loadingStrategy: firstFile.loadingStrategy, shouldLoop: firstFile.shouldLoop)
         } else {
             firstPublisher = AudioFileResource.loadAsync(named: firstFile.resourceName, in: bundle, inputMode: firstFile.inputMode, loadingStrategy: firstFile.loadingStrategy, shouldLoop: firstFile.shouldLoop)
         }

         for i in 1..<audioFiles.count {
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
                         return resource
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
                         return resource
                     }
                     .eraseToAnyPublisher()
             }
         }
         anyPublisher!
             .collect()
             .sink(receiveValue: { loadedEntities in
                 //The model loaded successfully.
                 //Now we can make use of it.
                 completion(loadedEntities)
                  
             }).store(in: &RKAssetLoader.cancellables)
     }
    
    
    static func loadAudioAsync(audioFile: AudioFile,
                                      in bundle: Bundle? = nil,
                                      completionHandler: @escaping (_ audioFileResource: AudioFileResource) -> ()){
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
                               completionHandler: @escaping (_ audioFileResource: AudioFileResource) -> ()) {
        let loadRequest = RKAssetLoader.makeLoadRequest(contentsOf: url,
                                                         withName: resourceName,
                                                         inputMode: inputMode,
                                                         loadingStrategy: loadingStrategy,
                                                         shouldLoop: shouldLoop)
         
        loadRequest
            .sink(receiveValue: { audioFileResource in
                completionHandler(audioFileResource)
                 
            }).store(in: &RKAssetLoader.cancellables)
        }
    
    ///Makes an Asynchronous load request with predefined presets.
    private static func makeLoadRequest(contentsOf url: URL,
                                withName resourceName: String? = nil,
                                inputMode: AudioResource.InputMode = .spatial,
                                loadingStrategy: AudioFileResource.LoadingStrategy = .preload,
                                shouldLoop: Bool = false) -> AnyPublisher<AudioFileResource, Error> {
            return AudioFileResource.loadAsync(contentsOf: url,
                                               withName: resourceName,
                                               inputMode: inputMode,
                                               loadingStrategy: loadingStrategy,
                                               shouldLoop: shouldLoop)
                .tryMap { resource in
                    return resource
                }
                .eraseToAnyPublisher()
    }
}
