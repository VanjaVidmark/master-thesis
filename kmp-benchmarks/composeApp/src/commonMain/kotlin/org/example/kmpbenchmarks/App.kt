package org.example.kmpbenchmarks

import ScrollScreen
import VisibilityScreen
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.material.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.launch
import org.jetbrains.compose.ui.tooling.preview.Preview

@Composable
@Preview
fun App(benchmarkRunner: BenchmarkRunner) {
    var currentScreen by remember { mutableStateOf("Tabs") }
    var selectedTab by remember { mutableStateOf("Hardware") }
    val scope = rememberCoroutineScope()

    MaterialTheme {
        when (currentScreen) {
            "Scroll" -> ScrollScreen(onDone = { currentScreen = "Tabs" })
            "Visibility" -> VisibilityScreen(onDone = { currentScreen = "Tabs" })

            else -> Scaffold(
                bottomBar = {
                    BottomNavigation {
                        BottomNavigationItem(
                            selected = selectedTab == "Hardware",
                            onClick = { selectedTab = "Hardware" },
                            label = { Text("Hardware") },
                            icon = { Icon(Icons.Default.Phone, contentDescription = "Hardware") }
                        )
                        BottomNavigationItem(
                            selected = selectedTab == "UI",
                            onClick = { selectedTab = "UI" },
                            label = { Text("UI") },
                            icon = { Icon(Icons.Default.Person, contentDescription = "UI") }
                        )
                        BottomNavigationItem(
                            selected = selectedTab == "Other",
                            onClick = { selectedTab = "Other" },
                            label = { Text("Other") },
                            icon = { Icon(Icons.Default.Menu, contentDescription = "Other") }
                        )
                    }
                }
            ) {
                when (selectedTab) {

                    "Hardware" -> Column(
                        modifier = Modifier.fillMaxSize(),
                        verticalArrangement = Arrangement.Center,
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Text("Measure execution times")
                        Button(onClick = {
                            scope.launch { benchmarkRunner.run("FileReadTime") }
                        }) { Text("Run File Read Benchmark") }

                        Button(onClick = {
                            scope.launch { benchmarkRunner.run("FileWriteTime") }
                        }) { Text("Run File Write Benchmark") }

                        Button(onClick = {
                            scope.launch { benchmarkRunner.run("CameraTime") }
                        }) { Text("Run Camera Benchmark") }

                        Spacer(modifier = Modifier.height(24.dp))
                        Text("Measure CPU and memory")
                        Button(onClick = {
                            scope.launch { benchmarkRunner.run("FileReadPerformance") }
                        }) { Text("Run File Read Benchmark") }

                        Button(onClick = {
                            scope.launch { benchmarkRunner.run("FileWritePerformance") }
                        }) { Text("Run File Write Benchmark") }

                        Button(onClick = {
                            scope.launch { benchmarkRunner.run("CameraPerformance") }
                        }) { Text("Run Camera Benchmark") }
                    }

                    "UI" -> Column(
                        modifier = Modifier.fillMaxSize(),
                        verticalArrangement = Arrangement.Center,
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Button(onClick = {
                            scope.launch {
                                benchmarkRunner.run("Scroll")
                                currentScreen = "Scroll"
                            }
                        }) { Text("Run Scroll Benchmark") }

                        Button(onClick = {
                            scope.launch {
                                benchmarkRunner.run("Visibility")
                                currentScreen = "Visibility"
                            }
                        }) { Text("Run Visibility Benchmark") }
                    }

                    "Other" -> Column(
                        modifier = Modifier.fillMaxSize(),
                        verticalArrangement = Arrangement.Center,
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Button(onClick = {
                            scope.launch { benchmarkRunner.run("RequestPermissions") }
                        }) { Text("Request all necessary permissions") }

                        Button(onClick = {
                            scope.launch { benchmarkRunner.run("PreWrite") }
                        }) { Text("Write files for Read Benchmark") }

                        Button(onClick = {
                            scope.launch { benchmarkRunner.run("IdleState") }
                        }) { Text("Sample Idle State Memory") }
                    }
                }
            }
        }
    }
}
