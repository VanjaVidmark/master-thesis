package org.example.geolocationKmp

import platform.CoreLocation.*
import platform.Foundation.NSError
import platform.darwin.NSObject
import kotlinx.cinterop.ExperimentalForeignApi
import kotlinx.cinterop.useContents
import kotlinx.coroutines.InternalCoroutinesApi
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlin.coroutines.resume

actual class LocationProvider : NSObject(), CLLocationManagerDelegateProtocol {
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

    // CLL location manager = iOS API fpr location tracking
    // Varför suspendcallable coroutine? för att den ska vänta tills man får location svar innan man returnerar resultat
    // detta startar en suspending function, cont = continuation, och suspend pågår tills man kallar
    // cont.resume()

    // delegate = like callback or event listener, notifies when location is retrieved or failed.
    // NSObject = base class for swift objects
    // we define an anonymous class (class without name) Why?
    // 1. because we only need to use it once (no extra work of first making the class then making an instance)
    // 2. it has access to cont, without passing it in as a parameter

    @OptIn(ExperimentalForeignApi::class, InternalCoroutinesApi::class)
    actual suspend fun getCurrentLocation(): LocationData? = suspendCancellableCoroutine { cont ->
        val delegate = object : NSObject(), CLLocationManagerDelegateProtocol {

            override fun locationManager(manager: CLLocationManager, didUpdateLocations: List<*>) {
                val location = didUpdateLocations.lastOrNull() as? CLLocation
                location?.let {
                    val coordinates = it.coordinate.useContents { LocationData(latitude, longitude) }
                    if (cont.isActive) {
                        cont.resume(coordinates)
                    }
                }
            }

            override fun locationManager(manager: CLLocationManager, didFailWithError: NSError) {
                if (cont.isActive) {
                    cont.resume(null)
                }
            }
        }

        locationManager.delegate = delegate
        // when we call requestLocation here, we wait until the iOS device has a result
        // given how we defined the delegate above, when a result is received, it will run one of the
        // two locationManager functions above, which will resume the coroutine and provide the result.
        locationManager.requestLocation()
    }
}

actual fun getLocationProvider(): LocationProvider = LocationProvider()

