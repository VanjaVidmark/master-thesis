package org.example.kmpbenchmarks

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.material.Button
import androidx.compose.material.MaterialTheme
import androidx.compose.material.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import kotlinx.coroutines.launch
import org.example.geolocationKmp.GeolocationBenchmark
import org.jetbrains.compose.ui.tooling.preview.Preview
import org.example.geolocationKmp.getLocationProvider

@Composable
@Preview
fun App() {
    val locationProvider = remember { getLocationProvider() }
    val benchmark = remember { GeolocationBenchmark() }
    var locationText by remember { mutableStateOf("Press the button to get location") }
    var benchmarkText by remember { mutableStateOf("Press the button to get location") }
    val scope = rememberCoroutineScope() // needed to run suspend function

    suspend fun runGeolocation(): String? {
        return if (locationProvider.checkLocationPermission()) {
            locationProvider.getCurrentLocation()?.let { location ->
                "Latitude: ${location.lat}, Longitude: ${location.lon}"
            }
        } else {
            "Location permission not granted"
        }
    }

    suspend fun runBenchmark(): String {
        return if (locationProvider.checkLocationPermission()) {
            benchmark.runBenchmark().let { time ->
                "Benchmark completed in ${time}ms"
            }
        } else {
            "Benchmark failed"
        }
    }

    MaterialTheme {
        Column(Modifier.fillMaxWidth(), horizontalAlignment = Alignment.CenterHorizontally) {

            Button(onClick = {
                scope.launch {
                    val result = runGeolocation()
                    locationText = result ?: "Failed to retrieve location"
                }
            }) {
                Text("Geolocation")
            }
            Text(locationText)

            Button(onClick = {
                scope.launch {
                    val result = runBenchmark()
                    benchmarkText = result
                }
            }) {
                Text("Geo benchmark")
            }
            Text(benchmarkText)

        }
    }
}

