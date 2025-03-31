//
//  MetricHandler.swift
//  iosApp
//
//  Created by Anna Skantz on 2023-03-29.
//

import Foundation

class MetricHandler {
    // FIFO queue to store the metric measurements until they are written to file
    private var queue = DispatchQueue(label: "metricHandler", attributes: .concurrent)
    private var buffer = [String]()
    
    private let benchConfigs: BenchConfigs
    private let fileURL: URL
    
    // Thread for writing the measurements to file
    private var writeToFIleThread: Thread!
    
    // Flag that marks when the benchmark is done
    private var isDone = false
    
    init(fileURL: URL, configs: BenchConfigs) {
        
        self.benchConfigs = configs
        self.fileURL = fileURL
        
        // Start the write thread
        writeToFIleThread = Thread(target: self, selector: #selector(writeToFileLoop), object: nil)
        writeToFIleThread.start()
        addMeasurement(configs.headerText+configs.headerDescription) // Adds header text for the results file
    }
    
    // Add a metric measurement to the queue
    func addMeasurement(_ string: String) {  // The measurements have been manually verified to add the measurements in the correct order (i.e. timestamp is strictly increasing)
        queue.async(flags: .barrier) {
            self.buffer.append(string)
        }
    }
    
    // Continuously poll the queue to write the measurements to file
    @objc private func writeToFileLoop() {
        while !isDone {
            queue.sync(flags: .barrier) {
                // Check if the queue has any contents
                if !buffer.isEmpty {
                    // Open file for appending
                    if let handle = try? FileHandle(forWritingTo: fileURL) {
                        handle.seekToEndOfFile()
                        
                        for string in buffer {
                            handle.write((string + "\n").data(using: .utf8)!)
                        }
                        
                        // Clear buffer
                        buffer.removeAll()
                        
                        // Closing the file
                        handle.closeFile()
                        
                    } else {
                        print("Unable to open file at \(fileURL) for writing")
                    }
                }
            }
            // Wait before polling the queue again
            usleep(1000)
        }
    }
    
    // Stop the write thread when all contents on the queue is consumed and wait for it to terminate
    func stop() {
        
        // Make sure the queue is emptied and all measurements are written to file before stopping the writing thread
        while !buffer.isEmpty {
            usleep(1000)
        }
        
        isDone = true
        writeToFIleThread.cancel()
        // Wait until the thread is canceled before exiting
        while writeToFIleThread.isExecuting {
            Thread.sleep(forTimeInterval: 0.1)
        }
    }
}
