package com.example.personal_tracker

import android.app.*
import android.content.Intent
import android.os.IBinder
import androidx.core.app.NotificationCompat

class NetworkSpeedService : Service() {

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()

        val notification = NotificationCompat.Builder(this, "netpulse_channel")
            .setContentTitle("NetPulse Running")
            .setContentText("Monitoring network speed")
            .setSmallIcon(android.R.drawable.stat_sys_download)
            .build()

        startForeground(1, notification)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // TODO: Add TrafficStats logic later
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotificationChannel() {
        val channel = NotificationChannel(
            "netpulse_channel",
            "NetPulse Service",
            NotificationManager.IMPORTANCE_LOW
        )

        val manager = getSystemService(NotificationManager::class.java)
        manager.createNotificationChannel(channel)
    }
}