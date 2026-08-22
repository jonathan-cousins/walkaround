package com.walkaround.app.services

import android.annotation.SuppressLint
import android.content.Context
import android.location.Geocoder
import android.location.Location
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.Priority
import com.walkaround.app.models.LocationSnapshot
import kotlinx.coroutines.suspendCancellableCoroutine
import java.util.Locale
import kotlin.coroutines.resume

class LocationService(private val context: Context) {
    private val fusedClient = LocationServices.getFusedLocationProviderClient(context)

    @SuppressLint("MissingPermission")
    suspend fun captureSnapshot(): LocationSnapshot = suspendCancellableCoroutine { continuation ->
        try {
            fusedClient.getCurrentLocation(Priority.PRIORITY_HIGH_ACCURACY, null)
                .addOnSuccessListener { location: Location? ->
                    if (location != null) {
                        val geocoder = Geocoder(context, Locale.getDefault())
                        val addresses = try {
                            geocoder.getFromLocation(location.latitude, location.longitude, 1)
                        } catch (e: Exception) {
                            null
                        }
                        val address = addresses?.firstOrNull()
                        val placeName = address?.featureName ?: address?.locality ?: "Current Location"
                        val formatted = address?.getAddressLine(0) ?: "$placeName, GPS: ${location.latitude}, ${location.longitude}"

                        continuation.resume(
                            LocationSnapshot(
                                latitude = location.latitude,
                                longitude = location.longitude,
                                altitude = location.altitude,
                                placeName = placeName,
                                formattedAddress = formatted
                            )
                        )
                    } else {
                        continuation.resume(LocationSnapshot(placeName = "Airport / Rental Station"))
                    }
                }
                .addOnFailureListener {
                    continuation.resume(LocationSnapshot(placeName = "Rental Station"))
                }
        } catch (e: Exception) {
            continuation.resume(LocationSnapshot(placeName = "Rental Station"))
        }
    }
}
