import Foundation

final class CameraBenchmark {
    private let cameraService = CameraService()
    private let performanceCalculator: HardwarePerformanceCalculator

    init(performanceCalculator: HardwarePerformanceCalculator) {
        self.performanceCalculator = performanceCalculator
    }

    func runBenchmark(warmup: Int, n: Int) async {
        do {
            try await cameraService.prepare()
        } catch {
            print("Camera setup failed: \(error)")
            return
        }

        for i in 0...warmup {
            // warmup round
            try? await cameraService.takeAndSavePhoto()
            print("Saved warmup photo \(i + 1)/\(warmup)")
        }
        
        for i in 0...n {
            // First pass - Measure CPU and Memory
            performanceCalculator.start()
            try? await cameraService.takeAndSavePhoto()
            performanceCalculator.stopAndPost(iteration: i)
            print("Saved photo \(i + 1)/\(n), first pass")
            
            // Second pass - Measure Execution time
            var start = CFAbsoluteTimeGetCurrent()
            try? await cameraService.takeAndSavePhoto()
            let timeElapsed = CFAbsoluteTimeGetCurrent() - start
            performanceCalculator.postTime(duration: timeElapsed)
            print("Saved photo \(i + 1)/\(n), second pass")
        }
        cameraService.stop()
        print("Camera benchmark complete")
    }
}
