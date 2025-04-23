package org.example.kmpbenchmarks.camera

import kotlinx.cinterop.ExperimentalForeignApi
import kotlinx.coroutines.suspendCancellableCoroutine
import platform.AVFoundation.*
import platform.Foundation.*
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException

private var captureSession: AVCaptureSession? = null
private var photoOutput: AVCapturePhotoOutput? = null
private var delegate: CameraPhotoDelegate? = null

@OptIn(ExperimentalForeignApi::class)
actual suspend fun prepareCameraSession() {
    val session = AVCaptureSession().apply {
        sessionPreset = AVCaptureSessionPresetPhoto
    }

    val device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    val input = AVCaptureDeviceInput.deviceInputWithDevice(device!!, null) as AVCaptureDeviceInput
    if (session.canAddInput(input)) session.addInput(input)

    val output = AVCapturePhotoOutput()
    if (session.canAddOutput(output)) {
        session.addOutput(output)
        photoOutput = output
    }

    captureSession = session
    session.startRunning()

    var retries = 10
    while (photoOutput?.connectionWithMediaType(AVMediaTypeVideo)?.isActive() != true && retries-- > 0) {
        NSRunLoop.currentRunLoop.runUntilDate(NSDate.dateWithTimeIntervalSinceNow(0.2))
    }

    if (retries <= 0) {
        println("Camera warm-up failed.")
    }
}

actual suspend fun takeAndSavePhoto() {
    suspendCancellableCoroutine<Unit> { cont ->
        val output = photoOutput
        if (output == null) {
            cont.resumeWithException(IllegalStateException("Camera not ready"))
            return@suspendCancellableCoroutine
        }

        val settings = AVCapturePhotoSettings()
        delegate = CameraPhotoDelegate {
            cont.resume(Unit)
        }

        output.capturePhotoWithSettings(settings, delegate!!)
    }
}

actual fun stopCameraSession() {
    captureSession?.stopRunning()
    captureSession = null
    photoOutput = null
    delegate = null
}
