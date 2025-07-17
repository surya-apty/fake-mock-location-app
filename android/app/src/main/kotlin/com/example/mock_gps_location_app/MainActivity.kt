package com.example.mock_gps_location_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.provider.Settings
import android.location.LocationManager
import android.location.Location
import android.os.Build
import android.content.Context
import android.app.Activity
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import android.Manifest

class MainActivity: FlutterActivity() {
    private val CHANNEL = "mock_location_service"
    private lateinit var locationManager: LocationManager
    private var isMocking = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startMocking" -> {
                    startMocking(call, result)
                }
                "stopMocking" -> {
                    stopMocking(result)
                }
                "isMockLocationEnabled" -> {
                    result.success(isMockLocationEnabled())
                }
                "isDeveloperModeEnabled" -> {
                    result.success(isDeveloperModeEnabled())
                }
                "isMockLocationAppSelected" -> {
                    result.success(isMockLocationAppSelected())
                }
                "openDeveloperOptions" -> {
                    openDeveloperOptions()
                    result.success(null)
                }
                "openMockLocationSettings" -> {
                    openMockLocationSettings()
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun startMocking(call: MethodChannel.MethodCall, result: MethodChannel.Result) {
        try {
            if (!isDeveloperModeEnabled()) {
                result.error("DEVELOPER_MODE_DISABLED", "Developer mode is not enabled", null)
                return
            }

            if (!isMockLocationAppSelected()) {
                result.error("MOCK_APP_NOT_SELECTED", "This app is not selected as mock location app", null)
                return
            }

            val latitude = call.argument<Double>("latitude") ?: 0.0
            val longitude = call.argument<Double>("longitude") ?: 0.0
            val accuracy = call.argument<Double>("accuracy") ?: 3.0
            val altitude = call.argument<Double>("altitude") ?: 0.0
            val heading = call.argument<Double>("heading") ?: 0.0
            val speed = call.argument<Double>("speed") ?: 0.0

            // Add test provider if not already added
            if (!locationManager.allProviders.contains(LocationManager.GPS_PROVIDER)) {
                locationManager.addTestProvider(
                    LocationManager.GPS_PROVIDER,
                    false, false, false, false, false,
                    true, true, 0, 5
                )
            }

            // Enable test provider
            locationManager.setTestProviderEnabled(LocationManager.GPS_PROVIDER, true)

            // Create mock location
            val mockLocation = Location(LocationManager.GPS_PROVIDER)
            mockLocation.latitude = latitude
            mockLocation.longitude = longitude
            mockLocation.altitude = altitude
            mockLocation.bearing = heading.toFloat()
            mockLocation.speed = speed.toFloat()
            mockLocation.accuracy = accuracy.toFloat()
            mockLocation.time = System.currentTimeMillis()
            mockLocation.elapsedRealtimeNanos = System.nanoTime()

            // Set mock location
            locationManager.setTestProviderLocation(LocationManager.GPS_PROVIDER, mockLocation)
            
            isMocking = true
            result.success(null)
        } catch (e: Exception) {
            result.error("MOCKING_FAILED", "Failed to start mocking: ${e.message}", null)
        }
    }

    private fun stopMocking(result: MethodChannel.Result) {
        try {
            if (locationManager.allProviders.contains(LocationManager.GPS_PROVIDER)) {
                locationManager.setTestProviderEnabled(LocationManager.GPS_PROVIDER, false)
                locationManager.removeTestProvider(LocationManager.GPS_PROVIDER)
            }
            isMocking = false
            result.success(null)
        } catch (e: Exception) {
            result.error("STOP_MOCKING_FAILED", "Failed to stop mocking: ${e.message}", null)
        }
    }

    private fun isMockLocationEnabled(): Boolean {
        return try {
            locationManager.allProviders.contains(LocationManager.GPS_PROVIDER) &&
            locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER)
        } catch (e: Exception) {
            false
        }
    }

    private fun isDeveloperModeEnabled(): Boolean {
        return try {
            Settings.Global.getInt(contentResolver, Settings.Global.DEVELOPMENT_SETTINGS_ENABLED) == 1
        } catch (e: Exception) {
            false
        }
    }

    private fun isMockLocationAppSelected(): Boolean {
        return try {
            val mockLocationApp = Settings.Secure.getString(contentResolver, Settings.Secure.MOCK_LOCATION)
            mockLocationApp == packageName
        } catch (e: Exception) {
            false
        }
    }

    private fun openDeveloperOptions() {
        val intent = Intent(Settings.ACTION_APPLICATION_DEVELOPMENT_SETTINGS)
        startActivity(intent)
    }

    private fun openMockLocationSettings() {
        val intent = Intent(Settings.ACTION_APPLICATION_DEVELOPMENT_SETTINGS)
        startActivity(intent)
    }

    override fun onDestroy() {
        super.onDestroy()
        if (isMocking) {
            stopMocking(MethodChannel.Result { })
        }
    }
} 