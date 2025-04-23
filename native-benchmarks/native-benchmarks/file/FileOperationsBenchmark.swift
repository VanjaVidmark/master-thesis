import Foundation

class FileOperationsBenchmark {
    private let fileManager = FileManager.default
    private let performanceCalculator: HardwarePerformanceCalculator
    private let data: Data
    
    init(performanceCalculator: HardwarePerformanceCalculator) {
        self.performanceCalculator = performanceCalculator
        let sizeInMB = 100
        self.data = Data(count: sizeInMB * 1024 * 1024)
    }

    func fileURL(for index: Int, suffix: String? = nil) -> URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filename = suffix != nil
            ? "file_\(index)_\(suffix!).dat"
            : "file_\(index).dat"
        return dir.appendingPathComponent(filename)
    }

    func write(index: Int, data: Data, suffix: String? = nil) {
        let url = fileURL(for: index, suffix: suffix)
        try? data.write(to: url, options: .atomic)
    }
    
    func read(index: Int, suffix: String? = nil) -> Data? {
        let url = fileURL(for: index, suffix: suffix)
        if !fileManager.fileExists(atPath: url.path) {
            print("File not found: \(url.lastPathComponent)")
            return nil
        }
        return try? Data(contentsOf: url)
    }
    
    func delete(index: Int, suffix: String? = nil) {
        let url = fileURL(for: index, suffix: suffix)
        try? fileManager.removeItem(at: url)
    }

    func runWriteBenchmark(warmup: Int, n: Int, measureTime: Bool) {
        for i in 0..<warmup {
            self.write(index: i, data: data, suffix: "write")
        }
        if measureTime {
            for i in 0..<n {
                let start = Date().timeIntervalSince1970
                self.write(index: i, data: data, suffix: "write")
                let duration = Date().timeIntervalSince1970 - start
                performanceCalculator.sampleTime(duration: duration)
                print("Wrote file \(i)")
            }
            performanceCalculator.postTimes()
        } else {
            for i in 0..<n {
                performanceCalculator.start()
                self.write(index: i, data: data, suffix: "write")
                performanceCalculator.stopAndPost(iteration: i)
                print("Wrote file \(i)")
            }
        }
        for i in 0..<n {
            self.delete(index: i)
        }
        print("File write benchmark done")
    }
    
    // Writes all files to be read during the read benchmark
    func preWriteFiles(files: Int) {
        for i in 0..<files {
            self.write(index: i, data: data, suffix: "read")
            print("Wrote file \(i), read")
        }
        print("Files pre-written, restart app!")
    }
    
    func runReadBenchmark(warmup: Int, n: Int, measureTime: Bool) {
        let totalFiles = warmup + n
        var indices = Array(0..<totalFiles)
        indices.shuffle()

        // Warmup reads (not measured)
        for i in 0..<warmup {
            let idx = indices[i]
            autoreleasepool {
                _ = read(index: idx, suffix: "read")
            }
        }
        if measureTime {
            for i in 0..<n {
                let idx = indices[i + warmup]
                let start = Date().timeIntervalSince1970
                autoreleasepool {
                    _ = read(index: idx, suffix: "read")
                }
                let duration = Date().timeIntervalSince1970 - start
                performanceCalculator.sampleTime(duration: duration)
            }
            performanceCalculator.postTimes()
        } else {
            for i in 0..<n {
                let idx = indices[i + warmup]
                performanceCalculator.start()
                autoreleasepool {
                    _ = read(index: idx, suffix: "read")
                }
                performanceCalculator.stopAndPost(iteration: i)
            }
        }
        print("File read benchmark done")
    }
}
