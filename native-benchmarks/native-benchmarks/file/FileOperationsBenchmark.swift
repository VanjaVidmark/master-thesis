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
    private let performanceCalculator : HardwarePerformanceCalculator
    private let data: Data
    
    init(performanceCalculator: HardwarePerformanceCalculator) {
        self.performanceCalculator = performanceCalculator
        self.baseURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let sizeInMB = 10
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
    
    func runWriteBenchmark(n: Int, measureTime: Bool) {
        // warmup rounds
        for i in 0..<10 {
            self.write(index: i, data: data)
        }
        // measurement rounds
        if measureTime {
            for i in 10..<n {
                performanceCalculator.sampleTime("\(i) start")
                self.write(index: i, data: data)
                performanceCalculator.sampleTime("\(i) end")
            }
            performanceCalculator.postTimeSamples()
        } else {
            performanceCalculator.start()
            for i in 10..<n {
                self.write(index: i, data: data)
            }
            performanceCalculator.stopAndPost(iteration: 1)
        }
        print("\(n) files written")
    }
    
    func runReadBenchmark(n: Int, measureTime: Bool) {
        // warmup rounds
        for i in 0..<10 {
            self.read(index: i)
        }
        // measurement rounds
        if measureTime {
            for i in 10..<n {
                performanceCalculator.sampleTime("\(i) start")
                self.read(index: i)
                performanceCalculator.sampleTime("\(i) end")
            }
            performanceCalculator.postTimeSamples()
        } else {
            performanceCalculator.start()
            for i in 10..<n {
                self.read(index: i)
            }
            performanceCalculator.stopAndPost(iteration: 1)
        }
        print("\(n) files read")
    }
    
    func runDeleteBenchmark(n: Int, measureTime: Bool) {
        // warmup rounds
        for i in 0..<10 {
            self.read(index: i)
        }
        // measurement rounds
        if measureTime {
            for i in 10..<n {
                performanceCalculator.sampleTime("\(i) start")
                self.delete(index: i)
                performanceCalculator.sampleTime("\(i) end")
            }
            performanceCalculator.postTimeSamples()
        } else {
            performanceCalculator.start()
            for i in 10..<n {
                self.delete(index: i)
            }
            performanceCalculator.stopAndPost(iteration: 1)
        }
        print("\(n) files deleted")
    }
}
