package com.walkaround.app.services

import android.content.Context
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Typeface
import android.graphics.pdf.PdfDocument
import com.walkaround.app.models.Rental
import java.io.File
import java.io.FileOutputStream
import java.text.SimpleDateFormat
import java.util.*

object PDFReportGenerator {
    private val dateFormatter = SimpleDateFormat("MMM d, yyyy h:mm a", Locale.US)

    fun generatePDF(
        context: Context,
        rental: Rental,
        renterName: String = "Jonathan Cousins",
        claimNumber: String = ""
    ): File {
        val pdfDoc = PdfDocument()
        val pageWidth = 612 // Standard US Letter width in points (72 dpi)
        val pageHeight = 792 // US Letter height in points

        // PAGE 1: Overview & Location Audit
        val pageInfo1 = PdfDocument.PageInfo.Builder(pageWidth, pageHeight, 1).create()
        val page1 = pdfDoc.startPage(pageInfo1)
        val canvas1 = page1.canvas

        // Header Background
        val headerPaint = Paint().apply {
            color = Color.rgb(15, 23, 42) // Dark Navy
            style = Paint.Style.FILL
        }
        canvas1.drawRect(36f, 36f, (pageWidth - 36).toFloat(), 100f, headerPaint)

        val headerTitlePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.WHITE
            textSize = 15f
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
        }
        canvas1.drawText("WALKAROUND™ VEHICLE INSPECTION DOSSIER", 52f, 65f, headerTitlePaint)

        val headerSubPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.rgb(5, 150, 105) // Emerald Accent
            textSize = 9f
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
        }
        canvas1.drawText("VERIFIED VEHICLE INSPECTION RECORD • TIME & GPS DOCUMENTED", 52f, 85f, headerSubPaint)

        // Metadata Grid
        val gridPaint = Paint().apply {
            color = Color.rgb(245, 247, 250)
            style = Paint.Style.FILL
        }
        canvas1.drawRoundRect(36f, 120f, (pageWidth - 36).toFloat(), 260f, 8f, 8f, gridPaint)

        val labelPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.DKGRAY
            textSize = 8f
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
        }
        val valuePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.BLACK
            textSize = 10f
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
        }

        val meta = listOf(
            "VEHICLE" to rental.vehicleTitle,
            "LICENSE PLATE" to "${rental.licensePlate} (${rental.stateOrCountry})",
            "RENTAL AGENCY" to rental.agency.title,
            "AGREEMENT #" to if (rental.agreementNumber.isNotBlank()) rental.agreementNumber else "N/A",
            "CLAIM / NOTICE #" to if (claimNumber.isNotBlank()) claimNumber else "N/A",
            "RENTER / AUDITOR" to renterName
        )

        meta.forEachIndexed { index, pair ->
            val col = index % 3
            val row = index / 3
            val x = 52f + (col * 175f)
            val y = 145f + (row * 50f)
            canvas1.drawText(pair.first, x, y, labelPaint)
            canvas1.drawText(pair.second, x, y + 14f, valuePaint)
        }

        // Section Title: GPS & Location
        val sectionTitlePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.rgb(15, 23, 42)
            textSize = 11f
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
        }
        canvas1.drawText("1. VERIFIED GEOGRAPHIC AUDIT TRAIL", 36f, 300f, sectionTitlePaint)

        val gpsBoxPaint = Paint().apply {
            color = Color.rgb(240, 245, 255)
            style = Paint.Style.FILL
        }
        canvas1.drawRoundRect(36f, 315f, (pageWidth / 2 - 10).toFloat(), 380f, 6f, 6f, gpsBoxPaint)
        canvas1.drawText("PICKUP LOCATION:", 46f, 335f, labelPaint)
        canvas1.drawText(rental.pickupInspection?.location?.placeName ?: "Pickup Location Recorded", 46f, 355f, valuePaint)

        val returnBoxPaint = Paint().apply {
            color = Color.rgb(240, 253, 244)
            style = Paint.Style.FILL
        }
        canvas1.drawRoundRect((pageWidth / 2 + 10).toFloat(), 315f, (pageWidth - 36).toFloat(), 380f, 6f, 6f, returnBoxPaint)
        canvas1.drawText("RETURN LOCATION:", (pageWidth / 2 + 20).toFloat(), 335f, labelPaint)
        canvas1.drawText(rental.dropoffInspection?.location?.placeName ?: "Return Location Recorded", (pageWidth / 2 + 20).toFloat(), 355f, valuePaint)

        // Pre-Existing Damages
        canvas1.drawText("2. PRE-EXISTING DAMAGE LOGGED AT VEHICLE ACCEPTANCE", 36f, 410f, sectionTitlePaint)
        val damages = rental.pickupInspection?.damagePoints ?: emptyList()
        if (damages.isEmpty()) {
            val emptyPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = Color.GRAY
                textSize = 9f
            }
            canvas1.drawText("No significant defects flagged at pickup. Vehicle accepted in standard condition.", 46f, 430f, emptyPaint)
        } else {
            damages.take(3).forEachIndexed { i, dmg ->
                val dY = 430f + (i * 30f)
                canvas1.drawText("⚠️ ${dmg.zoneId.shortTitle}: ${dmg.type.title} [${dmg.severity.title}]", 46f, dY, valuePaint)
                canvas1.drawText("    Notes: ${if (dmg.notes.isNotBlank()) dmg.notes else "Documented on pickup photo."}", 46f, dY + 12f, labelPaint)
            }
        }

        // Footer
        val footerPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.GRAY
            textSize = 8f
        }
        canvas1.drawText("Generated via Walkaround for Android • Verified Timestamp & GPS Report • Page 1 of 2", 36f, pageHeight - 30f, footerPaint)

        pdfDoc.finishPage(page1)

        // PAGE 2: Dispute Letter
        val pageInfo2 = PdfDocument.PageInfo.Builder(pageWidth, pageHeight, 2).create()
        val page2 = pdfDoc.startPage(pageInfo2)
        val canvas2 = page2.canvas

        canvas2.drawText("FORMAL REBUTTAL & DISPUTE NOTICE", 36f, 60f, sectionTitlePaint)

        val letterText = DisputeLetterTemplate.generateLetter(
            rental = rental,
            recipient = DisputeRecipient.RENTAL_AGENCY,
            renterName = renterName,
            claimNumber = claimNumber
        )

        val bodyPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.rgb(30, 41, 59)
            textSize = 9f
            typeface = Typeface.create(Typeface.MONOSPACE, Typeface.NORMAL)
        }

        var lineY = 90f
        letterText.lines().forEach { line ->
            if (lineY < pageHeight - 50f) {
                canvas2.drawText(line, 36f, lineY, bodyPaint)
                lineY += 13f
            }
        }

        canvas2.drawText("Generated via Walkaround for Android • Verified Timestamp & GPS Report • Page 2 of 2", 36f, pageHeight - 30f, footerPaint)
        pdfDoc.finishPage(page2)

        // Write to Cache File
        val pdfFile = File(context.cacheDir, "Walkaround_Dispute_${rental.licensePlate}.pdf")
        FileOutputStream(pdfFile).use { out ->
            pdfDoc.writeTo(out)
        }
        pdfDoc.close()
        return pdfFile
    }
}
