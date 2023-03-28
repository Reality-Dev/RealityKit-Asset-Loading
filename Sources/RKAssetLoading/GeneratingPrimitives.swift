//
//  Primitives.swift
//  RealityKit-Asset-Loading
//
//  Created by Grant Jarvis on 11/6/21.
//

import RealityKit

//For generating text, see: https://github.com/Reality-Dev/RealityKit-Text

//These are useful for making simple shapes with Simple Materials

public extension ModelEntity {
    static func makeSphere(color: SimpleMaterial.Color = .blue,
                            radius: Float = 0.05,
                            isMetallic: Bool = true) -> ModelEntity{
        
        let sphereMesh = MeshResource.generateSphere(radius: radius)
        let sphereMaterial = SimpleMaterial.init(color: color, isMetallic: isMetallic)
        return ModelEntity(mesh: sphereMesh,
                           materials: [sphereMaterial])
    }

    static func makeBox(color: SimpleMaterial.Color = .blue,
                         isMetallic: Bool = true,
                         size: simd_float3 = .one,
                         cornerRadius: Float = 0,
                         splitFaces: Bool = false) -> ModelEntity{
        
        let boxMesh = MeshResource.generateBox(width: size.x, height: size.y, depth: size.z, cornerRadius: cornerRadius, splitFaces: splitFaces)
        let boxMaterial = SimpleMaterial.init(color: color, isMetallic: isMetallic)
        return ModelEntity(mesh: boxMesh,
                           materials: [boxMaterial])
    }

    static func makePlane(color: SimpleMaterial.Color = .blue,
                          isMetallic: Bool = true,
                          width: Float = 1,
                          height: Float = 1,
                          cornerRadius: Float = 0)-> ModelEntity{
        let planeMesh = MeshResource.generatePlane(width: width, height: height, cornerRadius: cornerRadius)
        let planeMaterial = SimpleMaterial.init(color: color, isMetallic: isMetallic)
        return ModelEntity(mesh: planeMesh,
                           materials: [planeMaterial])
    }
}


