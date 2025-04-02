//
//  FileOperationsBenchmark.swift
//  native-benchmarks
//
//  Created by Vanja Vidmark on 2025-04-01.
//

import Foundation

class FileOperationsBenchmark {
    private let fileManager = FileManager.default
    private let baseURL: URL
    private let performanceCalculator : PerformanceCalculator
    private let data: Data
    
    init(performanceCalculator: PerformanceCalculator) {
        self.performanceCalculator = performanceCalculator
        self.baseURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let sizeInMB = 50
        self.data = Data(count: sizeInMB * 1024 * 1024)
    }

    private func fileURL(for index: Int) -> URL {
        baseURL.appendingPathComponent("benchmark_\(index).bin")
    }

    func write(index: Int, data: Data) {
        let url = fileURL(for: index)
        try? data.write(to: url, options: .atomic)
    }
    
    func read(index: Int){
        let url = fileURL(for: index)
        try? Data(contentsOf: url)
    }
    
    func delete(index: Int) {
        let url = fileURL(for: index)
        try? fileManager.removeItem(at: url)
    }
    
    func runWriteBenchmark(n: Int) {
        performanceCalculator.start()
        let startTime = Date()
        for i in 0..<n {
            self.write(index: i, data: data)
        }
        print("\(n) files written")
        
        let duration = Date().timeIntervalSince(startTime)
        print("File write completed in \(duration) seconds.")
        
        performanceCalculator.pause()
    }
    
    func runReadBenchmark(n: Int) {
        
        performanceCalculator.start()
        let startTime = Date()
        
        for i in 0..<n {
            self.read(index: i)
        }
        print("\(n) files read")
        
        let duration = Date().timeIntervalSince(startTime)
        print("File read completed in \(duration) seconds.")
        
        performanceCalculator.pause()
    }
    
    func runDeleteBenchmark(n: Int) {
        
        performanceCalculator.start()
        let startTime = Date()
        
        for i in 0..<n {
            self.delete(index: i)
        }
        print("\(n) files deleted")
        
        let duration = Date().timeIntervalSince(startTime)
        print("File delete completed in \(duration) seconds.")
        
        performanceCalculator.pause()
    }
}
