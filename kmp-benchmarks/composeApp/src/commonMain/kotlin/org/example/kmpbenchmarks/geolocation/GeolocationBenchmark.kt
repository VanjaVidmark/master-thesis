package org.example.kmpbenchmarks

import kotlin.time.Duration
import kotlin.time.measureTime

data class LocationData(
    val lat: Double,
    val lon: Double
)

expect fun checkLocationPermission(): Boolean
expect suspend fun getCurrentLocation(): LocationData?

class GeolocationBenchmark {
    suspend fun runBenchmark(n: Int): String {
        if (!checkLocationPermission()) {
            return "Location permission not granted"
        }

        var successfulFetches = 0
        val timeResults = mutableListOf<Duration>()
        val metricResults = mutableListOf<String>()

        // First Pass: Measure Execution Time Only
        repeat(n) {
            val elapsedTime = measureTime {
                val location = getCurrentLocation()
                if (location != null) {
                    successfulFetches++
                }
            }
            timeResults.add(elapsedTime)
            println(elapsedTime)
        }

        // Second Pass: Measure Execution Time + Performance Metrics


        // Export performance data to CSV
        // metricMonitor.exportToCSV(metricResults)

        return "Completed $successfulFetches successful location fetches"
    }
}
