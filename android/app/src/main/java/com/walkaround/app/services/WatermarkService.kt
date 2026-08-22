package com.walkaround.app.services

import android.graphics.*
import com.walkaround.app.models.InspectionPhase
import com.walkaround.app.models.LocationSnapshot
import java.io.ByteArrayOutputStream
import java.security.MessageDigest
import java.text.SimpleDateFormat
import java.util.*
import kotlin.math.max

data class StampedResult(
    val bitmap: Bitmap,
    val sha256: String
)

object WatermarkService {
    private val utcFormatter = SimpleDateFormat("yyyy-MM-dd HH:mm:ss 'UTC'", Locale.US).apply {
        timeZone = TimeZone.getTimeZone("UTC")
    }
    private val localFormatter = SimpleDateFormat("MMM d, yyyy h:mm a", Locale.getDefault())

    fun stampImage(
        original: Bitmap,
        phase: InspectionPhase,
        location: LocationSnapshot?,
        vehicleSummary: String,
        licensePlate: String,
        zoneTitle: String,
        agencyName: String
    ): StampedResult {
        val width = original.width
        val height = original.height

        val result = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(result)
        canvas.drawBitmap(original, 0f, 0f, null)

        val baseScale = max(width, height) / 1200f

        // 1. Top Banner
        val topBannerHeight = 44f * baseScale
        val topPaint = Paint().apply {
            color = if (phase == InspectionPhase.PICKUP) Color.rgb(13, 115, 242) else Color.rgb(26, 179, 89)
            style = Paint.Style.FILL
        }
        canvas.drawRect(0f, 0f, width.toFloat(), topBannerHeight, topPaint)

        val badgeText = "🔒 WALKAROUND PROOF • ${phase.stampPrefix}"
        val badgePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.WHITE
            textSize = 18f * baseScale
            typeface = Typeface.create(Typeface.MONOSPACE, Typeface.BOLD)
            textAlign = Paint.Align.CENTER
        }
        canvas.drawText(badgeText, width / 2f, topBannerHeight * 0.65f, badgePaint)

        // 2. Bottom HUD Overlay Panel
        val hudHeight = 140f * baseScale
        val hudPaint = Paint().apply {
            color = Color.argb(190, 0, 0, 0)
            style = Paint.Style.FILL
        }
        canvas.drawRect(0f, height - hudHeight, width.toFloat(), height.toFloat(), hudPaint)

        val linePaint = Paint().apply {
            color = Color.argb(64, 255, 255, 255)
            strokeWidth = 1.5f * baseScale
        }
        canvas.drawLine(0f, height - hudHeight, width.toFloat(), height - hudHeight, linePaint)

        val leftMargin = 24f * baseScale
        val textPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.WHITE
            textSize = 13f * baseScale
            typeface = Typeface.create(Typeface.MONOSPACE, Typeface.NORMAL)
        }
        val titlePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.WHITE
            textSize = 15f * baseScale
            typeface = Typeface.create(Typeface.MONOSPACE, Typeface.BOLD)
        }
        val yellowPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.rgb(255, 215, 0)
            textSize = 13f * baseScale
            typeface = Typeface.create(Typeface.MONOSPACE, Typeface.BOLD)
        }

        var textY = height - hudHeight + (28f * baseScale)
        canvas.drawText("🚗 $vehicleSummary • Plate: $licensePlate ($agencyName)", leftMargin, textY, titlePaint)

        textY += 24f * baseScale
        val now = Date()
        canvas.drawText("⏱️ ${utcFormatter.format(now)} (${localFormatter.format(now)})", leftMargin, textY, yellowPaint)

        textY += 24f * baseScale
        val latStr = String.format(Locale.US, "%.5f", location?.latitude ?: 0.0)
        val lonStr = String.format(Locale.US, "%.5f", location?.longitude ?: 0.0)
        canvas.drawText("📍 GPS: $latStr, $lonStr • ${location?.placeName ?: "Rental Location"}", leftMargin, textY, textPaint)

        textY += 24f * baseScale
        canvas.drawText("🎯 ZONE: $zoneTitle • Tamper-Sealed Forensic Record", leftMargin, textY, textPaint)

        // Calculate SHA-256 Hash of pixels
        val stream = ByteArrayOutputStream()
        result.compress(Bitmap.CompressFormat.JPEG, 90, stream)
        val bytes = stream.toByteArray()
        val md = MessageDigest.getInstance("SHA-256")
        val digest = md.digest(bytes)
        val sha256 = digest.joinToString("") { "%02x".format(it) }

        return StampedResult(result, sha256)
    }
}
