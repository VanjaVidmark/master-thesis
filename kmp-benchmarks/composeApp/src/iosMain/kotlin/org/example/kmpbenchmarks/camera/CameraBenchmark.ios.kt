package org.example.kmpbenchmarks.camera

import kotlinx.cinterop.ExperimentalForeignApi
import kotlinx.coroutines.suspendCancellableCoroutine
import org.example.kmpbenchmarks.PerformanceCalculator
import platform.AVFoundation.*
import platform.Foundation.*
import kotlin.coroutines.resume

private var captureSession: AVCaptureSession? = null
private var photoOutput: AVCapturePhotoOutput? = null
private var delegate: CameraPhotoDelegate? = null
private var calculator: PerformanceCalculator? = null
private var benchmarkFinished: (() -> Unit)? = null

private var measurementRuns: Int = 0
private var warmupRuns: Int = 0
private var totalPhotos: Int = 0
private var photosTaken: Int = 0
private var runStartTime: NSDate? = null
private var measureTimeFlag: Boolean = false

actual suspend fun prepareCameraSessionAndWarmUp() {
    resetState()
    setupSession()
    startSessionAndWarmUp()
}

actual suspend fun runCameraBenchmark(warmup: Int, n: Int, performanceCalculator: PerformanceCalculator) {
    return suspendCancellableCoroutine { cont ->
        println("Camera ready. Starting photo benchmark of $n photos.")
        measurementRuns = n
        warmupRuns = warmup
        totalPhotos = n + warmup
        calculator = performanceCalculator

        benchmarkFinished = {
            println("Camera KMP benchmark complete.")
            cont.resume(Unit)
        }
        captureNextPhoto()
    }
}

private fun resetState() {
    delegate = null
    calculator = null
    benchmarkFinished = null

    measurementRuns = 0
    warmupRuns = 0
    totalPhotos = 0
    photosTaken = 0
    runStartTime = null
    measureTimeFlag = false
}

@OptIn(ExperimentalForeignApi::class)
private fun setupSession() {
    val session = AVCaptureSession()
    session.sessionPreset = AVCaptureSessionPresetPhoto
    captureSession = session

    val device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    val input = AVCaptureDeviceInput.deviceInputWithDevice(device!!, null) as AVCaptureDeviceInput
    if (session.canAddInput(input)) session.addInput(input)

    val output = AVCapturePhotoOutput()
    if (session.canAddOutput(output)) {
        session.addOutput(output)
        photoOutput = output
    }
}

private fun startSessionAndWarmUp() {
    captureSession?.startRunning()

    var retries = 10
    while (photoOutput?.connectionWithMediaType(AVMediaTypeVideo)?.isActive() != true && retries-- > 0) {
        NSRunLoop.currentRunLoop.runUntilDate(
            NSDate.dateWithTimeIntervalSinceNow(0.2)
        )
    }

    if (retries <= 0) {
        println("Camera warm-up failed.")
    }
}

private fun captureNextPhoto() {
    if (totalPhotos - photosTaken <= 0) {
        cleanup()
        benchmarkFinished?.invoke()
        benchmarkFinished = null
        return
    }
    // Starting performance measurements after warmup rounds
    if (!measureTimeFlag && photosTaken >= warmupRuns) {
        calculator?.start()
    }

    // Making time measurements after warmup rounds
    if (measureTimeFlag && photosTaken >= warmupRuns) {
        runStartTime = NSDate()
    }

    val settings = AVCapturePhotoSettings()
    delegate = CameraPhotoDelegate {
        val measuredTime = measureTimeFlag
        println("Photo $photosTaken saved")

        // Firtst pass: Save performance metrics, and measure time next pass
        if (!measuredTime && photosTaken >= warmupRuns) {
            calculator?.stopAndPost(photosTaken - warmupRuns)
            measureTimeFlag = true
        }
        // Second pass: Save time metrics, and measure performance next pass
        if (measuredTime && photosTaken >= warmupRuns) {
            val duration = NSDate().timeIntervalSinceDate(runStartTime!!)
            calculator?.postTime(duration)
            measureTimeFlag = false
            photosTaken++
        }
        // Increment photo count during warmup
        if (photosTaken < warmupRuns) {
            photosTaken++
        }
        captureNextPhoto()
    }

    photoOutput?.capturePhotoWithSettings(settings, delegate!!)
}

private fun cleanup() {
    captureSession?.stopRunning()
    captureSession = null
    photoOutput = null
    calculator = null
}
