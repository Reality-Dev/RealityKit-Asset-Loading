//
//  LoadingFromRealityFiles.swift
//  RealityKit-Asset-Loading
//
//  Created by Grant Jarvis on 11/6/21.
//

import RealityKit
import Combine
import UIKit

public extension RKAssetLoader {

    //This code came from:
    //https://developer.apple.com/documentation/realitykit/creating_3d_content_with_reality_composer/loading_reality_composer_files_manually_without_generated_code
     static func createRealityURL(filename: String,
                          fileExtension: String,
                          sceneName:String) -> URL? {
        // Create a URL that points to the specified Reality file.
        guard let realityFileURL = Bundle.main.url(forResource: filename,
                                                   withExtension: fileExtension) else {
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
                                        completion: @escaping (Swift.Result<(Entity & HasAnchoring)?, Swift.Error>) -> Void) {
        Entity.loadAnchorAsync(named: filename, in: bundle)
            .sink(receiveValue: { (entity) in
            completion(.success(entity))
        }).store(in: &RKAssetLoader.cancellables)
    }
    
    
    ///Use this function to access a particular scene from within a .reality file.
    static func loadRealitySceneAsync(filename: String,
                                        fileExtension: String = "reality",
                                        sceneName: String,
                                        completion: @escaping (Swift.Result<(Entity & HasAnchoring)?, Swift.Error>) -> Void) {
        
        guard let realityFileSceneURL = RKAssetLoader.createRealityURL(filename: filename, fileExtension: fileExtension, sceneName: sceneName) else {
            print("Error: Unable to find specified file in application bundle")
            return
        }
        loadRealitySceneAsync(realityFileSceneURL: realityFileSceneURL, completion: completion)
    }
    
    
    static func loadRealitySceneAsync(realityFileSceneURL: URL,
                                        completion: @escaping (Swift.Result<(Entity & HasAnchoring)?, Swift.Error>) -> Void) {
        guard FileManager.default.fileExists(atPath: realityFileSceneURL.path) else {
            print("No file exists at path \(realityFileSceneURL.path)")
            return
        }
        Entity.loadAnchorAsync(contentsOf: realityFileSceneURL)
            .sink(receiveValue: { (entity) in
            completion(.success(entity))
        }).store(in: &RKAssetLoader.cancellables)
    }
}
