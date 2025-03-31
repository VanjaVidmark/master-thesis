package org.example.kmpbenchmarks

actual fun checkLocationPermission(): Boolean = true
actual suspend fun getCurrentLocation(): LocationData? = LocationData(0.0, 0.0)