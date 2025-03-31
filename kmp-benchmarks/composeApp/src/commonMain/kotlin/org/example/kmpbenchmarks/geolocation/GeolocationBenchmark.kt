package org.example.kmpbenchmarks.geolocation

data class LocationData(
    val lat: Double,
    val lon: Double
)

expect fun checkLocationPermission(): Boolean
expect suspend fun getCurrentLocation(): LocationData?

class GeolocationBenchmark {
    suspend fun runBenchmark(n: Int) {
        println("Inside kotlin Geolocation Benchmark")
        if (!checkLocationPermission()) {
            println("Location permission not granted")
        }

        var successfulFetches = 0

        repeat(n) {
            println("Fetching location $it")
            val location = getCurrentLocation()
            println("Fetched location: $location")
            if (location != null) {
                successfulFetches++
            }
        }

        println("Completed $successfulFetches successful location fetches")
    }
}
