//
//  File.swift
//  
//
//  Created by Grant Jarvis on 5/24/23.
//

import ARKit
import RealityKit
import RKAssetLoading
import RKUtilities

extension ARSUIView {
    /// This is an example for using .reality files to load content
    func loadRocketFromRealityFile() {
        let fileName = "Rocket"
        
        // This is another way to load content from Reality Composer projects other than the example given down below, since .rcproject files are turned into .reality files at build time.
        //        let fileName = "Rocket_Project"
        
        RKAssetLoader.loadRealitySceneAsync(filename: fileName) { [weak self] loadedScene in
            // Use the loaded content here.
            // The scene comes as an AnchorEntity, and the entities (the rocket in this case) come as entities attached to that anchor, so we only need to add the anchor to the ARView's scene, and the other entities will therefore be added as children as well.
            self?.scene.addAnchor(loadedScene)
        }
        
        enableOcclusion()
    }
    
    // For use with Reality Composer projects:
    // Fill in the placeholders with the names of your project and scene.
    /*
     func loadSceneAsync(){
     // Load the scene from the Reality File, checking for any errors
     <#Project#>.<#loadSceneAsync#> {[weak self] result in
     switch result{
     case .failure (let error):
     print("Unable to load the scene with error: ", error.localizedDescription)
     case .success(let scene):
     //Make use of the scene
     print("Scene Loaded Asyncronously")
     self?.<#scene#> = scene
     self?.<#sceneDidLoad()#>
     }
     }
     }
     */
    
    /// This is an example for using a reality composer project to load content
    func loadRocketFromRealityComposerProject() {
        // Load the scene from the Reality File, checking for any errors
        RocketProject.loadRocketSceneAsync { [weak self] result in
            switch result {
            case let .failure(error):
                print("Unable to load the scene with error: ", error.localizedDescription)
            case let .success(scene):
                // Make use of the loaded scene
                print("Scene Loaded Asyncronously")
                self?.rocketScene = scene
                self?.scene.addAnchor(scene)
                
                //Optionally, create another method to call upon successful loading.
                // self?.sceneDidLoad()
            }
        }
        
        enableOcclusion()
    }
    

    

    
    func loadOneEntity() {
        RKAssetLoader.loadEntityAsync(named: "aluminum_capsule") { [weak self] capsuleModelEntity in
            self?.sceneAnchor.addChild(capsuleModelEntity)
            capsuleModelEntity.position = [0, 0, -2]
        }
    }
    
    func loadOneModelEntity() {
        RKAssetLoader.loadModelEntityAsync(named: "gold_star") { [weak self] starModelEntity in
            self?.sceneAnchor.addChild(starModelEntity)
            starModelEntity.position = [0, 0, -2]
        }
    }
    
    func loadBodyTrackedEntity() {
        guard ARBodyTrackingConfiguration.isSupported else { return }
        // Make sure to run an ARBodyTrackingConfiguration.
        let btConfig = ARBodyTrackingConfiguration()
        session.run(btConfig)
        
        RKAssetLoader.loadBodyTrackedEntityAsync(named: "biped_robot") { [weak self] robot in
            let bodyAnchor = AnchorEntity(.body)
            self?.scene.addAnchor(bodyAnchor)
            bodyAnchor.addChild(robot)
            robot.scale = .init(repeating: 1.4)
        }
    }
    
    func loadAudioFile() {
        guard let audioURL = Bundle.main.url(forResource: "audio_Loop", withExtension: "mp3") else { return }
        let audioFile = RKAssetLoader.AudioFile(resourceName: "audio_Loop", url: audioURL, shouldLoop: true)
        RKAssetLoader.loadAudioAsync(audioFile: audioFile) { [weak self] audio in
            let audioEntity = ModelEntity.makeSphere(radius: 0.1)
            self?.sceneAnchor.addChild(audioEntity)
            audioEntity.position = [0, 0, -1]
            audioEntity.playAudio(audio)
        }
    }

    
    
    func loadMultipleEntitiesAtOnceWithFileNames() {
        // There is also a ModelEntity version of this function.
        
        // Pass in the names of the assets to load.
        // This function requires at least two entities and can load as many as you would like.
        RKAssetLoader.loadEntitiesAsync(entityNames:
                                            ["aluminum_capsule",
                                        "gold_star",
                                        "toy_biplane",
                                        "aluminum_capsule"],
                                        errorHandler: { error in
            assertionFailure("\(error)")
        })
        { [weak self] entities in
            // Use the loaded assets here.
            for (index, entity) in entities.enumerated() {
                self?.sceneAnchor.addChild(entity)
                entity.position = [(Float(index) * 0.8) - 1, 0, -2] // Spread the entities out.
                
                // Usdz animation
                if index == 2 { // Biplane
                    self?.makePlaneFly(entity)
                }
            }
        }
    }
    
    // Usdz animation
    func makePlaneFly(_ plane: Entity) {
        if #available(iOS 15.0, *) {
            plane.playFirstAnimation()
            plane.scale = .init(repeating: 0.04)
        }
        // Another option:
        // plane.playAnimation(plane.availableAnimations()?.first)
    }
    
    func loadMultipleEntitiesAtOnceWithURLs() {
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
        RKAssetLoader.loadEntitiesAsync(entities:
                                            [(path: capsulePath, name: nil),
                                        (path: starPath, name: "gold_star"),
                                        (path: ballPath, name: "toy_biplane"),
                                        (path: capsulePath, name: "aluminum_capsule")])
        { [weak self] entities in
            // Use the loaded assets here.
            for (index, entity) in entities.enumerated() {
                self?.sceneAnchor.addChild(entity)
                entity.position = [(Float(index) * 0.5) - 1, 0, -2] // Spread the entities out.
                
                // Usdz animation
                if index == 2 { // Biplane
                    self?.makePlaneFly(entity)
                }
            }
        }
    }
}
