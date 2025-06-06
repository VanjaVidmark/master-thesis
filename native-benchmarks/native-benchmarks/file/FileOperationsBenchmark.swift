//
//  FileOperationsBenchmark.swift
//  native-benchmarks
//
//  Created by Vanja Vidmark on 2025-04-15.
//

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

        do {
            FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil)
            let fileHandle = try FileHandle(forWritingTo: url)
            defer { try? fileHandle.close()}
            try fileHandle.write(contentsOf: data)
            try fileHandle.synchronize()  // flushes write buffers
        } catch {
            print("Write error at \(url.path): \(error)")
        }
    }

    
    func read(index: Int, suffix: String? = nil) -> Data? {
        let url = fileURL(for: index, suffix: suffix)
        guard fileManager.fileExists(atPath: url.path) else {
            print("File not found: \(url.path)")
            return nil
        }
        
        do {
            let fileHandle = try FileHandle(forReadingFrom: url)
            defer { try? fileHandle.close() }
            return try fileHandle.readToEnd()
        } catch {
            print("Read error at \(url.path): \(error)")
            return nil
        }
    }

    func delete(index: Int, suffix: String? = nil) {
        let url = fileURL(for: index, suffix: suffix)
        if !fileManager.fileExists(atPath: url.path) {
            print("File not found: \(url.path)")
        }
        try? fileManager.removeItem(at: url)
    }

    func runWriteBenchmark(warmup: Int, n: Int, measureTime: Bool) {
        for i in 0..<warmup {
            self.write(index: i, data: data, suffix: "write")
            print("Warmup: Wrote file \(i)")
        }
        if measureTime {
            for i in warmup..<n+warmup {
                let start = ProcessInfo.processInfo.systemUptime
                self.write(index: i, data: data, suffix: "write")
                let duration = ProcessInfo.processInfo.systemUptime - start
                performanceCalculator.sampleTime(duration: duration)
                print("Measured time: Wrote file \(i)")
            }
            performanceCalculator.postTimes()
        } else {
            performanceCalculator.start()
            for i in warmup..<n+warmup {
                performanceCalculator.markIteration(i-warmup)
                self.write(index: i, data: data, suffix: "write")
                print("Measured performance: Wrote file \(i)")
            }
            performanceCalculator.stopAndPost()
        }
        for i in 0..<n+warmup {
            self.delete(index: i, suffix: "write")
            print("Deleted file \(i)")
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
            for i in warmup..<n+warmup {
                let start = ProcessInfo.processInfo.systemUptime
                autoreleasepool {
                    _ = read(index: indices[i], suffix: "read")
                }
                let duration = ProcessInfo.processInfo.systemUptime - start
                performanceCalculator.sampleTime(duration: duration)
            }
            performanceCalculator.postTimes()
        } else {
            performanceCalculator.start()
            for i in warmup..<n+warmup {
                performanceCalculator.markIteration(i-warmup)
                autoreleasepool {
                    _ = read(index: indices[i], suffix: "read")
                }
            }
            performanceCalculator.stopAndPost()
        }
        print("File read benchmark done")
    }
}
