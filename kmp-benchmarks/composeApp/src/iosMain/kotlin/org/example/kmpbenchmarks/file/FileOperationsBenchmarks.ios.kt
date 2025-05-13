package org.example.kmpbenchmarks.file

import kotlinx.cinterop.BetaInteropApi
import kotlinx.cinterop.ExperimentalForeignApi
import kotlinx.cinterop.autoreleasepool
import kotlinx.cinterop.convert
import kotlinx.cinterop.memScoped
import kotlinx.cinterop.refTo
import platform.Foundation.*
import platform.posix.memcpy

private fun fileURL(index: Int, suffix: String? = null): NSURL {
    val tempDir = NSTemporaryDirectory()
    val filename = if (suffix != null) "file_${index}_${suffix}.dat" else "file_${index}.dat"
    return NSURL.fileURLWithPath("$tempDir$filename")
}

@OptIn(BetaInteropApi::class, ExperimentalForeignApi::class)
actual fun write(index: Int, data: ByteArray, suffix: String?) {
    autoreleasepool {
        val url = fileURL(index, suffix)

        NSFileManager.defaultManager.createFileAtPath(
            path = url.path ?: return@autoreleasepool,
            contents = null,
            attributes = null
        )

        val fileHandle = NSFileHandle.fileHandleForWritingToURL(url, null)
        if (fileHandle == null) {
            println("Failed to open file handle for writing at ${url.path}")
            return@autoreleasepool
        }

        try {
            fileHandle.writeData(data.toNSData())
            fileHandle.synchronizeFile()  // flush write buffer
        } catch (e: Exception) {
            println("Write error at ${url.path}: ${e.message}")
        } finally {
            fileHandle.closeFile()
        }
    }
}

@OptIn(BetaInteropApi::class, ExperimentalForeignApi::class)
actual fun read(index: Int, suffix: String?): ByteArray? {
    return autoreleasepool {
        val url = fileURL(index, suffix)

        if (!NSFileManager.defaultManager.fileExistsAtPath(url.path ?: "")) {
            println("File #$index not found")
            return@autoreleasepool null
        }

        val fileHandle = NSFileHandle.fileHandleForReadingFromURL(url, null)
        if (fileHandle == null) {
            println("Failed to open file handle for reading at ${url.path}")
            return@autoreleasepool null
        }

        try {
            val data = fileHandle.readDataToEndOfFile()
            return@autoreleasepool data.toByteArray()
        } catch (e: Exception) {
            println("Read error at ${url.path}: ${e.message}")
            return@autoreleasepool null
        } finally {
            fileHandle.closeFile()
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

@OptIn(ExperimentalForeignApi::class)
fun NSData.toByteArray(): ByteArray {
    val length = this.length.toInt()
    val byteArray = ByteArray(length)
    memScoped {
        val buffer = byteArray.refTo(0).getPointer(this)
        memcpy(buffer, this@toByteArray.bytes, length.convert())
    }
    return byteArray
}

