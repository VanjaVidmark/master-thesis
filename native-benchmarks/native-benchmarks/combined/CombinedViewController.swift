//
//  CombinedViewController.swift
//  native-benchmarks
//
//  Created by Vanja Vidmark on 2025-04-21.
//

import UIKit
import AVFoundation
import Photos

class CombinedViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    private var captureSession: AVCaptureSession!
    private var photoOutput: AVCapturePhotoOutput!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    private var performanceCallback: (() -> Void)?
    private var completionHandler: (() -> Void)?
    private var totalInterations = 0
    private var warmupIterations = 0
    private var iteration = 0
    private var imageView: UIImageView!
    private var overlayView: UIView!
    private var savedPhotoURLs: [URL] = []
    private var loadingSpinner: UIActivityIndicatorView!
    private var captureButton: UIButton!

    private let performanceCalculator : UiPerformanceCalculator
    
    init(performanceCalculator: UiPerformanceCalculator) {
        self.performanceCalculator = performanceCalculator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startBenchmark(warmup: Int, runs: Int = 10, onDone: @escaping () -> Void) {
        self.totalInterations = runs + warmup
        self.warmupIterations = warmup
        self.completionHandler = onDone
        self.setupCamera()
        self.setupUI()
    }

    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo

        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
              captureSession.canAddInput(videoInput) else {
            print("Camera unavailable")
            return
        }

        captureSession.addInput(videoInput)

        photoOutput = AVCapturePhotoOutput()
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)

        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // triggers first photo after 3 seconds
            self.captureButton.sendActions(for: .touchUpInside)
        }
    }

    private func setupUI() {
        overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = .white
        overlayView.alpha = 0
        view.addSubview(overlayView)
        
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0
        view.addSubview(imageView)

        loadingSpinner = UIActivityIndicatorView(style: .large)
        loadingSpinner.center = view.center
        loadingSpinner.hidesWhenStopped = true
        view.addSubview(loadingSpinner)
        
        captureButton = UIButton(type: .system)
        captureButton.frame = CGRect(x: (view.frame.width - 80) / 2, y: view.frame.height - 100, width: 80, height: 80)
        captureButton.layer.cornerRadius = 40
        captureButton.backgroundColor = .white
        captureButton.setTitle("Photo", for: .normal)
        captureButton.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        captureButton.addTarget(self, action: #selector(handleCaptureButton), for: .touchUpInside)
        view.addSubview(captureButton)

    }
    
    @objc private func handleCaptureButton() {
        takePhoto()
    }

    private func takePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        
        self.loadingSpinner.startAnimating()
        self.captureButton.isHidden = true
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else { return }

        // Save to disk
        let filename = UUID().uuidString + ".jpg"
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)
        savedPhotoURLs.append(fileURL)
        do {
            try imageData.write(to: fileURL)
            print("Saved to disk at \(fileURL)")
        } catch {
            print("Error saving: \(error)")
        }

        // Save to gallery
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                }
            }
        }

        // Read it back & display
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            if let data = try? Data(contentsOf: fileURL),
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.loadingSpinner.stopAnimating()
                    self.overlayView.alpha = 0
                    self.imageView.image = image
                    
                    // fade in image + white backgorund
                    UIView.animate(withDuration: 0.6) {
                        self.overlayView.alpha = 1
                        self.imageView.alpha = 1
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        // fade away image + white backgorund
                        UIView.animate(withDuration: 0.6) {
                            self.overlayView.alpha = 0
                            self.imageView.alpha = 0
                            self.captureButton.isHidden = false
                        }
                        
                        self.iteration += 1
                        
                        if self.iteration == self.warmupIterations {
                            self.performanceCalculator.start()
                        }
                        
                        if self.iteration < self.totalInterations {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                self.captureButton.sendActions(for: .touchUpInside)
                            }
                        } else {
                            self.performanceCalculator.stopAndPost()
                            self.cleanup()
                            self.completionHandler?()
                        }
                    }
                }
            }
        }
    }

    private func cleanup() {
        captureSession.stopRunning()
        previewLayer.removeFromSuperlayer()
        
        for url in savedPhotoURLs {
            try? FileManager.default.removeItem(at: url)
            print("Deleted \(url.lastPathComponent)")
        }
        
        imageView.removeFromSuperview()
        overlayView.removeFromSuperview()
        loadingSpinner.removeFromSuperview()
    }
}

class CombinedBenchmark {
    private let performanceCalculator : UiPerformanceCalculator
    init(performanceCalculator: UiPerformanceCalculator) {
        self.performanceCalculator = performanceCalculator
    }
    
    func runBenchmark(warmup: Int, n: Int) async throws {
        await MainActor.run {
            if let scene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
               let window = scene.windows.first,
               let rootVC = window.rootViewController {
                
                let vc = CombinedViewController(performanceCalculator: performanceCalculator)
                vc.modalPresentationStyle = .fullScreen
                vc.startBenchmark(warmup: warmup, runs: n) {
                    vc.dismiss(animated: true)
                }
                rootVC.present(vc, animated: true)
            }
        }

    }
}
