//
//  FileOperationsBenchmark.swift
//  native-benchmarks
//
//  Created by Vanja Vidmark on 2025-04-01.
//

import Foundation

class FileOperationsBenchmark {
    private let fileManager = FileManager.default
    private let performanceCalculator : HardwarePerformanceCalculator
    private let data: Data
    
    init(performanceCalculator: HardwarePerformanceCalculator) {
        self.performanceCalculator = performanceCalculator
        
        let sizeInMB = 100
        self.data = Data(count: sizeInMB * 1024 * 1024)
    }

    func fileURL(for index: Int, suffix: String? = nil) -> URL {
        let dir = FileManager.default.temporaryDirectory
        let filename = suffix != nil
            ? "file_\(index)_\(suffix!).dat"
            : "file_\(index).dat"
        return dir.appendingPathComponent(filename)
    }

    func write(index: Int, data: Data, suffix: String? = nil) {
        let url = fileURL(for: index, suffix: suffix)
        try? data.write(to: url, options: .atomic)
    }
    
    func read(index: Int, suffix: String? = nil){
        let url = fileURL(for: index, suffix: suffix)
        try? Data(contentsOf: url)
    }
    
    func delete(index: Int, suffix: String? = nil) {
        let url = fileURL(for: index, suffix: suffix)
        try? fileManager.removeItem(at: url)
    }
    
    func runWriteBenchmark(n: Int) {
        // warmup rounds
        for i in 0..<10 {
            self.write(index: i, data: data)
            self.delete(index: i)
        }
        
        // measurement rounds
        for i in 0..<n {
            // First pass - Measure CPU and Memory
            performanceCalculator.start()
            self.write(index: i, data: data, suffix: "pass1")
            performanceCalculator.stopAndPost(iteration: i)
            self.delete(index: i, suffix: "pass1")
            
            // Second pass - Measure Execution Time
            let start = Date().timeIntervalSince1970
            self.write(index: i, data: data, suffix: "pass2")
            let duration = Date().timeIntervalSince1970 - start
            self.delete(index: i, suffix: "pass2")
            performanceCalculator.postTime(duration: duration)
        }
        print("File write done")
    }
    
    func runReadBenchmark(n: Int) {
        // warmup rounds
        for i in 0..<10 {
            self.write(index: i, data: data)
            self.read(index: i)
            self.delete(index: i)
        }
        
        // measurement rounds
        for i in 0..<n {
            // First pass - Measure CPU and Memory
            self.write(index: i, data: data, suffix: "pass1")
            performanceCalculator.start()
            self.read(index: i, suffix: "pass1")
            performanceCalculator.stopAndPost(iteration: i)
            self.delete(index: i, suffix: "pass1")
            
            // Second pass - Measure Execution Time
            self.write(index: i, data: data, suffix: "pass2")
            let start = Date().timeIntervalSince1970
            self.read(index: i, suffix: "pass2")
            let duration = Date().timeIntervalSince1970 - start
            self.delete(index: i, suffix: "pass2")
            performanceCalculator.postTime(duration: duration)
        }
        print("File read done")
    }
}
