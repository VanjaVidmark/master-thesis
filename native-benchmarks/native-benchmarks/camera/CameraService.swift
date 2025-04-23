//
//  CameraService.swift
//  native-benchmarks
//
//  Created by Vanja Vidmark on 2025-04-23.
//

import AVFoundation
import Photos
import UIKit

final class CameraService: NSObject, AVCapturePhotoCaptureDelegate {
    private var captureSession: AVCaptureSession?
    private var photoOutput: AVCapturePhotoOutput?
    private var photoTakenContinuation: CheckedContinuation<Void, Error>?
    private let captureQueue = DispatchQueue(label: "camera-capture-queue")

    func prepare() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            captureQueue.async {
                do {
                    let session = AVCaptureSession()
                    session.sessionPreset = .photo

                    guard let device = AVCaptureDevice.default(for: .video),
                          let input = try? AVCaptureDeviceInput(device: device),
                          session.canAddInput(input) else {
                        throw CameraError.setupFailed
                    }

                    session.addInput(input)

                    let output = AVCapturePhotoOutput()
                    guard session.canAddOutput(output) else {
                        throw CameraError.setupFailed
                    }

                    session.addOutput(output)

                    self.captureSession = session
                    self.photoOutput = output

                    session.startRunning()
                    self.pollCameraReady(retries: 10) {
                        continuation.resume()
                    }

                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func takeAndSavePhoto() async throws {
        guard let photoOutput = self.photoOutput else {
            throw CameraError.captureUnavailable
        }

        return try await withCheckedThrowingContinuation { continuation in
            self.photoTakenContinuation = continuation

            let settings = AVCapturePhotoSettings()
            photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }

    func stop() {
        captureSession?.stopRunning()
        captureSession = nil
        photoOutput = nil
    }

    private func pollCameraReady(retries: Int, completion: @escaping () -> Void) {
        guard let isActive = photoOutput?.connection(with: .video)?.isActive else {
            completion()
            return
        }

        if isActive {
            completion()
        } else if retries > 0 {
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
                self.pollCameraReady(retries: retries - 1, completion: completion)
            }
        } else {
            completion()
        }
    }

    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard error == nil,
              let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            photoTakenContinuation?.resume(throwing: CameraError.captureFailed)
            return
        }

        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { success, error in
            if success {
                self.photoTakenContinuation?.resume()
            } else {
                self.photoTakenContinuation?.resume(throwing: CameraError.saveFailed)
            }
        }
    }

    enum CameraError: Error {
        case setupFailed
        case captureUnavailable
        case captureFailed
        case saveFailed
    }
}
