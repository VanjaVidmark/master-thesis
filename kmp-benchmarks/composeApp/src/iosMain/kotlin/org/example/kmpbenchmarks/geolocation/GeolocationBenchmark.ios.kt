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

actual suspend fun getCurrentLocation(): LocationData? = suspendCancellableCoroutine { cont ->
    val delegate = LocationDelegate { locationData ->
        if (cont.isActive) {
            cont.resume(locationData)
        }
    }
    locationManager.delegate = delegate
    locationManager.requestLocation()

    cont.invokeOnCancellation {
        locationManager.delegate = null
    }
}
