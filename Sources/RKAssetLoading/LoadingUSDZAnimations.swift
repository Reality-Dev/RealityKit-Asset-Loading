//
//  LoadingUSDZAnimations.swift
//  RealityKit-Asset-Loading
//
//  Created by Grant Jarvis on 11/7/21.
//

import RealityKit
import Combine
import Foundation
import CoreMedia

public extension Entity {
    ///Returns the first entity in the hierarchy that has an available animation, searching the entire hierarchy recursively.
    func findAnim() -> Entity?{
        if self.availableAnimations.isEmpty == false {
            return self
        } else {
            for child in self.children {
                if let animEntity = child.findAnim() {
                    return animEntity
                }
            }
        }
        return nil
    }
    
    func availableAnimations()-> [AnimationResource]? {
        guard let animEntity = self.findAnim() else {return nil}
        return animEntity.availableAnimations
    }
    
    @available(macOS 12.0, iOS 15.0, *)
    @discardableResult func playFirstAnimation(transitionDuration: TimeInterval = 0,
                                               blendLayerOffset: Int = 0,
                                               separateAnimatedValue: Bool = false,
                                               startsPaused: Bool = false,
                                               clock: CMClockOrTimebase? = nil) -> AnimationPlaybackController? {
        guard let animEntity = self.findAnim() else {return nil}
        let animation = animEntity.availableAnimations[0].repeat(duration: .infinity)
        return self.playAnimation(animation,
                                  transitionDuration: transitionDuration,
                                  blendLayerOffset: blendLayerOffset,
                                  separateAnimatedValue: separateAnimatedValue,
                                  startsPaused: startsPaused,
                                  clock: clock)
    }
}
