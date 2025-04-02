package org.example.kmpbenchmarks.file

import kotlinx.cinterop.BetaInteropApi
import kotlinx.cinterop.ExperimentalForeignApi
import kotlinx.cinterop.memScoped
import kotlinx.cinterop.refTo
import platform.Foundation.*
import platform.posix.memcpy

private fun fileURL(index: Int): NSURL {
    val paths = NSSearchPathForDirectoriesInDomains(
        directory = NSDocumentDirectory,
        domainMask = NSUserDomainMask,
        expandTilde = true
    )
    val documentsPath = paths.firstOrNull() as? String
        ?: error("Failed to get documents directory")

    val filename = "file_$index.dat"
    return NSURL.fileURLWithPath("$documentsPath/$filename")
}

actual fun write(index: Int, data: ByteArray) {
    val url = fileURL(index)  // samma som swift
    data.toNSData().writeToURL(url, atomically = true)
}

actual fun read(index: Int){
    val url = fileURL(index)
    if (!NSFileManager.defaultManager.fileExistsAtPath(url.path ?: "")) {
        println("File #$index not found")
    } else {
        NSData.dataWithContentsOfURL(url)?.toByteArray()
    }
}


@OptIn(ExperimentalForeignApi::class)
actual fun delete(index: Int) {
    val url = fileURL(index)
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
    val buffer = ByteArray(this.length.toInt())
    memScoped {
        memcpy(buffer.refTo(0), this@toByteArray.bytes, this@toByteArray.length)
    }
    return buffer
}
