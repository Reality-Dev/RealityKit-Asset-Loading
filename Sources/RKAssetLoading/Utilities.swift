//
//  Utilities.swift
//  RealityKit-Asset-Loading
//
//  Created by Grant Jarvis on 11/18/21.
//

import Combine
import Foundation

// From Apple's "Underwater" sample project.
// This is used to handle the errors, if any, from loading an asset.
public extension Publisher {
    func sink(receiveValue: @escaping ((Self.Output) -> Void)) -> AnyCancellable {
        sink(
            receiveCompletion: { result in
                switch result {
                case let .failure(error):
                    Swift.print("Error loading asset")
                    Swift.print(error)
                default:
                    return
                }
            },
            receiveValue: receiveValue
        )
    }
}
