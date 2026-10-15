package com.ezanvakti.app.ezan_vakti

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import org.json.JSONObject
import java.util.Calendar

class PrayerWidgetProvider : AppWidgetProvider() {

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
            val thisWidget = ComponentName(context, PrayerWidgetProvider::class.java)
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
            val views = RemoteViews(context.packageName, R.layout.prayer_app_widget)

            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val pendingIntent = PendingIntent.getActivity(
                context,
                101,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)

            try {
                val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                val location = prefs.getString("flutter.cached_prayer_times_location", "Balıkesir, Türkiye")
                val jsonStr = prefs.getString("flutter.cached_prayer_times_json", null)

                views.setTextViewText(R.id.tv_widget_location, location ?: "Ezan Vakti")

                var imsak = "05:30"
                var gunes = "06:55"
                var ogle = "13:00"
                var ikindi = "16:15"
                var aksam = "18:50"
                var yatsi = "20:10"

                if (jsonStr != null) {
                    val root = JSONObject(jsonStr)
                    val data = root.optJSONObject("data")
                    val timings = data?.optJSONObject("timings")

                    if (timings != null) {
                        imsak = cleanTime(timings.optString("Fajr", imsak))
                        gunes = cleanTime(timings.optString("Sunrise", gunes))
                        ogle = cleanTime(timings.optString("Dhuhr", ogle))
                        ikindi = cleanTime(timings.optString("Asr", ikindi))
                        aksam = cleanTime(timings.optString("Maghrib", aksam))
                        yatsi = cleanTime(timings.optString("Isha", yatsi))
                    }
                }

                views.setTextViewText(R.id.tv_time_imsak, imsak)
                views.setTextViewText(R.id.tv_time_gunes, gunes)
                views.setTextViewText(R.id.tv_time_ogle, ogle)
                views.setTextViewText(R.id.tv_time_ikindi, ikindi)
                views.setTextViewText(R.id.tv_time_aksam, aksam)
                views.setTextViewText(R.id.tv_time_yatsi, yatsi)

                val allPills = listOf(
                    R.id.pill_imsak to R.id.tv_title_imsak,
                    R.id.pill_gunes to R.id.tv_title_gunes,
                    R.id.pill_ogle to R.id.tv_title_ogle,
                    R.id.pill_ikindi to R.id.tv_title_ikindi,
                    R.id.pill_aksam to R.id.tv_title_aksam,
                    R.id.pill_yatsi to R.id.tv_title_yatsi
                )

                for ((pillId, titleId) in allPills) {
                    views.setInt(pillId, "setBackgroundResource", R.drawable.widget_prayer_pill_bg)
                    views.setTextColor(titleId, android.graphics.Color.parseColor("#94A3B8"))
                }

                val nextPrayer = getNextPrayerDetails(imsak, gunes, ogle, ikindi, aksam, yatsi)

                // Highlight active upcoming prayer pill
                views.setInt(nextPrayer.pillId, "setBackgroundResource", R.drawable.widget_prayer_pill_active_bg)
                views.setTextColor(nextPrayer.titleId, android.graphics.Color.parseColor("#10B981"))

                // Populate hero card and top status badge
                views.setTextViewText(R.id.tv_widget_hero_title, "${nextPrayer.name} • ${nextPrayer.time}")
                views.setTextViewText(R.id.tv_widget_hero_countdown, "${nextPrayer.countdown} kaldı")
                views.setTextViewText(R.id.tv_widget_next, "${nextPrayer.name}: ${nextPrayer.countdown}")

            } catch (e: Exception) {
                e.printStackTrace()
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        private fun cleanTime(raw: String): String {
            return if (raw.contains(" ")) raw.split(" ")[0] else raw
        }

        data class PrayerTarget(
            val name: String,
            val time: String,
            val countdown: String,
            val pillId: Int,
            val titleId: Int
        )

        private fun getNextPrayerDetails(
            imsak: String, gunes: String, ogle: String, ikindi: String, aksam: String, yatsi: String
        ): PrayerTarget {
            val cal = Calendar.getInstance()
            val nowMinutes = cal.get(Calendar.HOUR_OF_DAY) * 60 + cal.get(Calendar.MINUTE)

            val targets = listOf(
                PrayerTarget("İmsak", imsak, "", R.id.pill_imsak, R.id.tv_title_imsak),
                PrayerTarget("Güneş", gunes, "", R.id.pill_gunes, R.id.tv_title_gunes),
                PrayerTarget("Öğle", ogle, "", R.id.pill_ogle, R.id.tv_title_ogle),
                PrayerTarget("İkindi", ikindi, "", R.id.pill_ikindi, R.id.tv_title_ikindi),
                PrayerTarget("Akşam", aksam, "", R.id.pill_aksam, R.id.tv_title_aksam),
                PrayerTarget("Yatsı", yatsi, "", R.id.pill_yatsi, R.id.tv_title_yatsi)
            )

            for (target in targets) {
                val m = toMinutes(target.time)
                if (m > nowMinutes) {
                    val diff = m - nowMinutes
                    val hours = diff / 60
                    val mins = diff % 60
                    val cd = if (hours > 0) "$hours sa $mins dk" else "$mins dk"
                    return target.copy(countdown = cd)
                }
            }

            val fajrM = toMinutes(imsak) + 24 * 60
            val diff = fajrM - nowMinutes
            val hours = diff / 60
            val mins = diff % 60
            val cd = if (hours > 0) "$hours sa $mins dk" else "$mins dk"
            return targets[0].copy(countdown = cd)
        }

        private fun toMinutes(timeStr: String): Int {
            return try {
                val parts = timeStr.split(":")
                parts[0].trim().toInt() * 60 + parts[1].trim().toInt()
            } catch (e: Exception) {
                0
            }
        }
    }
}
