package org.example.kmpbenchmarks

interface Platform {
    val name: String
}

expect fun getPlatform(): Platform