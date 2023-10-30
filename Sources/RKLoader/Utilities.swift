//
//  Utilities.swift
//  RealityKit-Asset-Loading
//
//  Created by Grant Jarvis on 11/18/21.
//

import Combine
import Foundation
import RealityKit

public typealias RKErrorHandler = (Error) -> Void

public typealias RKCompletionHandler<T> = (T) -> Void

// From Apple's "Underwater" sample project.
// This is used to handle the errors, if any, from loading an asset.
public extension Publisher {
    func sink(receiveValue: @escaping ((Self.Output) -> Void),
              errorHandler: RKErrorHandler?) -> AnyCancellable {
        sink(
            receiveCompletion: { result in
                switch result {
                case let .failure(error):
                    Swift.print("Error loading asset")
                    Swift.print(error)
                    errorHandler?(error)
                default:
                    return
                }
            },
            receiveValue: receiveValue
        )
    }
}

public extension RKLoader {
    static func loadMany<T>(requests: [LoadRequest<T>],
                            completion: @escaping (([T]) -> Void),
                            errorHandler: RKErrorHandler?) {
        Publishers.MergeMany(requests).collect()
            .sink(receiveValue: completion,
                  errorHandler: errorHandler
            ).store(in: &RKLoader.cancellables)
    }
}

//From:
//https://medium.com/geekculture/from-combine-to-async-await-c08bf1d15b77
enum AsyncError: Error {
    case finishedWithoutValue
}
public extension AnyPublisher {
    func async() async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            var finishedWithoutValue = true
            cancellable = first()
                .sink { result in
                    switch result {
                    case .finished:
                        if finishedWithoutValue {
                            Swift.print("Loading Failed")
                            continuation.resume(throwing: AsyncError.finishedWithoutValue)
                        }
                    case let .failure(error):
                        Swift.print(error.localizedDescription)
                        continuation.resume(throwing: error)
                    }
                    cancellable?.cancel()
                } receiveValue: { value in
                    finishedWithoutValue = false
                    continuation.resume(with: .success(value))
                }
        }
    }
}
