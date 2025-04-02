//
//  GeolocationBenchmark.swift
//  native-benchmarks
//
//  Created by Vanja Vidmark on 2025-03-31.
//

import Foundation
import CoreLocation

struct LocationData {
    let lat: Double
    let lon: Double
}

class GeolocationBenchmark: NSObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager?
    private var continuation: CheckedContinuation<LocationData?, Never>?

    func checkLocationPermission() -> Bool {
        let status = locationManager?.authorizationStatus ?? .notDetermined

        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            return true
        case .notDetermined:
            locationManager = CLLocationManager()
            locationManager?.requestWhenInUseAuthorization()
            return false
        default:
            return false
        }
    }

    func getCurrentLocation() async -> LocationData? {
        return await withCheckedContinuation { cont in
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            continuation = cont
            locationManager?.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else {
            continuation?.resume(returning: nil)
            continuation = nil
            return
        }

        let data = LocationData(lat: loc.coordinate.latitude, lon: loc.coordinate.longitude)
        continuation?.resume(returning: data)
        continuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error)")
        continuation?.resume(returning: nil)
        continuation = nil
    }

    func runBenchmark(n: Int) async {

        if !checkLocationPermission() {
            print("Location permission not granted or still pending")
            return
        }

        var successfulFetches = 0

        for i in 0..<n {
            print("Fetching location \(i)")
            let location = await getCurrentLocation()
            print("Fetched location: \(String(describing: location))")
            if location != nil {
                successfulFetches += 1
            }
        }

        print("Completed \(successfulFetches) successful location fetches")
    }
}

