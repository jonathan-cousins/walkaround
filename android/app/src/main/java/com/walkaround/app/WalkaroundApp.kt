package com.walkaround.app

import android.app.Application
import com.walkaround.app.services.RentalRepository

class WalkaroundApp : Application() {
    override fun onCreate() {
        super.onCreate()
        // Initialize persistent storage
        RentalRepository.getInstance(this)
    }
}
