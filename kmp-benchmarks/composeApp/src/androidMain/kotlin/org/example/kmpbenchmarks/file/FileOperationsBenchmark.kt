package org.example.kmpbenchmarks.file

actual fun write(index: Int, data: ByteArray, suffix: String?) {}
actual fun delete(index: Int, suffix: String?) {}
actual fun read(index: Int, suffix: String?) {}