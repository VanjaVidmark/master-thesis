//
// Copyright © 2017 Gavrilov Daniil
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
// Modified by Vanja Vidmark, 2025.
// Source: https://github.com/dani-gavrilov/GDPerformanceView-Swift/blob/master/GDPerformanceView-Swift/GDPerformanceMonitoring
//
import Foundation
import QuartzCore
import UIKit
import ComposeApp

/// Performance calculator. Uses CADisplayLink to count FPS. Also counts CPU and memory usage.
internal class UiPerformanceCalculator : PerformanceCalculator {

    // MARK: Private Properties
    private var displayLink: CADisplayLink!
    private let linkedFramesList = LinkedFramesList()
    private var startTimestamp: TimeInterval?
    private var previousFrameTimestamp: TimeInterval?
    private let filename: String
    private let serverURL: URL

    // Properties for handing the measuemtents
    private var queue = DispatchQueue(label: "metricHandler", attributes: .concurrent)
    private var buffer = [String]()

    // MARK: Init Methods & Superclass Overriders
    required internal init(serverURL: URL, filename: String) {
        self.serverURL = serverURL
        self.filename = filename
        self.configureDisplayLink()
        self.addMeasurement("\nCPU | FPS | Dropped |Memory (MB) | Timestamp\n---")
    }
}

// MARK: Public Methods

internal extension UiPerformanceCalculator {
    /// Starts performance monitoring.
    func start() {
        self.startTimestamp = Date().timeIntervalSince1970
        self.displayLink?.isPaused = false
    }

    /// Pauses performance monitoring.
    func stopAndPost() {
        self.displayLink?.isPaused = true
        self.startTimestamp = nil
        self.stopAndSendMetrics()
    }
    
    func sampleTime(duration: Double) {}

    func postTimes() {}
    
}

// MARK: Timer Actions

private extension UiPerformanceCalculator {
    @objc func displayLinkAction(displayLink: CADisplayLink) {
        // triggered every time the screen refreshes
        self.linkedFramesList.append(frameWithTimestamp: displayLink.timestamp)
        self.takePerformanceEvidence(timestamp: displayLink.timestamp)
        previousFrameTimestamp = displayLink.timestamp
    }
}

// MARK: Monitoring

private extension UiPerformanceCalculator {

    func takePerformanceEvidence(timestamp: TimeInterval) {
        let cpuUsage = self.cpuUsage()
        let fps = self.linkedFramesList.count
        let dropped = self.droppedFrames(currentTimestamp: timestamp)
        let memoryUsage = self.memoryUsage()
        let measurement = "\(cpuUsage) | \(fps) | \(dropped) | \(memoryUsage) | \(timestamp)"
        self.addMeasurement(measurement)
    }

    func cpuUsage() -> Double {
        var totalUsageOfCPU: Double = 0.0
        var threadsList: thread_act_array_t?
        var threadsCount = mach_msg_type_number_t(0)
        let threadsResult = withUnsafeMutablePointer(to: &threadsList) {
            return $0.withMemoryRebound(to: thread_act_array_t?.self, capacity: 1) {
                task_threads(mach_task_self_, $0, &threadsCount)
            }
        }

        if threadsResult == KERN_SUCCESS, let threadsList = threadsList {
            for index in 0..<threadsCount {
                var threadInfo = thread_basic_info()
                var threadInfoCount = mach_msg_type_number_t(THREAD_INFO_MAX)
                let infoResult = withUnsafeMutablePointer(to: &threadInfo) {
                    $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                        thread_info(threadsList[Int(index)], thread_flavor_t(THREAD_BASIC_INFO), $0, &threadInfoCount)
                    }
                }

                guard infoResult == KERN_SUCCESS else {
                    break
                }

                let threadBasicInfo = threadInfo as thread_basic_info
                if threadBasicInfo.flags & TH_FLAGS_IDLE == 0 {
                    totalUsageOfCPU = (totalUsageOfCPU + (Double(threadBasicInfo.cpu_usage) / Double(TH_USAGE_SCALE) * 100.0))
                }
            }
        }

        vm_deallocate(mach_task_self_, vm_address_t(UInt(bitPattern: threadsList)), vm_size_t(Int(threadsCount) * MemoryLayout<thread_t>.stride))
        return totalUsageOfCPU
    }

    func droppedFrames(currentTimestamp: TimeInterval) -> Int {
        guard let previous = previousFrameTimestamp else {
            return 0
        }
        
        let delta = currentTimestamp - previous
        let frameBudget = 1.0 / 60.0  // 60Hz = ~16.67ms
        let drops = Int((delta / frameBudget).rounded(.down)) - 1
        return max(drops, 0)
    }

    func memoryUsage() -> Double {
        var taskInfo = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info>.size) / 4
        let result: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
            }
        }

        var used: Double = 0
        if result == KERN_SUCCESS {
            //used = UInt64(taskInfo.phys_footprint)
            used = Double(taskInfo.phys_footprint)
        }

        let usedInMegaBytes = used / 1048576.0 // (= 1024*1024)

        return usedInMegaBytes
    }

}

// MARK: Configurations

private extension UiPerformanceCalculator {
    func configureDisplayLink() {
        self.displayLink = CADisplayLink(target: self, selector: #selector(UiPerformanceCalculator.displayLinkAction(displayLink:)))
        self.displayLink.isPaused = true
        self.displayLink?.add(to: .current, forMode: .common)

        let maxFps = UIScreen.main.maximumFramesPerSecond
        print("Displaylink is configured. Max FPS is \(maxFps) FPS.")

        let totalInMegaBytes = Double(ProcessInfo.processInfo.physicalMemory) / 1048576.0 // (= 1024*1024)
        print("Total memory in MegaBytes is \(totalInMegaBytes)\n")
    }

    func addMeasurement(_ string: String) {
        queue.async(flags: .barrier) {
            self.buffer.append(string)
        }
    }

    func stopAndSendMetrics() {
        // Ensure all writes are done before posting
        queue.sync(flags: .barrier) {
            let header = "\n--- NEW BENCHMARK RUN ---\n"
            let allMetrics = buffer.joined(separator: "\n")
            postToServer(metrics: header + allMetrics, filename: filename)
        }
    }

    private func postToServer(metrics: String, filename: String) {
        var request = URLRequest(url: serverURL)
        request.httpMethod = "POST"
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        request.setValue(filename, forHTTPHeaderField: "Filename")
        request.setValue("append", forHTTPHeaderField: "Write-Mode")
        request.httpBody = metrics.data(using: .utf8)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to upload metrics: \(error)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Metrics uploaded: \(httpResponse.statusCode)")
            }
        }
        task.resume()
    }
}
