//
//  AnimationsScreen.swift
//  native-benchmarks
//
//  Created by Vanja Vidmark on 2025-04-25.
//

import SwiftUI

struct AnimatedImage {
    let imageName: String
    let speed: Double
    let yOffset: CGFloat
    let phaseOffset: Double
    let direction: Double
    let rotationSpeed: Double
}

struct AnimationsScreen: View {
    @ObservedObject var controller = AnimationsController.shared
    @State private var startTime = Date()
    @State private var images: [AnimatedImage] = []

    let onDone: () -> Void
    let imageNames = (1...10).map { "star\($0)" }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                if controller.isAnimating {
                    TimelineView(.animation) { context in
                        let now = context.date.timeIntervalSince(startTime)
                        let totalWidth = geo.size.width + 200.0

                        ForEach(0..<images.count, id: \.self) { i in
                            let img = images[i]
                            let basePosition = now * img.speed * img.direction + img.phaseOffset
                            let x = CGFloat(fmod(basePosition + totalWidth, totalWidth)) - 100.0
                            let angle = Angle(degrees: now * img.rotationSpeed * img.direction)

                            Image(img.imageName)
                                .resizable()
                                .frame(width: 60, height: 60)
                                .rotationEffect(angle)
                                .position(x: x, y: img.yOffset)
                        }
                    }
                    .onAppear {
                        startTime = Date()
                        generateImages(screenHeight: geo.size.height)
                    }
                }
            }
            .onChange(of: controller.isAnimating) { running in
                if !running {
                    onDone()
                }
            }
        }
    }

    func generateImages(screenHeight: CGFloat) {
        images = (0..<100).map { _ in
            AnimatedImage(
                imageName: imageNames.randomElement() ?? "star1",
                speed: Double.random(in: 20...300),
                yOffset: CGFloat.random(in: 80...(screenHeight - 80)),
                phaseOffset: Double.random(in: 0...1000),
                direction: Bool.random() ? 1.0 : -1.0,
                rotationSpeed: Double.random(in: 30...180)
            )
        }
    }
}
