import Foundation
import CoreLocation

struct LocationData {
    let lat: Double
    let lon: Double
}

class GeolocationBenchmark: NSObject, CLLocationManagerDelegate {
    private let locationManager: CLLocationManager
    private var continuation: CheckedContinuation<LocationData?, Never>?

    override init() {
        self.locationManager = CLLocationManager()
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
    }

    private func hasPermission() -> Bool {
        let status = locationManager.authorizationStatus
        return status == .authorizedWhenInUse || status == .authorizedAlways
    }

    func getCurrentLocation() async -> LocationData? {
        return await withCheckedContinuation { cont in
            self.continuation = cont
            locationManager.requestLocation()
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
        print("Location error: \(error.localizedDescription)")
        continuation?.resume(returning: nil)
        continuation = nil
    }

    func runBenchmark(n: Int) async {
        print("Inside Swift Geolocation Benchmark")

        guard hasPermission() else {
            print("Location permission not granted or still pending")
            return
        }

        var successfulFetches = 0

        for i in 0..<n {
            print("Fetching location \(i)")
            if let location = await getCurrentLocation() {
                print("Fetched location: \(location)")
                successfulFetches += 1
            } else {
                print("Failed to fetch location")
            }

            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s delay
        }

        print("Completed \(successfulFetches) successful location fetches")
    }
}
