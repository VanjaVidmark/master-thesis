package org.example.geolocationKmp

import kotlinx.datetime.Clock
import kotlinx.datetime.Instant

class GeolocationBenchmark {
    private val locationProvider: LocationProvider = getLocationProvider()

    suspend fun runBenchmark(): Long {
        var successfulFetches = 0
        val startTime: Instant = Clock.System.now()

        repeat(10) {
            val location = locationProvider.getCurrentLocation()
            if (location != null) {
                successfulFetches++
            }
        }

        val totalTime = Clock.System.now() - startTime
        return totalTime.inWholeMilliseconds
    }
}

