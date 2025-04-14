package org.example.kmpbenchmarks.file

import kotlinx.cinterop.BetaInteropApi
import kotlinx.cinterop.ExperimentalForeignApi
import kotlinx.cinterop.autoreleasepool
import kotlinx.cinterop.memScoped
import kotlinx.cinterop.refTo
import platform.Foundation.*
import platform.posix.memcpy

private fun fileURL(index: Int, suffix: String? = null): NSURL {
    val tempDir = NSTemporaryDirectory()
    val filename = if (suffix != null) "file_${index}_${suffix}.dat" else "file_${index}.dat"
    return NSURL.fileURLWithPath("$tempDir$filename")
}

@OptIn(BetaInteropApi::class)
actual fun write(index: Int, data: ByteArray, suffix: String?) {
    autoreleasepool {
        val url = fileURL(index, suffix)
        data.toNSData().writeToURL(url, atomically = true)
    }
}

@OptIn(BetaInteropApi::class)
actual fun read(index: Int, suffix: String?) {
    val url = fileURL(index, suffix)
    if (!NSFileManager.defaultManager.fileExistsAtPath(url.path ?: "")) {
        println("File #$index not found")
    } else {
        autoreleasepool {
            NSData.dataWithContentsOfURL(url)
        }
    }
}


@OptIn(ExperimentalForeignApi::class)
actual fun delete(index: Int, suffix: String?) {
    val url = fileURL(index, suffix)
    if (!NSFileManager.defaultManager.fileExistsAtPath(url.path ?: "")) {
        println("File #$index not found")
    } else {
        NSFileManager.defaultManager.removeItemAtURL(url, null)
    }
}

@OptIn(ExperimentalForeignApi::class, BetaInteropApi::class)
fun ByteArray.toNSData(): NSData = memScoped {
    NSData.create(
        bytes = this@toNSData.refTo(0).getPointer(this),
        length = this@toNSData.size.toULong()
    )
}
