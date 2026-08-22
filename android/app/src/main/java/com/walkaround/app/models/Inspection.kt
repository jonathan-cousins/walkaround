package com.walkaround.app.models

import java.util.UUID

enum class InspectionPhase(val title: String, val stampPrefix: String) {
    PICKUP("Pick-Up Possession", "PICKUP VERIFICATION"),
    DROPOFF("Return Surrender", "RETURN SURRENDER")
}

data class LocationSnapshot(
    val latitude: Double = 0.0,
    val longitude: Double = 0.0,
    val altitude: Double = 0.0,
    val placeName: String = "Detecting Location...",
    val formattedAddress: String = "",
    val recordedAt: Long = System.currentTimeMillis()
)

data class PhotoEvidence(
    val id: String = UUID.randomUUID().toString(),
    val zoneId: VehicleZoneId,
    val filename: String,
    val capturedAt: Long = System.currentTimeMillis(),
    val location: LocationSnapshot? = null,
    val hasDamage: Boolean = false,
    val hashSHA256: String? = null
)

data class Inspection(
    val id: String = UUID.randomUUID().toString(),
    val phase: InspectionPhase,
    val startedAt: Long = System.currentTimeMillis(),
    var completedAt: Long? = null,
    var location: LocationSnapshot? = null,
    var odometerReading: String = "",
    var odometerUnit: String = "mi",
    var fuelLevel: FuelLevel = FuelLevel.FULL,
    val photos: MutableMap<VehicleZoneId, PhotoEvidence> = mutableMapOf(),
    val damagePoints: MutableList<DamagePoint> = mutableListOf(),
    var inspectorNotes: String = "",
    var isCompleted: Boolean = false
) {
    fun setPhoto(photo: PhotoEvidence, zone: VehicleZoneId) {
        photos[zone] = photo
    }

    val completedZoneCount: Int get() = photos.size
}
