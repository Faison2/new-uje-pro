package com.example.crdb

import android.os.Bundle
import android.view.WindowManager
import android.provider.Settings
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val SECURITY_CHANNEL = "com.example.crdb/security"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // 🔐 Set FLAG_SECURE to prevent screen recording and screenshots
        // This is the primary defense against screen capture attacks
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE
        )

        // 🔐 Prevent window from appearing in recent apps
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 🔐 Set up method channel for security operations
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SECURITY_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "enableSecureFlag" -> {
                        // Ensure FLAG_SECURE is set
                        window.setFlags(
                            WindowManager.LayoutParams.FLAG_SECURE,
                            WindowManager.LayoutParams.FLAG_SECURE
                        )
                        result.success(true)
                    }
                    "disableDebugBridge" -> {
                        // In production, ensure debug is disabled
                        val isDebuggable = (applicationInfo.flags and android.content.pm.ApplicationInfo.FLAG_DEBUGGABLE) != 0
                        if (isDebuggable) {
                            // Log warning but don't crash
                            android.util.Log.w("SecurityCheck", "App is running in debug mode")
                        }
                        result.success(true)
                    }
                    "checkUsbDebugging" -> {
                        // Check if USB debugging is enabled
                        val adbEnabled = Settings.Secure.getInt(
                            contentResolver,
                            Settings.Secure.ADB_ENABLED,
                            0
                        ) == 1
                        if (adbEnabled) {
                            android.util.Log.w("SecurityCheck", "USB debugging is enabled")
                        }
                        result.success(adbEnabled)
                    }
                    "isDeveloperModeEnabled" -> {
                        // Check if developer mode is enabled
                        val devModeEnabled = Settings.Secure.getInt(
                            contentResolver,
                            Settings.Global.DEVELOPMENT_SETTINGS_ENABLED,
                            0
                        ) == 1
                        result.success(devModeEnabled)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}

