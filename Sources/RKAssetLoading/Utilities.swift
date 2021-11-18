//
//  Utilities.swift
//  RealityKit-Asset-Loading
//
//  Created by Grant Jarvis on 11/18/21.
//

import Foundation
import Combine

struct CancellablesHolder {
    static var cancellables = [AnyCancellable]()
}

//From Apple's "Underwater" sample project.
//This is used to handle the errors, if any, from loading an asset.
extension Publisher {
    func sink(receiveValue: @escaping ((Self.Output) -> Void)) -> AnyCancellable {
        sink(
            receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    Swift.print("Error loading asset")
                    Swift.print(error.localizedDescription)
                default:
                    return
                }
            },
            receiveValue: receiveValue
        )
    }
}
