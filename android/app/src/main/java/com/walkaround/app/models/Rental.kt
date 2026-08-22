package com.walkaround.app.models

import java.util.UUID

enum class RentalAgency(val title: String) {
    HERTZ("Hertz"),
    ENTERPRISE("Enterprise"),
    AVIS("Avis"),
    BUDGET("Budget"),
    SIXT("Sixt"),
    NATIONAL("National"),
    ALAMO("Alamo"),
    TURO("Turo"),
    GETAROUND("Getaround"),
    UHAUL("U-Haul / Moving Truck"),
    OTHER("Other Rental Provider")
}

enum class RentalStatus(val title: String) {
    UPCOMING("Scheduled"),
    ACTIVE("In Possession"),
    RETURNED("Returned & Closed"),
    DISPUTED("Dispute Active")
}

data class Rental(
    val id: String = UUID.randomUUID().toString(),
    var make: String = "",
    var model: String = "",
    var year: String = "",
    var licensePlate: String = "",
    var stateOrCountry: String = "US",
    var vin: String = "",
    var agency: RentalAgency = RentalAgency.HERTZ,
    var agreementNumber: String = "",
    var status: RentalStatus = RentalStatus.ACTIVE,
    val createdAt: Long = System.currentTimeMillis(),
    var updatedAt: Long = System.currentTimeMillis(),
    var pickupInspection: Inspection? = null,
    var dropoffInspection: Inspection? = null
) {
    val vehicleTitle: String
        get() {
            val title = "$year $make $model".trim()
            return if (title.isNotBlank()) title else "Rental Vehicle ($licensePlate)"
        }

    val hasPickupCompleted: Boolean
        get() = pickupInspection?.isCompleted == true

    val hasDropoffCompleted: Boolean
        get() = dropoffInspection?.isCompleted == true

    val totalPickupDamagesCount: Int
        get() = pickupInspection?.damagePoints?.size ?: 0

    companion object {
        fun createSample(): Rental {
            val sample = Rental(
                make = "Ford",
                model = "Mustang GT",
                year = "2024",
                licensePlate = "8TRP492",
                stateOrCountry = "CA",
                vin = "1FA6P8CF8R5102948",
                agency = RentalAgency.HERTZ,
                agreementNumber = "H99281741",
                status = RentalStatus.ACTIVE
            )
            val pLoc = LocationSnapshot(
                latitude = 33.9416,
                longitude = -118.4085,
                placeName = "LAX Airport Hertz Center",
                formattedAddress = "9000 Airport Blvd, Los Angeles, CA 90045"
            )
            val pInsp = Inspection(
                phase = InspectionPhase.PICKUP,
                completedAt = System.currentTimeMillis() - 86400000L * 2,
                location = pLoc,
                odometerReading = "14,820",
                odometerUnit = "mi",
                fuelLevel = FuelLevel.FULL,
                isCompleted = true
            )
            pInsp.damagePoints.add(
                DamagePoint(
                    zoneId = VehicleZoneId.FRONT_BUMPER,
                    type = DamageType.SCRATCH,
                    severity = DamageSeverity.MINOR,
                    notes = "Lower air dam scrape on curb side"
                )
            )
            pInsp.damagePoints.add(
                DamagePoint(
                    zoneId = VehicleZoneId.DRIVER_FRONT_WHEEL,
                    type = DamageType.CURB_RASH,
                    severity = DamageSeverity.MODERATE,
                    notes = "2-inch curb rash on alloy rim spoke"
                )
            )
            sample.pickupInspection = pInsp
            return sample
        }
    }
}
