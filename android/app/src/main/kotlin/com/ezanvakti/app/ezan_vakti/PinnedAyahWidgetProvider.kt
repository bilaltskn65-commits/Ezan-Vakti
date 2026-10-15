package com.ezanvakti.app.ezan_vakti

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

class PinnedAyahWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        fun updateAllWidgets(context: Context) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val thisWidget = ComponentName(context, PinnedAyahWidgetProvider::class.java)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget)
            for (appWidgetId in appWidgetIds) {
                updateAppWidget(context, appWidgetManager, appWidgetId)
            }
        }

        private fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val views = RemoteViews(context.packageName, R.layout.pinned_ayah_app_widget)

            // Open app on widget tap
            val openIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                putExtra("tab", 1) // Quran tab
            }
            val pOpen = PendingIntent.getActivity(
                context, 401, openIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_pinned_ayah_container, pOpen)

            // Read preferences
            try {
                val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                val arabic = prefs.getString("flutter.pinned_arabic", "فَإِنَّ مَعَ الْعُسْرِ يُسْرًا")
                    ?: "فَإِنَّ مَعَ الْعُسْرِ يُسْرًا"
                val turkish = prefs.getString(
                    "flutter.pinned_turkish",
                    "\"Şüphesiz her güçlükle beraber bir kolaylık vardır.\""
                ) ?: "\"Şüphesiz her güçlükle beraber bir kolaylık vardır.\""
                val surahName = prefs.getString("flutter.pinned_surah", "İnşirah") ?: "İnşirah"
                val ayahNum = (prefs.all["flutter.pinned_ayah"] as? Number)?.toInt() ?: 5

                views.setTextViewText(R.id.tv_pinned_arabic, arabic)
                views.setTextViewText(R.id.tv_pinned_turkish, turkish)
                views.setTextViewText(R.id.tv_pinned_badge, "$surahName • $ayahNum")
            } catch (e: Exception) {
                e.printStackTrace()
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
