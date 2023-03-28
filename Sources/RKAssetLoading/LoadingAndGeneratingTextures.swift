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

@available(macOS 12.0, iOS 15.0, *)
public extension RKAssetLoader {
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
