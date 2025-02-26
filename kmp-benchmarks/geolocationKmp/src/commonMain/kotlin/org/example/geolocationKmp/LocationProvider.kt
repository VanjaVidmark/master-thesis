package org.example.geolocationKmp

data class LocationData(
    val lat: Double,
    val lon: Double
)

expect class LocationProvider {
    fun checkLocationPermission(): Boolean
    suspend fun getCurrentLocation(): LocationData?
}

expect fun getLocationProvider(): LocationProvider

