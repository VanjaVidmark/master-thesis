package org.example.kmpbenchmarks.file

actual fun write(index: Int, data: ByteArray) {}
actual fun delete(index: Int) {}
actual fun read(index: Int): ByteArray? { return null }