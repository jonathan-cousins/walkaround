package com.walkaround.app.services

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import com.google.gson.Gson
import com.google.gson.GsonBuilder
import com.google.gson.reflect.TypeToken
import com.walkaround.app.models.Rental
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.withContext
import java.io.File
import java.io.FileOutputStream

class RentalRepository(private val context: Context) {
    private val gson: Gson = GsonBuilder().setPrettyPrinting().create()
    private val storageFile: File get() = File(context.filesDir, "walkaround_rentals.json")
    private val photosDir: File get() = File(context.filesDir, "InspectionPhotos").apply { if (!exists()) mkdirs() }

    private val _rentals = MutableStateFlow<List<Rental>>(emptyList())
    val rentals: StateFlow<List<Rental>> = _rentals.asStateFlow()

    init {
        loadRentals()
    }

    fun loadRentals() {
        try {
            if (storageFile.exists()) {
                val json = storageFile.readText()
                val type = object : TypeToken<List<Rental>>() {}.type
                val loaded: List<Rental>? = gson.fromJson(json, type)
                _rentals.value = loaded ?: listOf(Rental.createSample())
            } else {
                _rentals.value = listOf(Rental.createSample())
                saveRentals()
            }
        } catch (e: Exception) {
            e.printStackTrace()
            _rentals.value = listOf(Rental.createSample())
        }
    }

    fun saveRentals() {
        try {
            val json = gson.toJson(_rentals.value)
            storageFile.writeText(json)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun addRental(rental: Rental) {
        _rentals.value = listOf(rental) + _rentals.value
        saveRentals()
    }

    fun updateRental(rental: Rental) {
        _rentals.value = _rentals.value.map { if (it.id == rental.id) rental else it }
        saveRentals()
    }

    fun deleteRental(rentalId: String) {
        _rentals.value = _rentals.value.filter { it.id != rentalId }
        saveRentals()
    }

    suspend fun saveImage(bitmap: Bitmap, filename: String): File? = withContext(Dispatchers.IO) {
        try {
            val file = File(photosDir, filename)
            FileOutputStream(file).use { out ->
                bitmap.compress(Bitmap.CompressFormat.JPEG, 88, out)
            }
            file
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }

    fun loadImage(filename: String): Bitmap? {
        val file = File(photosDir, filename)
        return if (file.exists()) BitmapFactory.decodeFile(file.absolutePath) else null
    }

    companion object {
        @Volatile
        private var INSTANCE: RentalRepository? = null

        fun getInstance(context: Context): RentalRepository {
            return INSTANCE ?: synchronized(this) {
                INSTANCE ?: RentalRepository(context.applicationContext).also { INSTANCE = it }
            }
        }
    }
}
