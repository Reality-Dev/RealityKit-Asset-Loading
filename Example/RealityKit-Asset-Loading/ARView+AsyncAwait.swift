//
//  File.swift
//  
//
//  Created by Grant Jarvis on 5/24/23.
//

import RKAssetLoading
import RKUtilities
import RealityKit
import ARKit

@available(iOS 15.0, *)
extension ARSUIView {
    
    /// This is an example for using .reality files to load content
    func loadRocketFromRealityFileAsync() async throws {
        let fileName = "Rocket"
        
        // This is another way to load content from Reality Composer projects other than the example given down below, since .rcproject files are turned into .reality files at build time.
        //        let fileName = "Rocket_Project"
        
                let loadedScene = try await RKAssetLoader.loadRealitySceneAsync(filename: fileName)
                
                // Use the loaded content here.
                // The scene comes as an AnchorEntity, and the entities (the rocket in this case) come as entities attached to that anchor, so we only need to add the anchor to the ARView's scene, and the other entities will therefore be added as children as well.
    
                self.scene.addAnchor(loadedScene)
                
                enableOcclusion()
    }


    
    func loadOneEntityAsync() async throws {
        let capsuleModelEntity = try await RKAssetLoader.loadEntityAsync(named: "aluminum_capsule")
        
        self.sceneAnchor.addChild(capsuleModelEntity)
        capsuleModelEntity.position = [0, 0, -2]
    }
    
    func loadOneModelEntityAsync() async throws {
        let starModelEntity = try await RKAssetLoader.loadModelEntityAsync(named: "gold_star")
        
        self.sceneAnchor.addChild(starModelEntity)
        starModelEntity.position = [0, 0, -2]
    }
    
    func loadBodyTrackedEntityAsync() async throws {
        guard ARBodyTrackingConfiguration.isSupported else { return }
        // Make sure to run an ARBodyTrackingConfiguration.
        let btConfig = ARBodyTrackingConfiguration()
        session.run(btConfig)
        
        let robot = try await RKAssetLoader.loadBodyTrackedEntityAsync(named: "biped_robot")
        
        let bodyAnchor = AnchorEntity(.body)
        self.scene.addAnchor(bodyAnchor)
        bodyAnchor.addChild(robot)
        robot.scale = .init(repeating: 1.4)
    }
    
    func loadAudioFileAsync() async throws {
        guard let audioURL = Bundle.main.url(forResource: "audio_Loop", withExtension: "mp3") else { return }
        let audioFile = RKAssetLoader.AudioFile(resourceName: "audio_Loop", url: audioURL, shouldLoop: true)
        
        let audio = try await RKAssetLoader.loadAudioAsync(audioFile: audioFile)
        
        let audioEntity = ModelEntity.makeSphere(radius: 0.1)
        self.sceneAnchor.addChild(audioEntity)
        audioEntity.position = [0, 0, -1]
        audioEntity.playAudio(audio)
    }

    func loadMultipleEntitiesAtOnceWithFileNamesAsync() async throws {
        // There is also a ModelEntity version of this function.
        
            // Pass in the names of the assets to load.
            // This function requires at least two entities and can load as many as you would like.
            let entities = try await RKAssetLoader.loadEntitiesAsync(entityNames:
                                                                        ["aluminum_capsule",
                                                                         "gold_star",
                                                                         "toy_biplane",
                                                                         "aluminum_capsule"])
            
            // Use the loaded assets here.
            for (index, entity) in entities.enumerated() {
                sceneAnchor.addChild(entity)
                entity.position = [(Float(index) * 0.8) - 1, 0, -2] // Spread the entities out.
                
                // Usdz animation
                if index == 2 { // Biplane
                    makePlaneFly(entity)
                }
            }
    }
    
    func loadMultipleEntitiesAtOnceWithURLsAsync() async throws {
        // Get the URLs for the usdz files.
        guard
            let capsulePath = Bundle.main.url(forResource: "aluminum_capsule", withExtension: "usdz"),
            let starPath = Bundle.main.url(forResource: "gold_star", withExtension: "usdz"),
            let ballPath = Bundle.main.url(forResource: "toy_biplane", withExtension: "usdz")
        else {
            print("Error making URLs for usdz assets.")
            return
        }
        // There is also a ModelEntity version of this function.
        
        // Pass in the URLs and the names of the assets to load. This function requires at least two entities and can load as many as you would like.
        let entities = try await RKAssetLoader.loadEntitiesAsync(entities:
                                            [(path: capsulePath, name: nil),
                                        (path: starPath, name: "gold_star"),
                                        (path: ballPath, name: "toy_biplane"),
                                        (path: capsulePath, name: "aluminum_capsule")])

        // Use the loaded assets here.
        for (index, entity) in entities.enumerated() {
            self.sceneAnchor.addChild(entity)
            entity.position = [(Float(index) * 0.5) - 1, 0, -2] // Spread the entities out.
            
            // Usdz animation
            if index == 2 { // Biplane
                self.makePlaneFly(entity)
            }
        }
    }
}
