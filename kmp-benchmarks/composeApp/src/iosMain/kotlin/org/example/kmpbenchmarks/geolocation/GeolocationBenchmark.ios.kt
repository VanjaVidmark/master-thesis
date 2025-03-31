package org.example.kmpbenchmarks.geolocation

import kotlinx.cinterop.ExperimentalForeignApi
import kotlinx.cinterop.useContents
import kotlinx.coroutines.suspendCancellableCoroutine
import platform.CoreLocation.CLLocation
import platform.CoreLocation.CLLocationManager
import platform.CoreLocation.CLLocationManagerDelegateProtocol
import platform.CoreLocation.kCLAuthorizationStatusAuthorizedAlways
import platform.CoreLocation.kCLAuthorizationStatusAuthorizedWhenInUse
import platform.CoreLocation.kCLAuthorizationStatusNotDetermined
import platform.Foundation.NSError
import platform.darwin.NSObject
import kotlin.coroutines.resume

private val locationManager = CLLocationManager()

actual fun checkLocationPermission(): Boolean {
    return when (CLLocationManager.authorizationStatus()) {
        kCLAuthorizationStatusAuthorizedWhenInUse, kCLAuthorizationStatusAuthorizedAlways -> true
        kCLAuthorizationStatusNotDetermined -> {
            locationManager.requestWhenInUseAuthorization()
            false
        }
        else -> false
    }
}

// Singleton delegate to maintain strong reference
@OptIn(ExperimentalForeignApi::class)
private class LocationDelegate(
    private val onLocationReceived: (LocationData?) -> Unit
) : NSObject(), CLLocationManagerDelegateProtocol {

    override fun locationManager(manager: CLLocationManager, didUpdateLocations: List<*>) {
        val location = didUpdateLocations.lastOrNull() as? CLLocation
        location?.let {
            val coordinates = it.coordinate.useContents { LocationData(latitude, longitude) }
            onLocationReceived(coordinates)
        } ?: onLocationReceived(null)
    }

    override fun locationManager(manager: CLLocationManager, didFailWithError: NSError) {
        onLocationReceived(null)
    }
}

@OptIn(ExperimentalForeignApi::class)
actual suspend fun getCurrentLocation(): LocationData? = suspendCancellableCoroutine { cont ->
    val delegate = LocationDelegate { locationData ->
        if (cont.isActive) {
            cont.resume(locationData)
        }
    }
    println("1")
    locationManager.delegate = delegate
    println("2")
    locationManager.requestLocation()
    println("3")

    cont.invokeOnCancellation {
        locationManager.delegate = null
    }
}
