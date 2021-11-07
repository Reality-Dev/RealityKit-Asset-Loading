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
    }
    
    ///If an AudioFile's url is non-nil, it will be loaded from that url, otherwise it will be loaded from the resourceName and bundle provided.
     static func loadAudioFilesAsync(in bundle: Bundle? = nil,
                                     audioFiles: AudioFile...,
                                     completion: @escaping (_ audioFileResources: [AudioFileResource]) -> ()){
         guard audioFiles.count > 1,
               let firstFile = audioFiles.first
         else {return}
         DispatchQueue.main.async {
             var cancellable: AnyCancellable? = nil
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
        
        DispatchQueue.main.async {
        _ = AudioFileResource.loadAsync(named: audioFile.resourceName,
                                    in: bundle,
                                    inputMode: audioFile.inputMode,
                                    loadingStrategy: audioFile.loadingStrategy,
                                    shouldLoop: audioFile.shouldLoop)
                .sink(
                    receiveCompletion: { completion in
                    print("Error loading audio")
                }, receiveValue: { audioFileResource in
                    completionHandler(audioFileResource)
                })
        }}
    
     private static func loadAudioAsync(contentsOf url: URL,
                               withName resourceName: String? = nil,
                               inputMode: AudioResource.InputMode = .spatial,
                               loadingStrategy: AudioFileResource.LoadingStrategy = .preload,
                               shouldLoop: Bool = false,
                               completionHandler: @escaping (_ audioFileResource: AudioFileResource) -> ()) {
        DispatchQueue.main.async {
        let loadRequest = RKAssetLoader.makeLoadRequest(contentsOf: url,
                                                         withName: resourceName,
                                                         inputMode: inputMode,
                                                         loadingStrategy: loadingStrategy,
                                                         shouldLoop: shouldLoop)
        var cancellable: AnyCancellable? = nil
        cancellable = loadRequest
            .sink(
                receiveCompletion: { completion in
                print("Error loading audio")
            }, receiveValue: { audioFileResource in
                completionHandler(audioFileResource)
                cancellable?.cancel()
            })
        }}
    
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
