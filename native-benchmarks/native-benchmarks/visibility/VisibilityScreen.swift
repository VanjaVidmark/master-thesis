//
//  VisibilityScreen.swift
//  native-benchmarks
//
//  Created by Vanja Vidmark on 2025-03-26.
//

import SwiftUI

struct VisibilityScreen: View {
    @ObservedObject var controller = VisibilityController.shared
    @State private var opacity: Double = 1.0
    @State private var fadeIn = false
    @State private var timer: Timer?

    let onDone: () -> Void

    var body: some View {
        ZStack {
            if controller.isRunning {
                Image("scroll10")
                    .resizable()
                    .scaledToFill()
                    .opacity(opacity)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .onAppear {
                        startAnimating()
                    }
                    .onDisappear {
                        stopAnimating()
                    }
            }
        }
        .onChange(of: controller.isRunning) { running in
            if !running {
                stopAnimating()
                onDone()
            }
        }
    }

    func startAnimating() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            withAnimation(.linear(duration: 1.0)) {
                opacity = fadeIn ? 1.0 : 0.0
                fadeIn.toggle()
            }
        }
    }

    func stopAnimating() {
        timer?.invalidate()
        timer = nil
    }
}
