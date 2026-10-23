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
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaPlayer
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import android.support.v4.media.session.MediaSessionCompat
import android.support.v4.media.session.PlaybackStateCompat
import androidx.core.app.NotificationCompat

class QuranAudioService : Service() {

    private var mediaPlayer: MediaPlayer? = null
    private var mediaSession: MediaSessionCompat? = null
    private var wakeLock: PowerManager.WakeLock? = null
    private var audioManager: AudioManager? = null
    private var audioFocusRequest: AudioFocusRequest? = null

    private var isPlaying = false
    private var surahNum = 94
    private var ayahNum = 5
    private var surahName = "İnşirah"

    companion object {
        const val ACTION_PLAY_PAUSE = "com.ezanvakti.app.ACTION_PLAY_PAUSE"
        const val ACTION_NEXT = "com.ezanvakti.app.ACTION_NEXT"
        const val ACTION_PREV = "com.ezanvakti.app.ACTION_PREV"
        const val ACTION_STOP = "com.ezanvakti.app.ACTION_STOP"

        private const val CHANNEL_ID = "quran_audio_playback"
        private const val NOTIF_ID = 2001

        @Volatile
        var isServiceRunning = false
            private set

        fun stopService(context: Context) {
            try {
                val stopIntent = Intent(context, QuranAudioService::class.java).apply {
                    action = ACTION_STOP
                }
                context.startService(stopIntent)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }

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
        isServiceRunning = true
        createNotificationChannel()

        audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager

        // Ekran kapandığında sesin kesilmemesi için WakeLock oluştur
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        wakeLock = powerManager.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "EzanVakti:QuranAudioLock").apply {
            setReferenceCounted(false)
        }

        initMediaSession()
    }

    private fun initMediaSession() {
        mediaSession = MediaSessionCompat(this, "QuranAudioPlayback").apply {
            isActive = true
            setCallback(object : MediaSessionCompat.Callback() {
                override fun onPlay() {
                    playArabicAudio()
                }

                override fun onPause() {
                    pauseAudio()
                }

                override fun onSkipToNext() {
                    nextSurah()
                }

                override fun onSkipToPrevious() {
                    prevSurah()
                }

                override fun onStop() {
                    stopAudio()
                }
            })
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val action = intent?.action ?: return START_NOT_STICKY

        readPrefs()

        when (action) {
            ACTION_PLAY_PAUSE -> {
                if (isPlaying) {
                    pauseAudio()
                } else {
                    playArabicAudio()
                }
            }
            ACTION_NEXT -> {
                nextSurah()
            }
            ACTION_PREV -> {
                prevSurah()
            }
            ACTION_STOP -> {
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

    private fun nextSurah() {
        val nextSurah = if (surahNum >= 114) 1 else surahNum + 1
        saveSurahAndAyah(nextSurah, 1)
        playArabicAudio()
    }

    private fun prevSurah() {
        val prevSurah = if (surahNum <= 1) 114 else surahNum - 1
        saveSurahAndAyah(prevSurah, 1)
        playArabicAudio()
    }

    private fun acquireWakeLock() {
        try {
            if (wakeLock?.isHeld == false) {
                wakeLock?.acquire(15 * 60 * 1000L) // 15 dakika güvenlik süresi
            }
        } catch (_: Exception) {}
    }

    private fun releaseWakeLock() {
        try {
            if (wakeLock?.isHeld == true) {
                wakeLock?.release()
            }
        } catch (_: Exception) {}
    }

    private fun requestAudioFocus(): Boolean {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                if (audioFocusRequest == null) {
                    val audioAttributes = AudioAttributes.Builder()
                        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                        .setUsage(AudioAttributes.USAGE_MEDIA)
                        .build()
                    audioFocusRequest = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN)
                        .setAudioAttributes(audioAttributes)
                        .setAcceptsDelayedFocusGain(false)
                        .setOnAudioFocusChangeListener { focusChange ->
                            if (focusChange == AudioManager.AUDIOFOCUS_LOSS ||
                                focusChange == AudioManager.AUDIOFOCUS_LOSS_TRANSIENT) {
                                pauseAudio()
                            }
                        }
                        .build()
                }
                audioManager?.requestAudioFocus(audioFocusRequest!!) == AudioManager.AUDIOFOCUS_REQUEST_GRANTED
            } else {
                @Suppress("DEPRECATION")
                audioManager?.requestAudioFocus(
                    { focusChange ->
                        if (focusChange == AudioManager.AUDIOFOCUS_LOSS ||
                            focusChange == AudioManager.AUDIOFOCUS_LOSS_TRANSIENT) {
                            pauseAudio()
                        }
                    },
                    AudioManager.STREAM_MUSIC,
                    AudioManager.AUDIOFOCUS_GAIN
                ) == AudioManager.AUDIOFOCUS_REQUEST_GRANTED
            }
        } catch (_: Exception) {
            true
        }
    }

    private fun abandonAudioFocus() {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                audioFocusRequest?.let { audioManager?.abandonAudioFocusRequest(it) }
            } else {
                @Suppress("DEPRECATION")
                audioManager?.abandonAudioFocus(null)
            }
        } catch (_: Exception) {}
    }

    private fun playArabicAudio() {
        val url = String.format(
            "https://everyayah.com/data/Alafasy_128kbps/%03d%03d.mp3",
            surahNum,
            ayahNum
        )

        try {
            requestAudioFocus()
            acquireWakeLock()
            this.isPlaying = true
            updateState(true)
            showForegroundNotification(true)

            mediaPlayer?.release()
            mediaPlayer = MediaPlayer().apply {
                setWakeMode(applicationContext, PowerManager.PARTIAL_WAKE_LOCK)
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
                    showForegroundNotification(true)
                }
                setOnCompletionListener {
                    val totalAyahs = getAyahCount(surahNum)
                    if (ayahNum < totalAyahs) {
                        saveSurahAndAyah(surahNum, ayahNum + 1)
                        playArabicAudio()
                    } else {
                        val nextSurah = if (surahNum >= 114) 1 else surahNum + 1
                        saveSurahAndAyah(nextSurah, 1)
                        playArabicAudio()
                    }
                }
                setOnErrorListener { _, _, _ ->
                    this@QuranAudioService.isPlaying = false
                    updateState(false)
                    releaseWakeLock()
                    abandonAudioFocus()
                    showForegroundNotification(false)
                    true
                }
                prepareAsync()
            }
        } catch (e: Exception) {
            e.printStackTrace()
            this.isPlaying = false
            updateState(false)
            releaseWakeLock()
            abandonAudioFocus()
        }
    }

    private fun pauseAudio() {
        try {
            if (mediaPlayer?.isPlaying == true) {
                mediaPlayer?.pause()
            }
        } catch (_: Exception) {}

        isPlaying = false
        releaseWakeLock()
        abandonAudioFocus()
        updateState(false)
        showForegroundNotification(false)
    }

    private fun stopAudio() {
        try {
            mediaPlayer?.stop()
            mediaPlayer?.release()
        } catch (_: Exception) {}

        mediaPlayer = null
        isPlaying = false
        releaseWakeLock()
        abandonAudioFocus()
        updateState(false)
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    private fun updateState(playing: Boolean) {
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        prefs.edit()
            .putBoolean("flutter.is_audio_playing", playing)
            .putBoolean("flutter.is_widget_audio_playing", playing)
            .apply()

        val trackTitle = "$surahName • $ayahNum. Ayet"

        QuranAudioWidgetProvider.updateAllWidgets(
            this,
            playing,
            trackTitle
        )
        updatePlaybackState(playing)
    }

    private fun updatePlaybackState(playing: Boolean) {
        val state = if (playing) PlaybackStateCompat.STATE_PLAYING else PlaybackStateCompat.STATE_PAUSED
        val actions = PlaybackStateCompat.ACTION_PLAY or
                PlaybackStateCompat.ACTION_PAUSE or
                PlaybackStateCompat.ACTION_PLAY_PAUSE or
                PlaybackStateCompat.ACTION_SKIP_TO_NEXT or
                PlaybackStateCompat.ACTION_SKIP_TO_PREVIOUS or
                PlaybackStateCompat.ACTION_STOP

        mediaSession?.setPlaybackState(
            PlaybackStateCompat.Builder()
                .setActions(actions)
                .setState(state, PlaybackStateCompat.PLAYBACK_POSITION_UNKNOWN, 1.0f)
                .build()
        )
    }

    private fun showForegroundNotification(playing: Boolean) {
        val notif = createNotification(playing)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(NOTIF_ID, notif, ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK)
        } else {
            startForeground(NOTIF_ID, notif)
        }
    }

    private fun createNotification(playing: Boolean): Notification {
        val openIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("tab", 1)
        }
        val pOpen = PendingIntent.getActivity(
            this, 201, openIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Previous Action
        val prevIntent = Intent(this, QuranAudioService::class.java).apply { action = ACTION_PREV }
        val pPrev = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            PendingIntent.getForegroundService(this, 202, prevIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        } else {
            PendingIntent.getService(this, 202, prevIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        }

        // Play/Pause Action
        val toggleIntent = Intent(this, QuranAudioService::class.java).apply { action = ACTION_PLAY_PAUSE }
        val pToggle = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            PendingIntent.getForegroundService(this, 203, toggleIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        } else {
            PendingIntent.getService(this, 203, toggleIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        }

        // Next Action
        val nextIntent = Intent(this, QuranAudioService::class.java).apply { action = ACTION_NEXT }
        val pNext = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            PendingIntent.getForegroundService(this, 204, nextIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        } else {
            PendingIntent.getService(this, 204, nextIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        }

        // Stop Action
        val stopIntent = Intent(this, QuranAudioService::class.java).apply { action = ACTION_STOP }
        val pStop = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            PendingIntent.getForegroundService(this, 205, stopIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        } else {
            PendingIntent.getService(this, 205, stopIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        }

        val playPauseIcon = if (playing) R.drawable.ic_widget_pause else R.drawable.ic_widget_play
        val playPauseText = if (playing) "Durdur" else "Oynat"

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Kuran-ı Kerim Tilaveti")
            .setContentText("$surahName Suresi • $ayahNum. Ayet")
            .setSubText("Saad el-Gamdi")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentIntent(pOpen)
            .addAction(R.drawable.ic_widget_prev, "Önceki", pPrev)
            .addAction(playPauseIcon, playPauseText, pToggle)
            .addAction(R.drawable.ic_widget_next, "Sonraki", pNext)
            .addAction(R.drawable.ic_widget_pause, "Kapat", pStop)
            .setStyle(
                androidx.media.app.NotificationCompat.MediaStyle()
                    .setMediaSession(mediaSession?.sessionToken)
                    .setShowActionsInCompactView(0, 1, 2)
                    .setShowCancelButton(true)
                    .setCancelButtonIntent(pStop)
            )
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
        isServiceRunning = false
        abandonAudioFocus()
        releaseWakeLock()
        mediaSession?.release()
        mediaSession = null
        mediaPlayer?.release()
        mediaPlayer = null
        super.onDestroy()
    }
}
