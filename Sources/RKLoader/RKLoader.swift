//
//  File.swift
//  
//
//  Created by Grant Jarvis on 11/28/23.
//

import Combine
import Foundation

public enum RKLoader {
    static var cancellables = [UUID: AnyCancellable]()
}
