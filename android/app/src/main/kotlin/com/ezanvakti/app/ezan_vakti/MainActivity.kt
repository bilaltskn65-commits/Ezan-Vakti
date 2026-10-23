package com.ezanvakti.app.ezan_vakti

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.ezanvakti.app/widget"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "updateWidget", "updatePrayerWidget" -> {
                    PrayerWidgetProvider.updateAllWidgets(applicationContext)
                    result.success(true)
                }
                "updateQuranWidget" -> {
                    QuranAudioWidgetProvider.updateAllWidgets(applicationContext)
                    result.success(true)
                }
                "updatePinnedAyahWidget" -> {
                    PinnedAyahWidgetProvider.updateAllWidgets(applicationContext)
                    result.success(true)
                }
                "updateAllWidgets" -> {
                    PrayerWidgetProvider.updateAllWidgets(applicationContext)
                    QuranAudioWidgetProvider.updateAllWidgets(applicationContext)
                    PinnedAyahWidgetProvider.updateAllWidgets(applicationContext)
                    result.success(true)
                }
                "stopQuranAudioService" -> {
                    QuranAudioService.stopService(applicationContext)
                    result.success(true)
                }
                "isQuranServicePlaying" -> {
                    result.success(QuranAudioService.isServiceRunning)
                }
                "pinWidget" -> {
                    val widgetType = call.argument<String>("type") ?: "prayer"
                    val providerClass = when (widgetType) {
                        "quran" -> QuranAudioWidgetProvider::class.java
                        "ayah" -> PinnedAyahWidgetProvider::class.java
                        else -> PrayerWidgetProvider::class.java
                    }

                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        val appWidgetManager = getSystemService(AppWidgetManager::class.java)
                        val providerComponent = ComponentName(this, providerClass)
                        if (appWidgetManager.isRequestPinAppWidgetSupported) {
                            val pinnedIntent = Intent(this, MainActivity::class.java)
                            val successCallback = PendingIntent.getActivity(
                                this, 501, pinnedIntent,
                                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                            )
                            val pinned = appWidgetManager.requestPinAppWidget(providerComponent, null, successCallback)
                            result.success(pinned)
                        } else {
                            result.success(false)
                        }
                    } else {
                        result.success(false)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    // Keep raw audio resources from being stripped during release builds
    private fun keepRawAudio() {
        val r1 = R.raw.ezan_uyari
        val r2 = R.raw.uyari_kanun
    }
}
