# RealityKit Asset Loading

## Discussion

This package includes classes and examples that enable easy, convenient asynchronous asset loading in RealityKit for all of these kinds of assets:
- Entities
- ModelEntities
- BodyTrackedEntity
- Audio
- USDZ animations
- Scenes from .reality files
- Scenes from .rcproject files

It also includes some convenience methods for generating simple shapes (box, sphere and plane) with simple materials.

There are different options provided: some for loading one file at a time, and others for loading many all together at once. You oftentimes have the option of either providing a URL specifying the location of the file on disk to load, or providing a file name and a bundle (bundle is optional - it defaults to the main bundle).

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

Add `import RKAssetLoading` to the top of your swift file to start.

### Important:
- Your completion handlers should use a capture list such as `[weak self]` to avoid a memory leak from the completion closure capturing a strong reference to any objects. Here is an example of using this asset loader with a capture list:
``` swift
    func loadOneModelEntity(){
        RKAssetLoader.loadModelEntityAsync(named: "gold_star"){[weak self] starModelEntity in
            self?.sceneAnchor.addChild(starModelEntity)
            starModelEntity.position = [0, 0, -2]
        }
    }
```

To learn more about automatic reference counting, strong reference cycles, and closure capture lists, see this link:
- [Swift Language Guide](https://docs.swift.org/swift-book/LanguageGuide/AutomaticReferenceCounting.html)

See the example project for multiple examples of how to load different kinds of assets:
- [Example Project](https://github.com/Reality-Dev/RealityKit-Asset-Loading/tree/main/Example)

The ARView file in the example project is especially helpful:
- [ARView](https://github.com/Reality-Dev/RealityKit-Asset-Loading/blob/main/Example/RealityKit-Asset-Loading/ARView.swift)







