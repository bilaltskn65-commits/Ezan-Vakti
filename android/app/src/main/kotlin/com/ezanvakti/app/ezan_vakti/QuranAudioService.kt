package com.ezanvakti.app.ezan_vakti

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat

class QuranAudioService : Service() {

    private var mediaPlayer: MediaPlayer? = null
    private var isPlaying = false
    private var surahNum = 94
    private var ayahNum = 5
    private var surahName = "İnşirah"
    private var pendingNextSurah = false

    companion object {
        const val ACTION_PLAY_PAUSE = "com.ezanvakti.app.ACTION_PLAY_PAUSE"
        const val ACTION_NEXT = "com.ezanvakti.app.ACTION_NEXT"
        const val ACTION_PREV = "com.ezanvakti.app.ACTION_PREV"
        const val ACTION_STOP = "com.ezanvakti.app.ACTION_STOP"
        private const val CHANNEL_ID = "quran_audio_playback"
        private const val NOTIF_ID = 2001

        private val SURAH_NAMES = arrayOf(
            "Fatiha", "Bakara", "Âl-i İmrân", "Nisâ", "Mâide", "En'âm", "A'râf", "Enfâl", "Tevbe", "Yûnus",
            "Hûd", "Yûsuf", "Ra'd", "İbrâhîm", "Hicr", "Nahl", "İsrâ", "Kehf", "Meryem", "Tâhâ",
            "Enbiyâ", "Hac", "Mü'minûn", "Nûr", "Furkân", "Şuarâ", "Neml", "Kasas", "Ankebût", "Rûm",
            "Lokmân", "Secde", "Ahzâb", "Sebe'", "Fâtır", "Yâsîn", "Sâffât", "Sâd", "Zümer", "Mü'min",
            "Fussilet", "Şûrâ", "Zuhruf", "Duhân", "Câsiye", "Ahkâf", "Muhammed", "Fetih", "Hucurât", "Kâf",
            "Zâriyât", "Tûr", "Necm", "Kamer", "Rahmân", "Vâkıa", "Hadîd", "Mücâdele", "Haşr", "Mümtehine",
            "Saf", "Cuma", "Münâfikûn", "Tegâbün", "Talâk", "Tahrîm", "Mülk", "Kalem", "Hâkka", "Meâric",
            "Nûh", "Cin", "Müzzemmil", "Müddessir", "Kıyâme", "İnsân", "Mürselât", "Nebe'", "Nâziât", "Abese",
            "Tekvîr", "İnfitâr", "Mutaffifîn", "İnşikâk", "Bürûc", "Târık", "A'lâ", "Gâşiye", "Fecr", "Beled",
            "Şems", "Leyl", "Duhâ", "İnşirâh", "Tîn", "Alak", "Kadr", "Beyyine", "Zilzâl", "Âdiyât",
            "Kâria", "Tekâsür", "Asr", "Hümeze", "Fîl", "Kureyş", "Mâûn", "Kevser", "Kâfirûn", "Nasr",
            "Tebbet", "İhlâs", "Felak", "Nâs"
        )

        private val SURAH_AYAH_COUNTS = intArrayOf(
            7, 286, 200, 176, 120, 165, 206, 75, 129, 109,
            123, 111, 43, 52, 99, 128, 111, 110, 98, 135,
            112, 78, 118, 64, 77, 227, 93, 88, 69, 60,
            34, 30, 73, 54, 45, 83, 182, 88, 75, 85,
            54, 53, 89, 59, 37, 35, 38, 29, 18, 45,
            60, 49, 62, 55, 78, 96, 29, 22, 24, 13,
            14, 11, 11, 18, 12, 12, 30, 52, 52, 44,
            28, 28, 20, 56, 40, 31, 50, 40, 46, 42,
            29, 19, 36, 25, 22, 17, 19, 26, 30, 20,
            15, 21, 11, 8, 8, 19, 5, 8, 8, 11,
            11, 8, 3, 9, 5, 4, 7, 3, 6, 3,
            5, 4, 5, 6
        )

        fun getAyahCount(surah: Int): Int {
            return if (surah in 1..114) SURAH_AYAH_COUNTS[surah - 1] else 10
        }

        fun getSurahName(surah: Int): String {
            return if (surah in 1..114) SURAH_NAMES[surah - 1] else "Sure $surah"
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val action = intent?.action ?: return START_NOT_STICKY

        readPrefs()

        val willPlay = if (action == ACTION_PLAY_PAUSE) !isPlaying else true
        val notif = createNotification(willPlay)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(NOTIF_ID, notif, ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK)
        } else {
            startForeground(NOTIF_ID, notif)
        }

        when (action) {
            ACTION_PLAY_PAUSE -> {
                if (isPlaying) {
                    pauseAudio()
                } else {
                    playAudio()
                }
            }
            ACTION_NEXT -> {
                if (isPlaying) {
                    // Ayet bittikten sonra sonraki sureye geçişi kuyruğa al
                    pendingNextSurah = true
                    android.widget.Toast.makeText(
                        this,
                        "Ayet bitince sonraki sureye geçilecek",
                        android.widget.Toast.LENGTH_SHORT
                    ).show()
                } else {
                    // Duraklatılmışsa veya kapalıysa hemen sonraki sureye geç ve oynat
                    val nextSurah = if (surahNum >= 114) 1 else surahNum + 1
                    saveSurahAndAyah(nextSurah, 1)
                    pendingNextSurah = false
                    playAudio()
                }
            }
            ACTION_PREV -> {
                pendingNextSurah = false
                if (ayahNum > 1) {
                    saveSurahAndAyah(surahNum, ayahNum - 1)
                } else {
                    val prevSurah = if (surahNum <= 1) 114 else surahNum - 1
                    saveSurahAndAyah(prevSurah, 1)
                }
                playAudio()
            }
            ACTION_STOP -> {
                pendingNextSurah = false
                stopAudio()
            }
        }

        return START_NOT_STICKY
    }

    private fun readPrefs() {
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        surahName = prefs.getString("flutter.current_audio_surah", "İnşirah") ?: "İnşirah"
        ayahNum = (prefs.all["flutter.current_audio_ayah"] as? Number)?.toInt() ?: 5
        surahNum = (prefs.all["flutter.current_audio_surah_num"] as? Number)?.toInt() ?: 94
    }

    private fun saveSurahAndAyah(surah: Int, ayah: Int) {
        surahNum = surah
        ayahNum = ayah
        surahName = getSurahName(surah)
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        prefs.edit()
            .putString("flutter.current_audio_surah", surahName)
            .putLong("flutter.current_audio_surah_num", surah.toLong())
            .putLong("flutter.current_audio_ayah", ayah.toLong())
            .apply()
    }

    private fun playAudio() {
        val url = String.format(
            "https://everyayah.com/data/Alafasy_128kbps/%03d%03d.mp3",
            surahNum,
            ayahNum
        )

        try {
            this.isPlaying = true
            updateState(true)
            mediaPlayer?.release()
            mediaPlayer = MediaPlayer().apply {
                setAudioAttributes(
                    AudioAttributes.Builder()
                        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                        .setUsage(AudioAttributes.USAGE_MEDIA)
                        .build()
                )
                setDataSource(url)
                setOnPreparedListener { mp ->
                    mp.start()
                    this@QuranAudioService.isPlaying = true
                    updateState(true)
                    val notif = createNotification(true)
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                        startForeground(NOTIF_ID, notif, ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK)
                    } else {
                        startForeground(NOTIF_ID, notif)
                    }
                }
                setOnCompletionListener {
                    if (pendingNextSurah) {
                        // Kullanıcı sonraki butonuna bastığı için ayet bittiğinde sonraki sureye geç
                        pendingNextSurah = false
                        val nextSurah = if (surahNum >= 114) 1 else surahNum + 1
                        saveSurahAndAyah(nextSurah, 1)
                        playAudio()
                    } else {
                        // Kesintisiz sure çalma: Sırada ayet varsa devam et, sure bittiyse sonraki sureye geç
                        val totalAyahs = getAyahCount(surahNum)
                        if (ayahNum < totalAyahs) {
                            saveSurahAndAyah(surahNum, ayahNum + 1)
                            playAudio()
                        } else {
                            val nextSurah = if (surahNum >= 114) 1 else surahNum + 1
                            saveSurahAndAyah(nextSurah, 1)
                            playAudio()
                        }
                    }
                }
                setOnErrorListener { _, _, _ ->
                    this@QuranAudioService.isPlaying = false
                    updateState(false)
                    stopForeground(STOP_FOREGROUND_REMOVE)
                    true
                }
                prepareAsync()
            }
        } catch (e: Exception) {
            e.printStackTrace()
            this@QuranAudioService.isPlaying = false
            updateState(false)
        }
    }

    private fun pauseAudio() {
        try {
            if (mediaPlayer?.isPlaying == true) {
                mediaPlayer?.pause()
            } else {
                mediaPlayer?.reset()
            }
        } catch (e: Exception) {
            try { mediaPlayer?.reset() } catch (_: Exception) {}
        }
        isPlaying = false
        updateState(false)
        val notif = createNotification(false)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(NOTIF_ID, notif, ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK)
        } else {
            startForeground(NOTIF_ID, notif)
        }
    }

    private fun stopAudio() {
        try {
            mediaPlayer?.stop()
            mediaPlayer?.release()
        } catch (_: Exception) {}
        mediaPlayer = null
        isPlaying = false
        updateState(false)
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    private fun updateState(playing: Boolean) {
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        prefs.edit().putBoolean("flutter.is_audio_playing", playing).apply()
        QuranAudioWidgetProvider.updateAllWidgets(this, playing, "$surahName, $ayahNum. Ayet")
    }

    private fun createNotification(playing: Boolean): Notification {
        val openIntent = Intent(this, MainActivity::class.java)
        val pOpen = PendingIntent.getActivity(
            this, 201, openIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val toggleIntent = Intent(this, QuranAudioService::class.java).apply {
            action = ACTION_PLAY_PAUSE
        }
        val pToggle = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            PendingIntent.getForegroundService(
                this, 202, toggleIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        } else {
            PendingIntent.getService(
                this, 202, toggleIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        }

        val stopIntent = Intent(this, QuranAudioService::class.java).apply {
            action = ACTION_STOP
        }
        val pStop = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            PendingIntent.getForegroundService(
                this, 203, stopIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        } else {
            PendingIntent.getService(
                this, 203, stopIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        }

        val playPauseIcon = if (playing) R.drawable.ic_widget_pause else R.drawable.ic_widget_play
        val playPauseText = if (playing) "Durdur" else "Oynat"

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Kuran-ı Kerim Dinleniyor")
            .setContentText("$surahName, $ayahNum. Ayet (Saad el-Gamdi)")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentIntent(pOpen)
            .addAction(playPauseIcon, playPauseText, pToggle)
            .addAction(R.drawable.ic_widget_pause, "Kapat", pStop)
            .setOngoing(playing)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .build()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Kuran Sesli Oynatıcı",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Kuran-ı Kerim arka plan ses çalma bildirimleri"
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    override fun onDestroy() {
        mediaPlayer?.release()
        mediaPlayer = null
        super.onDestroy()
    }
}
