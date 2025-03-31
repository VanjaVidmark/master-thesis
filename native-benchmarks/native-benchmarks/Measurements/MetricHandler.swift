//
//  MetricHandler.swift
//  iosApp
//
//  Created by Anna Skantz on 2023-03-29.
// OBS jag har gjort stora ändringar sedan anna, lista ut vad jag ska skriva här

import Foundation

class MetricHandler {
    private var queue = DispatchQueue(label: "metricHandler", attributes: .concurrent)
    private var buffer = [String]()
    
    private let benchConfigs: BenchConfigs
    private let serverURL: URL
    
    init(serverURL: URL, configs: BenchConfigs) {
        self.benchConfigs = configs
        self.serverURL = serverURL
        addMeasurement(configs.headerText + configs.headerDescription)
    }
    
    func addMeasurement(_ string: String) {
        queue.async(flags: .barrier) {
            self.buffer.append(string)
        }
    }
    
    func stop() {
        // Ensure all writes are done before posting
        queue.sync(flags: .barrier) {
            let allMetrics = buffer.joined(separator: "\n")
            postToServer(metrics: allMetrics)
        }
    }
    
    private func postToServer(metrics: String) {
        var request = URLRequest(url: serverURL)
        request.httpMethod = "POST"
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        request.setValue(benchConfigs.filename, forHTTPHeaderField: "Filename")
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
