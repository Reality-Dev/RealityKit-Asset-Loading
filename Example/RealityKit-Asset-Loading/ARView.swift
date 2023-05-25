//
//  ARView.swift
//
//  Created by Grant Jarvis
//


import RealityKit
import ARKit

class ARSUIView: ARView {
    var rocketScene: RocketProject.RocketScene!

    /// At 0,0,0 in world space, which is where the camera is when the ARSession starts.
    var sceneAnchor = AnchorEntity()

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        scene.addAnchor(sceneAnchor)

        if #available(iOS 15.0, *) {
            loadWithAsyncAwaitSyntax()
        } else {
            loadWithCompletionHandlers()
        }
    }
    
    
    @available(iOS 15.0, *)
    func loadWithAsyncAwaitSyntax(){
        // Here are examples of how to load different kinds of content into RealityKit.
        
        // Uncomment this code to try out the different loading methods.

        Task(priority: .userInitiated) {
            do {
//                try await loadAudioFileAsync()
//                try await loadOneEntityAsync()
//                try await loadOneModelEntityAsync()
//                try await loadBodyTrackedEntityAsync()
//                try await loadMultipleEntitiesAtOnceWithFileNamesAsync()
//                try await loadMultipleEntitiesAtOnceWithURLsAsync()
                try await loadRocketFromRealityFileAsync()
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }
    }
    
    func loadWithCompletionHandlers(){
        // Here are examples of how to load different kinds of content into RealityKit.
        
        // Uncomment this code to try out the different loading methods.
        
//        makeSimpleShapes()
//        loadAudioFile()
//        loadOneEntity()
//        loadOneModelEntity()
//        loadBodyTrackedEntity()
        loadMultipleEntitiesAtOnceWithFileNames()
//        loadMultipleEntitiesAtOnceWithURLs()
//        loadRocketFromRealityFile()
//        loadRocketFromRealityComposerProject()
    }
    
    func enableOcclusion() {
        // Enable occlusion
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            let config = ARWorldTrackingConfiguration()
            config.environmentTexturing = .automatic
            config.sceneReconstruction = .mesh
            config.planeDetection = .horizontal
            session.run(config)
            // --//
            environment.sceneUnderstanding.options.insert(.occlusion)
        }
    }
    
    func makeSimpleShapes() {
        let modelEntities = [
            // You can also pass in paramters to these initializers to customize these shapes.
            ModelEntity.makeBox(),
            ModelEntity.makeSphere(),
            ModelEntity.makePlane(),
        ]
        
        for (index, modelEntity) in modelEntities.enumerated() {
            sceneAnchor.addChild(modelEntity)
            modelEntity.position = [(Float(index) * 0.8) - 1, 0, -2] // Spread the entities out.
        }
    }
}
