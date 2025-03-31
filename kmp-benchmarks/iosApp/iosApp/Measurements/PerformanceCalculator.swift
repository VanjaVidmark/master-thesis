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

/// Performance calculator. Uses CADisplayLink to count FPS. Also counts CPU and memory usage.
internal class PerformanceCalculator {

    // MARK: Private Properties
    private var displayLink: CADisplayLink!
    private let linkedFramesList = LinkedFramesList()
    private var startTimestamp: TimeInterval?
    private var metricHandler: MetricHandler?

    // MARK: Init Methods & Superclass Overriders
    required internal init() {
        self.configureDisplayLink()
    }
}

// MARK: Public Methods

internal extension PerformanceCalculator {
    /// Starts performance monitoring.
    func start(metricHandler: MetricHandler?) {
        self.metricHandler = metricHandler
        self.startTimestamp = Date().timeIntervalSince1970
        self.displayLink?.isPaused = false
    }
    
    /// Pauses performance monitoring.
    func pause() {
        self.displayLink?.isPaused = true
        self.startTimestamp = nil
        self.metricHandler = nil
    }
}

// MARK: Timer Actions

private extension PerformanceCalculator {
    @objc func displayLinkAction(displayLink: CADisplayLink) { 
        // triggered every time the screen refreshes
        self.linkedFramesList.append(frameWithTimestamp: displayLink.timestamp)
        self.takePerformanceEvidence()
    }
}

// MARK: Monitoring

private extension PerformanceCalculator {
    
    func takePerformanceEvidence() {
        let cpuUsage = self.cpuUsage()
        let fps = self.linkedFramesList.count
        let jank = self.linkedFramesList.detectFrameJank()
        let memoryUsage = self.memoryUsage()
        let timestamp = ProcessInfo.processInfo.systemUptime
        let measurement = "\(cpuUsage) | \(fps) | \(jank) | \(memoryUsage) | \(timestamp)"
        
        // TODO: Metrichandler är Annas, skriv om eventuellt.
        if (metricHandler != nil) {
            metricHandler!.addMeasurement(measurement)
        } else {
            print(measurement)
        }
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

private extension PerformanceCalculator {
    func configureDisplayLink() {
        self.displayLink = CADisplayLink(target: self, selector: #selector(PerformanceCalculator.displayLinkAction(displayLink:)))
        self.displayLink.isPaused = true
        self.displayLink?.add(to: .current, forMode: .common)
        
        let maxFps = UIScreen.main.maximumFramesPerSecond
        print("Displaylink is configured. Max FPS is \(maxFps) FPS.")
        
        let totalInMegaBytes = Double(ProcessInfo.processInfo.physicalMemory) / 1048576.0 // (= 1024*1024)
        print("Total memory in MegaBytes is \(totalInMegaBytes)\n")
    }
}
