//
//  CameraView.swift
//  native-benchmarks
//
//  Created by Vanja Vidmark on 2025-04-05.
//

import SwiftUI
import UIKit

struct CameraView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CameraViewController {
        return CameraViewController()
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}
