//
//  GeneratingTextures.swift
//  RealityKit-Asset-Loading
//
//  Created by Grant Jarvis on 11/19/21.
//

import RealityKit
import UIKit
import Combine


@available(iOS 15.0, *)
public extension RKAssetLoader {
    
    static func generateTextureAsync(from cgImage: CGImage,
                                     withName resourceName: String? = nil,
                                     options: TextureResource.CreateOptions = .init(semantic: .color),
                                     completionHandler: @escaping ((_ texture: TextureResource)->())){
        DispatchQueue.main.async {
            TextureResource.generateAsync(from: cgImage,
                                          withName: resourceName,
                                          options: options)
                .sink(receiveValue: { texture in
                    completionHandler(texture)
                    
                }).store(in: &RKAssetLoader.cancellables)
    }}
    
    static func loadTextureAsync(named resourceName: String,
                                 in bundle: Bundle? = nil,
                                 options: TextureResource.CreateOptions = .init(semantic: .color),
                                 completionHandler: @escaping ((_ texture: TextureResource)->())){
        DispatchQueue.main.async {
            TextureResource.loadAsync(named: resourceName,
                                      in: bundle,
                                      options: options)
                .sink(receiveValue: { texture in
                    completionHandler(texture)
                    
                }).store(in: &RKAssetLoader.cancellables)
    }}
    
    static func loadTextureAsync(contentsOf url: URL,
                                 named resourceName: String,
                                 options: TextureResource.CreateOptions = .init(semantic: .color),
                                 completionHandler: @escaping ((_ texture: TextureResource)->())){
        DispatchQueue.main.async {
            TextureResource.loadAsync(contentsOf: url,
                                      withName: resourceName,
                                      options: options)
                .sink(receiveValue: { texture in
                    completionHandler(texture)
                    
                }).store(in: &RKAssetLoader.cancellables)
    }}
}
