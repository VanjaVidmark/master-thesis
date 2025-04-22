# Master Thesis – Performance Evaluation of Kotlin Multiplatform on iOS
### Comparing Kotlin and Compose Multiplatform with Native Swift for UI Animations and Hardware Interactions

This repository contains all code, data, and analysis scripts used in my master's thesis project. The goal of the thesis is to benchmark and compare performance characteristics of common operations (UI and hardware-related) across **Kotlin Multiplatform**, **Compose Multiplatform**  and **native Swift** implementations.

---

## 📁 Repository Structure

### `kmp-benchmarks/`
Cross-platform benchmark application built using **Kotlin Multiplatform** and **Compose Multiplatform**.

- `composeApp/`  
  Contains all shared Kotlin code, including:
  - An application home page where each benhcmark can be run from, written in Compose Multiplatform
  - All benchmark implementations in Kotlin/Compose
  - Platform-specific expect/actual logic where needed, to use iOS native API's

- `iosApp/`  
  Contains the iOS-specific entry point, and logic to record performance measurements.


### `native-benchmarks/`
Standalone benchmark application written in **Swift** for iOS, serving as the native baseline.
- An application home page where each benhcmark can be run from, written in Swift
- Contains all benchmark implementations in Swift/SwiftUI
- Measurement logic written in native Swift (same logic as the iosApp in the kmp-benchmark application)

### `data/`
Includes all result data and post-processing scripts.

- Raw measurements exported from the benchmark apps
- Scripts for data parsing, visualization, and statistical analysis

---
