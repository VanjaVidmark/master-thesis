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

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(0..<1000) { index in
                        HStack {
                            Image("example_img")
                                .resizable()
                                .frame(width: 64, height: 64)
                                .padding(.trailing, 8)
                            Text("Item \(index)")
                            Spacer()
                        }
                        .padding(8)
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
        timer = Timer.scheduledTimer(withTimeInterval: 0.015, repeats: true) { _ in
            withAnimation(.linear(duration: 0.015)) {
                proxy.scrollTo(scrollTarget, anchor: .top)
            }
            scrollTarget += 10
            if scrollTarget >= 999 {
                scrollTarget = 0
            }
        }
    }

    func stopScrolling() {
        timer?.invalidate()
        timer = nil
    }
}

