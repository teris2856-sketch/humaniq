package com.jenay_teris.swiftspeak

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioManager
import android.media.AudioTrack
import android.media.MediaPlayer
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.nio.ByteBuffer
import java.nio.ByteOrder
import kotlin.math.max
import kotlin.math.min

class MainActivity : FlutterActivity() {
    private val channelName = "swiftspeak/button_sound"
    private val mainHandler = Handler(Looper.getMainLooper())
    private var mediaPlayer: MediaPlayer? = null
    private var audioTrack: AudioTrack? = null
    @Volatile private var playGeneration = 0

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "play" -> play(call.argument<String>("path"), result)
                    "stop" -> {
                        stopAll()
                        result.success(null)
                    }
                    "resetAudio" -> {
                        prepareAudioRoute()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun audioManager(): AudioManager {
        return getSystemService(Context.AUDIO_SERVICE) as AudioManager
    }

    private fun prepareAudioRoute() {
        val manager = audioManager()
        manager.mode = AudioManager.MODE_NORMAL
        @Suppress("DEPRECATION")
        manager.isSpeakerphoneOn = true
        listOf(
            AudioManager.STREAM_MUSIC,
            AudioManager.STREAM_ACCESSIBILITY,
            AudioManager.STREAM_NOTIFICATION,
        ).forEach { stream ->
            if (manager.getStreamVolume(stream) == 0) {
                val maxVolume = manager.getStreamMaxVolume(stream)
                manager.setStreamVolume(stream, max(1, (maxVolume * 0.8).toInt()), 0)
            }
        }
    }

    private fun play(path: String?, result: MethodChannel.Result) {
        if (path.isNullOrBlank() || !File(path).exists()) {
            result.error("missing", "That sound file is missing. Record it again.", null)
            return
        }

        val bytes = try {
            File(path).readBytes()
        } catch (error: Exception) {
            result.error("play_failed", error.message, null)
            return
        }

        stopAll()
        prepareAudioRoute()
        val generation = playGeneration

        val wav = parseWav(bytes)
        if (wav != null) {
            if (wav.peak < 300) {
                result.error(
                    "silent",
                    "The microphone captured no voice. Turn on the emulator mic or use a real phone.",
                    null,
                )
                return
            }
            Thread { playPcm(wav, generation, result) }.start()
            return
        }

        playWithMediaPlayer(path, result)
    }

    private fun playPcm(wav: WavData, generation: Int, result: MethodChannel.Result) {
        var answered = false
        fun finishOnce(block: () -> Unit) {
            if (answered) return
            answered = true
            mainHandler.post(block)
        }

        try {
            val channelMask = if (wav.channels == 1) {
                AudioFormat.CHANNEL_OUT_MONO
            } else {
                AudioFormat.CHANNEL_OUT_STEREO
            }
            val minBuffer = AudioTrack.getMinBufferSize(
                wav.sampleRate,
                channelMask,
                AudioFormat.ENCODING_PCM_16BIT,
            )
            if (minBuffer <= 0) {
                finishOnce { result.error("play_failed", "Could not create a speaker track.", null) }
                return
            }

            val track = AudioTrack.Builder()
                .setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_MEDIA)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                        .build(),
                )
                .setAudioFormat(
                    AudioFormat.Builder()
                        .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                        .setSampleRate(wav.sampleRate)
                        .setChannelMask(channelMask)
                        .build(),
                )
                .setTransferMode(AudioTrack.MODE_STREAM)
                .setBufferSizeInBytes(minBuffer * 2)
                .build()

            audioTrack = track
            track.setVolume(1f)
            track.play()

            var offset = 0
            val pcm = wav.pcm
            val chunk = minBuffer
            while (offset < pcm.size && playGeneration == generation) {
                val written = track.write(pcm, offset, min(chunk, pcm.size - offset))
                if (written <= 0) break
                offset += written
            }

            val durationMs = (pcm.size * 1000L) /
                (wav.sampleRate.toLong() * wav.channels * 2).coerceAtLeast(1)
            Thread.sleep(durationMs.coerceAtLeast(80))

            if (audioTrack === track) {
                track.stop()
                track.release()
                audioTrack = null
            }
            Log.i(TAG, "Played PCM peak=${wav.peak} bytes=${pcm.size}")
            finishOnce { result.success(null) }
        } catch (error: Exception) {
            Log.e(TAG, "PCM play failed", error)
            finishOnce { result.error("play_failed", error.message, null) }
        }
    }

    private fun playWithMediaPlayer(path: String, result: MethodChannel.Result) {
        try {
            val player = MediaPlayer()
            mediaPlayer = player
            player.setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_MEDIA)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                    .build(),
            )
            player.setVolume(1f, 1f)
            player.setDataSource(path)

            var answered = false
            fun finishOnce(block: () -> Unit) {
                if (answered) return
                answered = true
                block()
            }

            player.setOnPreparedListener { it.start() }
            player.setOnCompletionListener {
                stopAll()
                finishOnce { result.success(null) }
            }
            player.setOnErrorListener { _, what, extra ->
                stopAll()
                finishOnce {
                    result.error("play_failed", "Could not play that sound ($what, $extra).", null)
                }
                true
            }
            player.prepareAsync()
        } catch (error: Exception) {
            stopAll()
            result.error("play_failed", error.message, null)
        }
    }

    private fun parseWav(bytes: ByteArray): WavData? {
        if (bytes.size < 44) return null
        if (bytes[0] != 'R'.code.toByte() || bytes[1] != 'I'.code.toByte()) return null

        var offset = 12
        var channels = 1
        var sampleRate = 16000
        var bits = 16
        var dataStart = -1
        var dataSize = 0

        while (offset + 8 <= bytes.size) {
            val id = String(bytes, offset, 4, Charsets.US_ASCII)
            val size = ByteBuffer.wrap(bytes, offset + 4, 4)
                .order(ByteOrder.LITTLE_ENDIAN)
                .int
            val body = offset + 8
            when (id) {
                "fmt " -> {
                    if (body + 16 <= bytes.size) {
                        val format = ByteBuffer.wrap(bytes, body, 16).order(ByteOrder.LITTLE_ENDIAN)
                        val audioFormat = format.short.toInt() and 0xFFFF
                        channels = format.short.toInt() and 0xFFFF
                        sampleRate = format.int
                        format.int
                        format.short
                        bits = format.short.toInt() and 0xFFFF
                        if (audioFormat != 1 || bits != 16) return null
                    }
                }
                "data" -> {
                    dataStart = body
                    dataSize = size
                    break
                }
            }
            offset = body + size
            if (size % 2 == 1) offset += 1
        }

        if (dataStart < 0) return null
        val end = min(bytes.size, dataStart + dataSize)
        if (end <= dataStart) return null
        val pcm = bytes.copyOfRange(dataStart, end)
        var peak = 0
        var i = 0
        while (i + 1 < pcm.size) {
            val sample = (pcm[i].toInt() and 0xFF) or (pcm[i + 1].toInt() shl 8)
            val signed = if (sample >= 32768) sample - 65536 else sample
            peak = max(peak, kotlin.math.abs(signed))
            i += 2
        }
        return WavData(pcm, channels.coerceAtLeast(1), sampleRate, peak)
    }

    private fun stopAll() {
        playGeneration += 1
        try {
            mediaPlayer?.reset()
            mediaPlayer?.release()
        } catch (_: Exception) {
        }
        mediaPlayer = null
        try {
            audioTrack?.pause()
            audioTrack?.flush()
            audioTrack?.release()
        } catch (_: Exception) {
        }
        audioTrack = null
    }

    override fun onDestroy() {
        stopAll()
        super.onDestroy()
    }

    private data class WavData(
        val pcm: ByteArray,
        val channels: Int,
        val sampleRate: Int,
        val peak: Int,
    )

    companion object {
        private const val TAG = "SwiftSpeakSound"
    }
}
