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

// Inspired from Apple's "Underwater" sample project. (see: "LICENSE-Apple-2" for license information).
// This is used to handle the errors, if any, from loading an asset.
internal extension Publisher {
    func sinkAndStore(receiveValue: @escaping ((Self.Output) -> Void),
              errorHandler: RKErrorHandler?) {
        
        // Create a unique id separate from the AnyCancellable's own self-contained identity, so that we can cancel it within the .sink method that creates it without creating a strong reference to it.
        let uuid = UUID()
        
        let cancellable = sink(
            receiveCompletion: { result in
                
                RKLoader.cancellables[uuid] = nil
                
                switch result {
                case let .failure(error):
                    Swift.print("Error loading asset")
                    Swift.print(error)
                    errorHandler?(error)
                default:
                    return
                }
            },
            receiveValue: { output in
                
                RKLoader.cancellables[uuid] = nil
                
                receiveValue(output)
            }
        )
        
        RKLoader.cancellables[uuid] = cancellable
    }
}

public extension RKLoader {
    
    static func loadMany<T>(tasks: [() async throws -> T]) async throws -> [T] {
        
        return try await withThrowingTaskGroup(of: (Int, T).self) { group -> [T] in
            for (index, task) in tasks.enumerated() {
                group.addTask {
                    return (index, try await task())
                }
            }

            var loadedResources = try await group.reduce(into: [(Int, T)]()) { $0.append($1) }
            
            loadedResources = loadedResources.sorted { $0.0 < $1.0 }
            
            return loadedResources.map { $0.1 }
        }
    }
    
    static func loadMany<T>(requests: [LoadRequest<T>],
                            completion: @escaping (([T]) -> Void),
                            errorHandler: RKErrorHandler?) {
        Publishers.MergeMany(requests).collect()
            .sinkAndStore(receiveValue: completion,
                  errorHandler: errorHandler
            )
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
