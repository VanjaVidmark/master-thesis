package org.example.kmpbenchmarks

import ScrollScreen
import VisibilityScreen
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import kotlinx.coroutines.launch
import org.jetbrains.compose.ui.tooling.preview.Preview

@Composable
@Preview
fun App(benchmarkRunner: BenchmarkRunner) {
    var currentScreen by remember { mutableStateOf("Home") } // "Tabs", "Scroll", "Visibility"
    var selectedTab by remember { mutableStateOf("Hardware") } // "Hardware", "UI", "Other"
    val scope = rememberCoroutineScope()

    MaterialTheme {
        when (currentScreen) {
            "Scroll" -> ScrollScreen(onDone = { currentScreen = "Home" })
            "Visibility" -> VisibilityScreen(onDone = { currentScreen = "Home" })

            else -> Scaffold(
                bottomBar = {
                    BottomNavigation(
                        backgroundColor = Color.White,
                        contentColor = Color.DarkGray
                    ) {
                        BottomNavigationItem(
                            selected = selectedTab == "Hardware",
                            onClick = { selectedTab = "Hardware" },
                            label = { Text("Hardware") },
                            icon = { Icon(Icons.Filled.Phone, contentDescription = "Hardware") }
                        )
                        BottomNavigationItem(
                            selected = selectedTab == "UI",
                            onClick = { selectedTab = "UI" },
                            label = { Text("UI") },
                            icon = { Icon(Icons.Filled.Person, contentDescription = "UI") }

                        )
                        BottomNavigationItem(
                            selected = selectedTab == "Other",
                            onClick = { selectedTab = "Other" },
                            label = { Text("Other") },
                            icon = { Icon(Icons.Filled.Menu, contentDescription = "Other") }
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
                        Button(onClick = {
                            scope.launch { benchmarkRunner.run("Camera") }
                        }) { Text("Run Camera Benchmark") }

                        Button(onClick = {
                            scope.launch { benchmarkRunner.run("FileWrite") }
                        }) { Text("Run WRITE file Benchmark") }

                        Button(onClick = {
                            scope.launch { benchmarkRunner.run("FileRead") }
                        }) { Text("Run READ file Benchmark") }
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
                            scope.launch {
                                benchmarkRunner.run("IdleState")
                            }
                        }) { Text("Sample idle state memory") }
                    }
                }
            }
        }
    }
}
