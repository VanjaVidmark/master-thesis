package org.example.kmpbenchmarks

import platform.Foundation.NSProcessInfo

actual fun getTime(): Double {
    return NSProcessInfo.processInfo.systemUptime
}
