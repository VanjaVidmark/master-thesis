//
//  CameraBenchmark.swift
//  native-benchmarks
//
//  Created by Vanja Vidmark on 2025-04-02.
//
/*
import Foundation
import AVFoundation
import Photos

class CameraBenchmark: NSObject {
    
    let session = AVCaptureSession()
    var cameraCaptureOutput : AVCapturePhotoOutput?
    var camera: AVCaptureDevice?
    
    private var totalIterations = 0
    private var currentIteration = 0
    
    func runBenchmark(n: Int) {
        totalIterations = n
        currentIteration = 0
        
        requestPermissionsIfNeeded { granted in
            guard granted else {
                self.log("Camera or photo library permission not granted.")
                return
            }
            self.setupSession()
        }
    }
    
    private func requestPermissionsIfNeeded(completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { videoGranted in
            guard videoGranted else {
                completion(false)
                return
            }
            PHPhotoLibrary.requestAuthorization { status in
                completion(status == .authorized)
            }
        }
    }
    
    private func setupSession() {
        session.beginConfiguration()
        session.sessionPreset = .high
        
        camera = AVCaptureDevice.default(for: .video)
        do {
            let cameraCaptureInput = try AVCaptureDeviceInput(device: camera!)
            cameraCaptureOutput = AVCapturePhotoOutput()
            session.addInput(cameraCaptureInput)
            session.addOutput(cameraCaptureOutput)
        } catch {
            log(error.localizedDescription)
        }
              
        }
        deviceInput = input
        session.addInput(input)
        
        guard session.canAddOutput(photoOutput) else {
            log("Failed to configure photo output.")
            return
        }
        session.addOutput(photoOutput)
        session.commitConfiguration()
        
        session.startRunning()
        
        DispatchQueue.main.async {
            self.captureNextPhoto()
        }
    }
    
    private func captureNextPhoto() {
        guard currentIteration < totalIterations else {
            log("Benchmark complete. Captured and saved \(totalIterations) photos.")
            session.stopRunning()
            return
        }
        
        log("Capturing photo \(currentIteration + 1)/\(totalIterations)")
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .off
        
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    private func log(_ message: String) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        print("[\(timestamp)] \(message)")
    }
}

extension CameraBenchmark: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        
        if let error = error {
            log("Error processing photo: \(error.localizedDescription)")
            return
        }
        
        guard let data = photo.fileDataRepresentation() else {
            log("Failed to get photo data.")
            return
        }
        
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetCreationRequest.forAsset()
            let options = PHAssetResourceCreationOptions()
            request.addResource(with: .photo, data: data, options: options)
        }, completionHandler: { success, error in
            if success {
                self.log("Saved photo \(self.currentIteration + 1)")
            } else {
                self.log("Failed to save photo: \(error?.localizedDescription ?? "unknown error")")
            }
            
            self.currentIteration += 1
            DispatchQueue.main.async {
                self.captureNextPhoto()
            }
        })
    }
}*/
