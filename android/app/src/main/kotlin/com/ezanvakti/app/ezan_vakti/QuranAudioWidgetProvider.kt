package com.ezanvakti.app.ezan_vakti

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.widget.RemoteViews

class QuranAudioWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        when (intent.action) {
            QuranAudioService.ACTION_PLAY_PAUSE,
            QuranAudioService.ACTION_NEXT,
            QuranAudioService.ACTION_PREV -> {
                val serviceIntent = Intent(context, QuranAudioService::class.java).apply {
                    action = intent.action
                }
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    context.startForegroundService(serviceIntent)
                } else {
                    context.startService(serviceIntent)
                }
            }
        }
    }

    companion object {
        fun updateAllWidgets(context: Context, isPlaying: Boolean? = null, trackTitle: String? = null) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val thisWidget = ComponentName(context, QuranAudioWidgetProvider::class.java)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget)
            for (appWidgetId in appWidgetIds) {
                updateAppWidget(context, appWidgetManager, appWidgetId, isPlaying, trackTitle)
            }
        }

        private fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int,
            overridePlaying: Boolean? = null,
            overrideTitle: String? = null
        ) {
            val views = RemoteViews(context.packageName, R.layout.quran_audio_app_widget)

            // Open app on container click
            val openIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                putExtra("tab", 1) // Quran tab
            }
            val pOpen = PendingIntent.getActivity(
                context, 301, openIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_quran_container, pOpen)

            // Play/Pause Action - directly starts foreground service
            val playIntent = Intent(context, QuranAudioService::class.java).apply {
                action = QuranAudioService.ACTION_PLAY_PAUSE
            }
            val pPlay = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                PendingIntent.getForegroundService(
                    context, 302, playIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
            } else {
                PendingIntent.getService(
                    context, 302, playIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
            }
            views.setOnClickPendingIntent(R.id.btn_play_pause, pPlay)

            // Next Action
            val nextIntent = Intent(context, QuranAudioService::class.java).apply {
                action = QuranAudioService.ACTION_NEXT
            }
            val pNext = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                PendingIntent.getForegroundService(
                    context, 303, nextIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
            } else {
                PendingIntent.getService(
                    context, 303, nextIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
            }
            views.setOnClickPendingIntent(R.id.btn_next_ayah, pNext)

            // Prev Action
            val prevIntent = Intent(context, QuranAudioService::class.java).apply {
                action = QuranAudioService.ACTION_PREV
            }
            val pPrev = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                PendingIntent.getForegroundService(
                    context, 304, prevIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
            } else {
                PendingIntent.getService(
                    context, 304, prevIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
            }
            views.setOnClickPendingIntent(R.id.btn_prev_ayah, pPrev)

            // Read preferences
            val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val playing = overridePlaying ?: prefs.getBoolean("flutter.is_audio_playing", false)
            val surah = prefs.getString("flutter.current_audio_surah", "İnşirah") ?: "İnşirah"
            val ayah = try {
                (prefs.all["flutter.current_audio_ayah"] as? Number)?.toInt() ?: 5
            } catch (e: Exception) { 5 }

            val displayTitle = overrideTitle ?: "$surah, $ayah. Ayet"
            views.setTextViewText(R.id.tv_audio_title, displayTitle)

            if (playing) {
                views.setImageViewResource(R.id.btn_play_pause, R.drawable.ic_widget_pause)
                views.setTextViewText(R.id.tv_audio_status, "Oynatılıyor • Dinlemek için durdurun")
            } else {
                views.setImageViewResource(R.id.btn_play_pause, R.drawable.ic_widget_play)
                views.setTextViewText(R.id.tv_audio_status, "Dokununca doğrudan çalar")
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
