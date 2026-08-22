package com.walkaround.app.models

import java.util.UUID

enum class DamageType(val title: String) {
    SCRATCH("Scratch / Scuff"),
    DENT("Dent / Ding"),
    PAINT_CHIP("Paint Chip / Flake"),
    CURB_RASH("Wheel Curb Rash"),
    CRACKED_GLASS("Cracked / Chipped Glass"),
    INTERIOR_STAIN("Interior Tear / Stain"),
    OTHER("Other Pre-Existing Defect")
}

enum class DamageSeverity(val title: String) {
    MINOR("Minor (< 2 inches)"),
    MODERATE("Moderate (2-6 inches)"),
    SEVERE("Severe (> 6 inches)")
}

data class DamagePoint(
    val id: String = UUID.randomUUID().toString(),
    val zoneId: VehicleZoneId,
    val type: DamageType = DamageType.SCRATCH,
    val severity: DamageSeverity = DamageSeverity.MINOR,
    val notes: String = "",
    val normalizedX: Float = 0.5f,
    val normalizedY: Float = 0.5f,
    val photoEvidenceId: String? = null
)
