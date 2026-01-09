package com.example.queue_manager

import android.os.Bundle
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import java.io.File
import kotlin.math.sin

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.queue_manager/sensor"
    private var eventSink: EventChannel.EventSink? = null
    private val handler = Handler(Looper.getMainLooper())
    private var runnable: Runnable? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    startReporting()
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                    stopReporting()
                }
            }
        )
    }

    private fun startReporting() {
        runnable = object : Runnable {
            var time = 0.0
            override fun run() {
                val temp = getCpuTemperature(time)
                eventSink?.success(temp)
                time += 0.1
                handler.postDelayed(this, 1000) // Update every second
            }
        }
        handler.post(runnable!!)
    }

    private fun stopReporting() {
        runnable?.let { handler.removeCallbacks(it) }
    }

    private fun getCpuTemperature(time: Double): Double {
        // Try reading from common thermal zones
        // Iterate through thermal zones (usually 0 to 20 depending on device)
        for (i in 0..20) {
            val path = "/sys/class/thermal/thermal_zone$i"
            try {
                val typeFile = File("$path/type")
                val tempFile = File("$path/temp")

                if (typeFile.exists() && tempFile.exists()) {
                    val type = typeFile.readText().trim().lowercase()
                    
                    // Prioritize known CPU thermal zone names
                    if (type.contains("cpu") || type.contains("mtktscpu") || type.contains("ap")) {
                         val content = tempFile.readText().trim()
                         val temp = content.toDoubleOrNull()
                         if (temp != null) {
                             // Standardize: If > 1000, it's millidegrees (e.g., 45000 -> 45.0)
                             return if (temp > 1000) temp / 1000.0 else temp
                         }
                    }
                }
            } catch (e: Exception) {
                // Continue to next zone if permission denied or empty
            }
        }
        
        // Secondary pass: If no explicit CPU sensor found, try zone0 as generic backup
        try {
             val tempFile = File("/sys/class/thermal/thermal_zone0/temp")
             if (tempFile.exists()) {
                 val content = tempFile.readText().trim()
                 val temp = content.toDoubleOrNull()
                 if (temp != null) return if (temp > 1000) temp / 1000.0 else temp
             }
        } catch (e: Exception) {}

        // Fallback: Simulate temperature oscillation between 30C and 80C
        // using a sine wave for demonstration if real sensor is unavailable
        return 55.0 + 25.0 * sin(time)
    }
}
