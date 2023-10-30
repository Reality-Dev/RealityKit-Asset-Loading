# RealityKit Asset Loading

## Discussion

This package includes classes and examples that enable easy, convenient asynchronous asset loading in RealityKit for all of these kinds of assets:
- USDZ files
    - Entities
    - ModelEntities
    - BodyTrackedEntity
    - USDZ animations
- Audio
- TextureResources
- Scenes from .reality files
- Scenes from .rcproject files

It also includes some convenience methods for generating simple shapes (box, sphere and plane) with simple materials, such as `ModelEntity.makeSphere()`.

For generating more simple shapes, see this package from Max Cobb:
- [Reality Geometries](https://github.com/maxxfrazer/RealityGeometries)

For generating text, see this package:
- [RealityKit Text](https://github.com/Reality-Dev/RealityKit-Text)



There are different options provided: some for loading one file at a time, and others for loading many all together at once. You oftentimes have the option of either providing a URL specifying the location of the file on disk to load, or providing a file name and a bundle (bundle is optional - it defaults to the main bundle).

There is also the option of using a completion handler OR using async-await syntax.

This package only includes asynchronous loading methods.
Synchronous load operations block the thread on which you call them which can lead to the user interface stalling and the app becoming unresponsive, especially when loading complex scenes like is often done for AR experiences.
To maintain a smooth user interface, it’s typically best to use an asynchronous load instead. All synchronous load operations have an asynchronous counterpart.


See these documentation articles for more information:
- [Loading Reality Composer Files Manually Without Generated Code](https://developer.apple.com/documentation/realitykit/creating_3d_content_with_reality_composer/loading_reality_composer_files_manually_without_generated_code)
- [Loading Reality Composer Files Using Generated Code](https://developer.apple.com/documentation/realitykit/creating_3d_content_with_reality_composer/loading_reality_composer_files_using_generated_code)
- [Loading Entities From a File](https://developer.apple.com/documentation/realitykit/entity/stored_entities/loading_entities_from_a_file)
  

## Requirements

- iOS 13 or macOS 10.15
- Swift 5.2
- Xcode 11


## Installation

### Swift Package Manager

Add the URL of this repository to your Xcode 11+ Project under:
    File > Add Packages
    `https://github.com/Reality-Dev/RealityKit-Asset-Loading`

## Usage

Add `import RKLoader` to the top of your swift file to start.

### Important:

- Be sure to call the loading functions from the main thread. If you need to call them from code running on a background thread, push the code to the main thread with:
``` swift
        DispatchQueue.main.async {
        //Loading code goes here
    }
```

- Your completion handlers should use a capture list such as `[weak self]` to avoid a memory leak from the completion closure capturing a strong reference to any objects. Here is an example of using this asset loader with a capture list:
``` swift
    func loadOneModelEntity(){
        RKLoader.loadModelEntityAsync(named: "gold_star"){[weak self] starModelEntity in
        
            self?.sceneAnchor.addChild(starModelEntity)
            starModelEntity.position = [0, 0, -2]
        }
    }
```

Here is the async-await version of that call:
``` swift
    func loadOneModelEntityAsync() async throws {
        let starModelEntity = try await RKLoader.loadModelEntityAsync(named: "gold_star")
        
        self.sceneAnchor.addChild(starModelEntity)
        starModelEntity.position = [0, 0, -2]
    }
```


To learn more about automatic reference counting, strong reference cycles, and closure capture lists, see this link:
- [Swift Language Guide](https://docs.swift.org/swift-book/LanguageGuide/AutomaticReferenceCounting.html)

See the example project for multiple examples of how to load different kinds of assets:
- [Example Project](https://github.com/Reality-Dev/RealityKit-Asset-Loading/tree/main/Example)

The ARView file in the example project is especially helpful:
- [ARView](https://github.com/Reality-Dev/RealityKit-Asset-Loading/blob/main/Example/RealityKit-Asset-Loading/ARView.swift)


### Audio

When initializing an `RKLoader.AudioFile` to use for loading audio you may use either the URL of the file on disk or the resource name in the given bundle. If the URL is non-nil, then the file will be loaded from the URL by default. If you are using `resourceName`, then leave the URL as nil, and be sure to include the file extension in the `resourceName` like this: `"myAudio.mp3"`.


## More

Pull Requests are welcome and encouraged.





