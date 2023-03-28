//
//  ContentView.swift
//
//  Created by Grant Jarvis
//

import RealityKit
import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            ARViewContainer().edgesIgnoringSafeArea(.all)
            // UIContent goes here.
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    func makeUIView(context _: Context) -> ARView {
        return ARSUIView(frame: .zero)
    }

    func updateUIView(_: ARView, context _: Context) {}
}

#if DEBUG
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
#endif
