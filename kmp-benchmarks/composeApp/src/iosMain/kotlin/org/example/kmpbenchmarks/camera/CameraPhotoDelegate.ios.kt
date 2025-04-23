package org.example.kmpbenchmarks.camera

import platform.AVFoundation.*
import platform.Photos.*
import platform.UIKit.UIImage
import platform.Foundation.NSData
import platform.Foundation.NSError
import platform.darwin.NSObject

class CameraPhotoDelegate(
    private val onSaved: () -> Unit
) : NSObject(), AVCapturePhotoCaptureDelegateProtocol {

    override fun captureOutput(
        output: AVCapturePhotoOutput,
        didFinishProcessingPhoto: AVCapturePhoto,
        error: NSError?
    ) {
        val data: NSData = didFinishProcessingPhoto.fileDataRepresentation() ?: run {
            println("No photo data.")
            onSaved()
            return
        }

        val image = UIImage(data = data)

        PHPhotoLibrary.requestAuthorization { status ->
            if (status == PHAuthorizationStatusAuthorized) {
                PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromImage(image)
                }) { _, _ ->
                    onSaved()
                }
            } else {
                println("Not authorized to save photo.")
                onSaved()
            }
        }
    }
}
