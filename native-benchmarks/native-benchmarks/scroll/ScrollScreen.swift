//
//  ScrollScreen.swift
//  native-benchmarks
//
//  Created by Vanja Vidmark on 2025-03-25.
//


import SwiftUI

struct ScrollScreen: View {
    @ObservedObject var controller = ScrollController.shared
    @State private var scrollTarget: Int = 0
    @State private var timer: Timer?
    
    let onDone: () -> Void

    let imageNames = (1...10).map { "scroll\($0)" }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .center) {
                    ForEach(0..<100) { index in
                        ScrollItemView(index: index, imageNames: imageNames)
                            .id(index)
                    }
                }
            }
            .onReceive(controller.$isScrolling) { isScrolling in
                if isScrolling {
                    startScrolling(proxy: proxy)
                } else {
                    stopScrolling()
                    onDone()
                }
            }
        }
    }

    func startScrolling(proxy: ScrollViewProxy) {
        scrollTarget = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
            withAnimation(.linear(duration: 0.4)) {
                proxy.scrollTo(scrollTarget, anchor: .top)
            }
            scrollTarget += 1
            if scrollTarget >= 99 {
                scrollTarget = 0
            }
        }
    }

    func stopScrolling() {
        timer?.invalidate()
        timer = nil
    }
}

struct ScrollItemView: View {
    let index: Int
    let imageNames: [String]

    @State private var randomImageName: String = ""

    var body: some View {
        VStack(spacing: 8) {
            Image(randomImageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 600, height: 400)
                .clipped()
                .frame(maxWidth: .infinity, alignment: .center)

            Text("Item \(index)")
                .font(.system(size: 20))
                .padding(.bottom, 24)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 16)
        .onAppear {
            if randomImageName.isEmpty {
                randomImageName = imageNames.randomElement() ?? "scroll1"
            }
        }
    }
}
