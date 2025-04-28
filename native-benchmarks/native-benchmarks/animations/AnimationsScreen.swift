import SwiftUI

struct AnimatedImage {
    let imageName: String
    let x: CGFloat
    let y: CGFloat
    let scaleOffset: Double
    let visibilityOffset: Double
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

                        ForEach(0..<images.count, id: \.self) { i in
                            let img = images[i]
                            let timeSec = now

                            let scale = 0.8 + 0.4 * sin((timeSec + img.scaleOffset / 1000.0) * 2 * Double.pi)
                            let alpha = 0.5 + 0.5 * sin((timeSec + img.visibilityOffset / 1000.0) * 2 * Double.pi)

                            Image(img.imageName)
                                .resizable()
                                .frame(width: 40, height: 40)
                                .scaleEffect(scale)
                                .position(x: img.x,
                                          y: img.y)
                                .opacity(alpha)
                        }
                    }
                    .onAppear {
                        startTime = Date()
                        generateImages(screenWidth: geo.size.width, screenHeight: geo.size.height)
                    }
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .onChange(of: controller.isAnimating) { running in
                if !running {
                    onDone()
                }
            }
        }
    }

    func generateImages(screenWidth: CGFloat, screenHeight: CGFloat) {
        images = (0..<150).map { _ in
            AnimatedImage(
                imageName: imageNames.randomElement() ?? "star1",
                x: CGFloat.random(in: 0...screenWidth),
                y: 0,
                scaleOffset: Double.random(in: 0...1000),
                visibilityOffset: Double.random(in: 0...1000)
            )
        }
    }
}
