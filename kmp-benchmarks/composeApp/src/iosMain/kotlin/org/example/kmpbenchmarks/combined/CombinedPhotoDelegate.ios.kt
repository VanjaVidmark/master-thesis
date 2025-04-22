package org.example.kmpbenchmarks.combined

import platform.AVFoundation.*
import platform.Foundation.*
import platform.Photos.*
import platform.UIKit.UIImage
import platform.darwin.NSObject

class CombinedPhotoDelegate(
    private val onSaved: (NSData) -> Unit
) : NSObject(), AVCapturePhotoCaptureDelegateProtocol {

    override fun captureOutput(
        output: AVCapturePhotoOutput,
        didFinishProcessingPhoto: AVCapturePhoto,
        error: NSError?
    ) {
        val data = didFinishProcessingPhoto.fileDataRepresentation() ?: run {
            println("Failed to get image data.")
            onSaved(NSData())
            return
        }

        val image = UIImage(data = data)
        PHPhotoLibrary.requestAuthorization { status ->
            if (status == PHAuthorizationStatusAuthorized) {
                PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromImage(image)
                }) { _, _ ->
                    onSaved(data)
                }
            } else {
                println("Not authorized to save to Photos.")
                onSaved(data)
            }
        }
    }
}
