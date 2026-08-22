package com.walkaround.app.services

import com.walkaround.app.models.Rental
import java.text.SimpleDateFormat
import java.util.*

enum class DisputeRecipient(val title: String) {
    RENTAL_AGENCY("Rental Agency (Damage Recovery Unit)"),
    CREDIT_CARD("Credit Card CDW Benefits (Chase / Amex / CapOne)"),
    TURO_SUPPORT("Turo Claims & Resolutions Team"),
    PERSONAL_INSURANCE("Personal Auto Insurance Adjuster")
}

object DisputeLetterTemplate {
    private val dateFormatter = SimpleDateFormat("MMMM d, yyyy", Locale.US)

    fun generateLetter(
        rental: Rental,
        recipient: DisputeRecipient,
        renterName: String = "Jonathan Cousins",
        claimNumber: String = "",
        disputedDescription: String = ""
    ): String {
        val todayStr = dateFormatter.format(Date())
        val pickupDateStr = rental.pickupInspection?.completedAt?.let { dateFormatter.format(Date(it)) } ?: "Pickup Date"
        val dropoffDateStr = rental.dropoffInspection?.completedAt?.let { dateFormatter.format(Date(it)) } ?: "Dropoff Date"
        val pickupLoc = rental.pickupInspection?.location?.placeName ?: "Rental Lot"
        val dropoffLoc = rental.dropoffInspection?.location?.placeName ?: "Return Lot"
        val pickupOdo = rental.pickupInspection?.odometerReading ?: "N/A"
        val dropoffOdo = rental.dropoffInspection?.odometerReading ?: "N/A"
        val unit = rental.pickupInspection?.odometerUnit ?: "mi"

        return when (recipient) {
            DisputeRecipient.RENTAL_AGENCY -> """
DATE: $todayStr
TO: ${rental.agency.title} - Damage Recovery Unit & Claims Department
RE: FORMAL DISPUTE OF DAMAGE CLAIM
RENTAL AGREEMENT NO: ${if (rental.agreementNumber.isNotBlank()) rental.agreementNumber else "[AGREEMENT #]"}
CLAIM REFERENCE NO: ${if (claimNumber.isNotBlank()) claimNumber else "[CLAIM # / NOTICE #]"}
VEHICLE: ${rental.vehicleTitle}
LICENSE PLATE: ${rental.licensePlate} (State/Region: ${rental.stateOrCountry})
VIN: ${if (rental.vin.isNotBlank()) rental.vin else "On File"}

Dear Claims Administrator,

I am writing to formally and unequivocally dispute the recent damage assessment and associated financial charges asserted against my account regarding the above-referenced rental vehicle.

I conducted a comprehensive, standardized, time-stamped, and GPS-verified pre-trip inspection prior to operating the vehicle on $pickupDateStr at $pickupLoc (Odometer: $pickupOdo $unit), as well as a certified return inspection upon surrender on $dropoffDateStr at $dropoffLoc (Odometer: $dropoffOdo $unit).

FORENSIC INSPECTION EVIDENCE:
As documented in the attached Certified Walkaround Forensic Audit Dossier:
1. The alleged damage ${if (disputedDescription.isNotBlank()) "($disputedDescription)" else "in question"} was documented as PRE-EXISTING at the exact time and GPS location of vehicle possession.
2. High-resolution photographic evidence with embedded cryptographic timestamps and SHA-256 metadata confirms that no new damage occurred during the authorized rental period.
3. The vehicle was returned in identical cosmetic and mechanical condition to that at pick-up.

DEMAND FOR DISMISSAL & REFUND:
Under applicable commercial rental regulations and credit card merchant service agreements:
- Any unauthorized or non-consensual credit card charges or holds must be released immediately.
- This claim must be closed with zero liability assigned to my name.
- Written confirmation of this claim closure must be provided within five (5) business days.

Sincerely,

$renterName
Attached: Certified Walkaround Forensic Evidence Dossier (Side-by-Side Photo Matrix & EXIF Proof)

____________________________________________________________
DISCLAIMER: Walkaround is a photo evidence documentation tool and does not provide legal advice or representation. This document is a factual record of vehicle condition prepared by the renter.
""".trimIndent()

            DisputeRecipient.CREDIT_CARD -> """
DATE: $todayStr
TO: Benefits Administrator - Auto Rental Collision Damage Waiver (CDW)
RE: REBUTTAL EVIDENCE & DISPUTE DOSSIER FOR CHARGEBACK / CLAIM RECOVERY
CARDHOLDER: $renterName
RENTAL COMPANY: ${rental.agency.title}
RENTAL AGREEMENT NO: ${if (rental.agreementNumber.isNotBlank()) rental.agreementNumber else "[AGREEMENT #]"}
DISPUTED AMOUNT: [INSERT CHARGE AMOUNT]

Dear Card Benefits & Disputes Team,

I am submitting the enclosed Certified Forensic Audit Dossier to dispute an erroneous damage assessment initiated by ${rental.agency.title} for vehicle ${rental.vehicleTitle} (Plate: ${rental.licensePlate}).

I captured complete, tamper-proof, GPS-stamped photographic evidence via the Walkaround protocol at both pick-up ($pickupDateStr at $pickupLoc) and drop-off ($dropoffDateStr at $dropoffLoc).

SUMMARY OF SUBMITTED EVIDENCE:
1. Multi-angle side-by-side photographic comparisons.
2. Verified dashboard odometer and fuel readings.
3. Photographic proof that the disputed damage was already present prior to my departure from the rental lot.

I request that your team review the attached documentation to reverse/chargeback any unauthorized merchant billing and protect my account under the cardholder collision protection policy.

Respectfully submitted,

$renterName
""".trimIndent()

            DisputeRecipient.TURO_SUPPORT -> """
DATE: $todayStr
TO: Turo Fair Claims Resolution Team
RE: TRIP DAMAGE DISPUTE & GUEST CHECK-IN REBUTTAL
RESERVATION ID: ${if (rental.agreementNumber.isNotBlank()) rental.agreementNumber else "[TURO TRIP ID]"}
VEHICLE: ${rental.vehicleTitle} (Plate: ${rental.licensePlate})

Dear Turo Resolution Specialist,

I am contesting the damage claim filed following the completion of my trip ending on $dropoffDateStr. 

As required by Turo's terms of service, I took detailed pre-trip check-in photos within the designated window prior to departure and complete post-trip checkout photos at drop-off.

The attached certified Walkaround dossier provides side-by-side comparison proof that the vehicle condition remained consistent throughout the trip and that the claimed flaw was pre-existing.

Thank you for reviewing the timestamped evidence.

Sincerely,
$renterName
""".trimIndent()

            DisputeRecipient.PERSONAL_INSURANCE -> """
DATE: $todayStr
TO: Insurance Claims Adjuster
RE: RENTAL CAR SUBROGATION DEFENSE - CLAIM # $claimNumber
INSURED: $renterName
RENTAL COMPANY: ${rental.agency.title}

Dear Adjuster,

Please find attached the certified photographic and GPS evidence package defending against the third-party subrogation notice received from ${rental.agency.title}.

The enclosed side-by-side inspection report establishes that the vehicle suffered no damage while under my care. Please include this evidence in the defense file.

Sincerely,
$renterName
""".trimIndent()
        }
    }
}
