package org.example.geolocationKmp

actual class LocationProvider {
    actual fun checkLocationPermission(): Boolean = true
    actual suspend fun getCurrentLocation(): LocationData? = LocationData(0.0, 0.0)
}
actual fun getLocationProvider(): LocationProvider = LocationProvider()