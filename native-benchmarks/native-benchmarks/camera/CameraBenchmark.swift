import AVFoundation
import Photos
import UIKit

class CameraBenchmark: NSObject, AVCapturePhotoCaptureDelegate {
    private var captureSession: AVCaptureSession?
    private var photoOutput: AVCapturePhotoOutput?
    private var captureQueue = DispatchQueue(label: "camera-capture-queue")

    private var photosTaken = 0
    private var totalPhotots = 0
    private var benchmarkStartTime: CFAbsoluteTime = 0
    private var benchmarkFinished: (() -> Void)? = nil
    private let performanceCalculator: HardwarePerformanceCalculator
    private var measureTime = false

    init(performanceCalculator: HardwarePerformanceCalculator) {
        self.performanceCalculator = performanceCalculator
    }

    func runBenchmark(n: Int, measureTime: Bool) async {
        self.measureTime = measureTime
        await withCheckedContinuation { continuation in
            captureQueue.async {
                self.prepareSession()
                self.startSessionAndWarmUp {
                    print("Camera ready. Starting photo benchmark of \(n) photos.")

                    self.totalPhotots = n
                    self.benchmarkStartTime = CFAbsoluteTimeGetCurrent()

                    self.benchmarkFinished = {
                        if self.measureTime {
                            self.performanceCalculator.postTimeSamples()
                        } else {
                            self.performanceCalculator.stopAndPost(iteration: 1)
                        }
                        print("Benchmark complete. Took \(self.benchmarkDuration()) seconds.")
                        continuation.resume()
                    }

                    self.captureNextPhoto()
                }
            }
        }
    }

    private func prepareSession() {
        let session = AVCaptureSession()
        session.sessionPreset = .photo
        self.captureSession = session

        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            print("Failed to set up camera input.")
            return
        }
        session.addInput(input)

        let output = AVCapturePhotoOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
            self.photoOutput = output
        }
    }

    private func startSessionAndWarmUp(completion: @escaping () -> Void) {
        guard let session = captureSession else { return }

        session.startRunning()

        var retries = 10
        func pollConnection() {
            if self.photoOutput?.connection(with: .video)?.isActive == true {
                completion()
            } else if retries > 0 {
                retries -= 1
                DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
                    pollConnection()
                }
            } else {
                print("Camera warm-up failed.")
                completion()
            }
        }

        pollConnection()
    }

    private func captureNextPhoto() {
        
        if totalPhotots - photosTaken <= 0 || photoOutput == nil {
            cleanup()
            benchmarkFinished?()
            benchmarkFinished = nil
            return
        }
        // Starting performance measurements after 10 warmup rounds
        if !measureTime && photosTaken == 10 {
            performanceCalculator.start()
        }
        // Making time measurements after 10 warmup rounds
        if measureTime && photosTaken >= 10 {
            performanceCalculator.sampleTime("\(photosTaken) start")
        }
        
        let output = photoOutput!
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }

    private func benchmarkDuration() -> Double {
        CFAbsoluteTimeGetCurrent() - benchmarkStartTime
    }

    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            print("Failed to process photo.")
            return
        }

        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                print("No photo library access.")
                return
            }

            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }) { success, error in
                if success {
                    print("Saved photo \(self.photosTaken)")
                    if self.measureTime && self.photosTaken >= 10 { self.performanceCalculator.sampleTime("\(self.photosTaken) end") }
                    self.photosTaken += 1
                    self.captureQueue.async {
                        self.captureNextPhoto()
                    }
                } else {
                    print("Failed to save image: \(String(describing: error))")
                }
            }
        }
    }

    private func cleanup() {
        captureSession?.stopRunning()
        captureSession = nil
        photoOutput = nil
    }
}
