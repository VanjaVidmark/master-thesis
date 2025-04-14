package org.example.kmpbenchmarks.camera

import kotlinx.cinterop.ExperimentalForeignApi
import kotlinx.coroutines.suspendCancellableCoroutine
import org.example.kmpbenchmarks.PerformanceCalculator
import platform.AVFoundation.*
import platform.Foundation.*
import kotlin.coroutines.resume

private var captureSession: AVCaptureSession? = null
private var photoOutput: AVCapturePhotoOutput? = null
private var totalPhotos: Int = 0
private var photosTaken: Int = 0
private var measureTimeFlag: Boolean = false
private var calculator: PerformanceCalculator? = null
private var benchmarkFinished: (() -> Unit)? = null

actual suspend fun prepareCameraSessionAndWarmUp() {
    setupSession()
    startSessionAndWarmUp()
}

actual suspend fun runCameraBenchmark(n: Int, measureTime: Boolean, performanceCalculator: PerformanceCalculator) {
    return suspendCancellableCoroutine { cont ->
        println("Camera ready. Starting photo benchmark of $n photos.")
        totalPhotos = n
        photosTaken = 0
        measureTimeFlag = measureTime
        calculator = performanceCalculator

        benchmarkFinished = {
            if (measureTime) {
                performanceCalculator.postTimeSamples()
            } else {
                performanceCalculator.stopAndPost(iteration = 1)
            }
            println("Camera KMP benchmark complete.")
            cont.resume(Unit)
        }

        takeNextPhoto()
    }
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

private fun takeNextPhoto() {
    if (totalPhotos - photosTaken <= 0) {
        cleanup()
        benchmarkFinished?.invoke()
        benchmarkFinished = null
        return
    }

    if (!measureTimeFlag && photosTaken == 10) {
        calculator?.start()
    }

    if (measureTimeFlag && photosTaken >= 10) {
        calculator?.sampleTime("$photosTaken start")
    }

    val settings = AVCapturePhotoSettings()
    val delegate = CameraPhotoDelegate {
        if (measureTimeFlag && photosTaken >= 10) {
            calculator?.sampleTime("$photosTaken end")
        }
        println("Photo $photosTaken saved")

        photosTaken++
        takeNextPhoto()
    }

    photoOutput?.capturePhotoWithSettings(settings, delegate)
}

private fun cleanup() {
    captureSession?.stopRunning()
    captureSession = null
    photoOutput = null
    calculator = null
}
