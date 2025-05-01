import SwiftUI

struct AnimatedImage: Identifiable {
    let id = UUID()
    let imageName: String
    let x: CGFloat
    let y: CGFloat
}

class StarAnimationState: ObservableObject {
    @Published var opacity: Double = 0.0
    @Published var scale: CGFloat = 1.0

    private var opacityTimer: Timer?
    private var scaleTimer: Timer?
    private var fadeIn = true
    private var grow = true

    func start() {
        let opacityDelay = Double.random(in: 0..<1.0)
        let scaleDelay = Double.random(in: 0..<1.0)

        DispatchQueue.main.asyncAfter(deadline: .now() + opacityDelay) {
            self.opacityTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                withAnimation(.linear(duration: 0.5)) {
                    self.opacity = self.fadeIn ? 1.0 : 0.0
                    self.fadeIn.toggle()
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + scaleDelay) {
            self.scaleTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.scale = self.grow ? 1.3 : 0.7
                    self.grow.toggle()
                }
            }
        }
    }

    func stop() {
        opacityTimer?.invalidate()
        scaleTimer?.invalidate()
        opacityTimer = nil
        scaleTimer = nil
    }
}


struct StarView: View {
    let image: AnimatedImage
    @ObservedObject var state: StarAnimationState

    var body: some View {
        Image(image.imageName)
            .resizable()
            .frame(width: 30, height: 30)
            .scaleEffect(state.scale)
            .opacity(state.opacity)
            .position(x: image.x, y: image.y)
    }
}

struct AnimationsScreen: View {
    @ObservedObject var controller = AnimationsController.shared
    @State private var stars: [(AnimatedImage, StarAnimationState)] = []

    let onDone: () -> Void
    let imageNames = (1...10).map { "star\($0)" }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(stars, id: \.0.id) { star, state in
                    StarView(image: star, state: state)
                }
            }
            .onAppear {
                stars = (0..<200).map { _ in
                    let star = AnimatedImage(
                        imageName: imageNames.randomElement() ?? "star1",
                        x: CGFloat.random(in: 0...geo.size.width),
                        y: CGFloat.random(in: 0...geo.size.height)
                    )
                    let state = StarAnimationState()
                    state.start()
                    return (star, state)
                }
            }
            .onChange(of: controller.isAnimating) { running in
                if !running {
                    stars.forEach { $0.1.stop() }
                    onDone()
                }
            }
        }
    }
}
