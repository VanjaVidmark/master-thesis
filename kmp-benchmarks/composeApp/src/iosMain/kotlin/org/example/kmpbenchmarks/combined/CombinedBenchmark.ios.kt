package org.example.kmpbenchmarks.combined

import kotlinx.coroutines.delay
import kotlinx.coroutines.suspendCancellableCoroutine
import platform.AVFoundation.*
import platform.Foundation.*
import platform.UIKit.UIImage
import platform.Photos.*
import kotlin.coroutines.resume
import kotlinx.cinterop.*
import org.example.kmpbenchmarks.UiPerformanceCalculator
import org.example.kmpbenchmarks.file.write
import org.example.kmpbenchmarks.file.read
import org.example.kmpbenchmarks.file.delete

private var runCounter = 0
private var warmup = 0
private var total = 0
private var measurePass = false
private var startTime: NSDate? = null
private var calculator: UiPerformanceCalculator? = null
/*
actual suspend fun runCombinedBenchmark(warmup: Int, n: Int, performanceCalculator: PerformanceCalculator) {
    warmup = warmup
    this.total = warmup + n
    this.runCounter = 0
    this.measurePass = false
    this.calculator = performanceCalculator

    setupCamera()
    startSessionAndWait()

    suspendCancellableCoroutine { cont ->
        takeNextPhoto {
            cleanupCamera()
            cont.resume(Unit)
        }
    }
}

private var session: AVCaptureSession? = null
private var output: AVCapturePhotoOutput? = null
private var delegate: CombinedPhotoDelegate? = null

@OptIn(ExperimentalForeignApi::class)
private fun setupCamera() {
    val s = AVCaptureSession().apply { sessionPreset = AVCaptureSessionPresetPhoto }
    val device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    val input = AVCaptureDeviceInput.deviceInputWithDevice(device!!, null) as AVCaptureDeviceInput
    if (s.canAddInput(input)) s.addInput(input)

    val o = AVCapturePhotoOutput()
    if (s.canAddOutput(o)) {
        s.addOutput(o)
        output = o
    }
    session = s
}

private fun startSessionAndWait() {
    session?.startRunning()
    repeat(10) {
        if (output?.connectionWithMediaType(AVMediaTypeVideo)?.isActive() == true) return
        NSRunLoop.currentRunLoop.runUntilDate(NSDate.dateWithTimeIntervalSinceNow(0.2))
    }
}

private fun takeNextPhoto(onDone: () -> Unit) {
    if (runCounter >= total) {
        onDone()
        return
    }

    if (!measurePass && runCounter >= warmup) calculator?.start()
    if (measurePass && runCounter >= warmup) startTime = NSDate()

    delegate = CombinedPhotoDelegate { imageData ->
        val index = runCounter
        val pass = if (!measurePass) "pass1" else "pass2"

        // Save to file
        write(index, imageData.toByteArray(), pass)

        if (!measurePass && runCounter >= warmup) {
            calculator?.stopAndPost(index - warmup)
        } else if (measurePass && runCounter >= warmup) {
            val duration = NSDate().timeIntervalSinceDate(startTime!!)
            calculator?.postTime(duration)
        }

        // Read back the image
        read(index, pass)

        // Clean up
        delete(index, pass)

        if (measurePass) runCounter++
        measurePass = !measurePass

        takeNextPhoto(onDone)
    }

    val settings = AVCapturePhotoSettings()
    output?.capturePhotoWithSettings(settings, delegate!!)
}
*/

