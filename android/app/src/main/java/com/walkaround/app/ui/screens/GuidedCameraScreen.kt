package com.walkaround.app.ui.screens

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import androidx.camera.core.*
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalLifecycleOwner
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.core.content.ContextCompat
import com.walkaround.app.models.*
import com.walkaround.app.services.LocationService
import com.walkaround.app.services.RentalRepository
import com.walkaround.app.services.WatermarkService
import com.walkaround.app.ui.components.GhostOverlay
import com.walkaround.app.ui.components.HUDTimestampBadge
import com.walkaround.app.ui.theme.AmberWarning
import com.walkaround.app.ui.theme.EmeraldPrimary
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.util.Date
import java.util.concurrent.Executors

@Composable
fun GuidedCameraScreen(
    rental: Rental,
    phase: InspectionPhase,
    onFinish: () -> Unit,
    onCancel: () -> Unit
) {
    val context = LocalContext.current
    val lifecycleOwner = LocalLifecycleOwner.current
    val scope = rememberCoroutineScope()
    val repository = remember { RentalRepository.getInstance(context) }
    val locationService = remember { LocationService(context) }

    val zones = VehicleZoneId.quick5Zones
    var currentZoneIndex by remember { mutableStateOf(0) }
    val currentZone = zones[currentZoneIndex]

    val capturedPhotos = remember { mutableStateMapOf<VehicleZoneId, Bitmap>() }
    var isCapturing by remember { mutableStateOf(false) }
    var flashEnabled by remember { mutableStateOf(false) }
    var imageCapture: ImageCapture? by remember { mutableStateOf(null) }

    val currentCapturedBitmap = capturedPhotos[currentZone]

    Box(modifier = Modifier.fillMaxSize().background(Color.Black)) {
        // 1. Camera Viewfinder or Frozen Photo
        if (currentCapturedBitmap != null) {
            Image(
                bitmap = currentCapturedBitmap.asImageBitmap(),
                contentDescription = "Captured Photo",
                modifier = Modifier.fillMaxSize()
            )
        } else {
            AndroidView(
                factory = { ctx ->
                    val previewView = PreviewView(ctx)
                    val cameraProviderFuture = ProcessCameraProvider.getInstance(ctx)
                    cameraProviderFuture.addListener({
                        val cameraProvider = cameraProviderFuture.get()
                        val preview = Preview.Builder().build().also {
                            it.setSurfaceProvider(previewView.surfaceProvider)
                        }
                        val capture = ImageCapture.Builder()
                            .setCaptureMode(ImageCapture.CAPTURE_MODE_MINIMIZE_LATENCY)
                            .setFlashMode(if (flashEnabled) ImageCapture.FLASH_MODE_ON else ImageCapture.FLASH_MODE_OFF)
                            .build()
                        imageCapture = capture

                        val cameraSelector = CameraSelector.DEFAULT_BACK_CAMERA
                        try {
                            cameraProvider.unbindAll()
                            cameraProvider.bindToLifecycle(lifecycleOwner, cameraSelector, preview, capture)
                        } catch (e: Exception) {
                            e.printStackTrace()
                        }
                    }, ContextCompat.getMainExecutor(ctx))
                    previewView
                },
                modifier = Modifier.fillMaxSize()
            )

            // Ghost Wireframe
            GhostOverlay(type = currentZone.wireframeType)
        }

        // 2. Top HUD Controls
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .statusBarsPadding()
                .padding(16.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                IconButton(
                    onClick = onCancel,
                    modifier = Modifier.background(Color.Black.copy(alpha = 0.6f), CircleShape)
                ) {
                    Icon(Icons.Default.Close, contentDescription = "Close", tint = Color.White)
                }

                HUDTimestampBadge()

                IconButton(
                    onClick = { flashEnabled = !flashEnabled },
                    modifier = Modifier.background(Color.Black.copy(alpha = 0.6f), CircleShape)
                ) {
                    Icon(
                        if (flashEnabled) Icons.Default.FlashOn else Icons.Default.FlashOff,
                        contentDescription = "Flash",
                        tint = if (flashEnabled) Color.Yellow else Color.White
                    )
                }
            }

            Spacer(modifier = Modifier.height(12.dp))

            // Step Progress Bar
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "${phase.stampPrefix} • STEP ${currentZoneIndex + 1} OF ${zones.size}",
                    color = Color.Yellow,
                    fontSize = 11.sp,
                    fontFamily = FontFamily.Monospace,
                    fontWeight = FontWeight.Bold
                )
                Text(
                    text = currentZone.shortTitle,
                    color = Color.White,
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Bold
                )
            }

            Spacer(modifier = Modifier.height(6.dp))

            LinearProgressIndicator(
                progress = { (currentZoneIndex + 1f) / zones.size },
                modifier = Modifier.fillMaxWidth().height(4.dp).clip(RoundedCornerShape(2.dp)),
                color = EmeraldPrimary,
                trackColor = Color.White.copy(alpha = 0.3f)
            )
        }

        // 3. Bottom Controls & Stepper
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .align(Alignment.BottomCenter)
                .navigationBarsPadding()
                .padding(bottom = 20.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Zone Instruction Pill
            Surface(
                color = Color.Black.copy(alpha = 0.75f),
                shape = RoundedCornerShape(10.dp),
                modifier = Modifier.padding(horizontal = 20.dp)
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier.padding(horizontal = 12.dp, vertical = 8.dp)
                ) {
                    Icon(Icons.Default.Info, contentDescription = null, tint = Color.Yellow, modifier = Modifier.size(16.dp))
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = currentZone.instruction,
                        color = Color.White,
                        fontSize = 12.sp,
                        lineHeight = 16.sp
                    )
                }
            }

            Spacer(modifier = Modifier.height(20.dp))

            // Shutter & Navigation Buttons
            Row(
                modifier = Modifier.fillMaxWidth().padding(horizontal = 30.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Back Button
                IconButton(
                    onClick = { if (currentZoneIndex > 0) currentZoneIndex-- },
                    enabled = currentZoneIndex > 0,
                    modifier = Modifier
                        .size(48.dp)
                        .background(if (currentZoneIndex > 0) Color.White.copy(alpha = 0.2f) else Color.Transparent, CircleShape)
                ) {
                    Icon(Icons.Default.ArrowBack, contentDescription = "Previous", tint = if (currentZoneIndex > 0) Color.White else Color.Transparent)
                }

                // Shutter / Checkmark Button
                Box(
                    contentAlignment = Alignment.Center,
                    modifier = Modifier
                        .size(76.dp)
                        .clip(CircleShape)
                        .border(4.dp, Color.White, CircleShape)
                        .clickable(enabled = !isCapturing) {
                            if (currentCapturedBitmap != null) {
                                // Already captured, advance
                                if (currentZoneIndex < zones.size - 1) {
                                    currentZoneIndex++
                                } else {
                                    // Complete Inspection
                                    finalizeInspection(rental, phase, repository)
                                    onFinish()
                                }
                            } else {
                                // Trigger Photo Capture
                                isCapturing = true
                                val executor = Executors.newSingleThreadExecutor()
                                val capture = imageCapture
                                if (capture != null) {
                                    capture.takePicture(
                                        executor,
                                        object : ImageCapture.OnImageCapturedCallback() {
                                            override fun onCaptureSuccess(imageProxy: ImageProxy) {
                                                val bitmap = imageProxyToBitmap(imageProxy)
                                                imageProxy.close()

                                                scope.launch {
                                                    val loc = locationService.captureSnapshot()
                                                    val stamped = withContext(Dispatchers.Default) {
                                                        WatermarkService.stampImage(
                                                            original = bitmap,
                                                            phase = phase,
                                                            location = loc,
                                                            vehicleSummary = rental.vehicleTitle,
                                                            licensePlate = rental.licensePlate,
                                                            zoneTitle = currentZone.title,
                                                            agencyName = rental.agency.title
                                                        )
                                                    }

                                                    val filename = "photo_${rental.id}_${phase.name}_${currentZone.name}.jpg"
                                                    repository.saveImage(stamped.bitmap, filename)

                                                    val evidence = PhotoEvidence(
                                                        zoneId = currentZone,
                                                        filename = filename,
                                                        capturedAt = System.currentTimeMillis(),
                                                        location = loc,
                                                        hashSHA256 = stamped.sha256
                                                    )

                                                    val inspection = if (phase == InspectionPhase.PICKUP) {
                                                        rental.pickupInspection ?: Inspection(phase = InspectionPhase.PICKUP).also { rental.pickupInspection = it }
                                                    } else {
                                                        rental.dropoffInspection ?: Inspection(phase = InspectionPhase.DROPOFF).also { rental.dropoffInspection = it }
                                                    }
                                                    inspection.setPhoto(evidence, currentZone)
                                                    rental.updatedAt = System.currentTimeMillis()
                                                    repository.updateRental(rental)

                                                    capturedPhotos[currentZone] = stamped.bitmap
                                                    isCapturing = false

                                                    if (currentZoneIndex < zones.size - 1) {
                                                        currentZoneIndex++
                                                    }
                                                }
                                            }

                                            override fun onError(exception: ImageCaptureException) {
                                                exception.printStackTrace()
                                                isCapturing = false
                                            }
                                        }
                                    )
                                } else {
                                    // Fallback for emulator without camera
                                    scope.launch {
                                        val loc = locationService.captureSnapshot()
                                        val dummyBitmap = Bitmap.createBitmap(1280, 720, Bitmap.Config.ARGB_8888)
                                        val stamped = WatermarkService.stampImage(
                                            original = dummyBitmap,
                                            phase = phase,
                                            location = loc,
                                            vehicleSummary = rental.vehicleTitle,
                                            licensePlate = rental.licensePlate,
                                            zoneTitle = currentZone.title,
                                            agencyName = rental.agency.title
                                        )
                                        capturedPhotos[currentZone] = stamped.bitmap
                                        isCapturing = false
                                        if (currentZoneIndex < zones.size - 1) {
                                            currentZoneIndex++
                                        }
                                    }
                                }
                            }
                        }
                ) {
                    Box(
                        modifier = Modifier
                            .size(62.dp)
                            .background(if (currentCapturedBitmap != null) EmeraldPrimary else Color.White, CircleShape)
                    ) {
                        if (currentCapturedBitmap != null) {
                            Icon(Icons.Default.Check, contentDescription = null, tint = Color.White, modifier = Modifier.align(Alignment.Center))
                        }
                    }
                }

                // Next Button
                IconButton(
                    onClick = {
                        if (currentZoneIndex < zones.size - 1) {
                            currentZoneIndex++
                        } else {
                            finalizeInspection(rental, phase, repository)
                            onFinish()
                        }
                    },
                    modifier = Modifier
                        .size(48.dp)
                        .background(Color.White.copy(alpha = 0.2f), CircleShape)
                ) {
                    Icon(
                        if (currentZoneIndex == zones.size - 1) Icons.Default.Check else Icons.Default.ArrowForward,
                        contentDescription = "Next",
                        tint = Color.White
                    )
                }
            }
        }
    }
}

private fun finalizeInspection(rental: Rental, phase: InspectionPhase, repository: RentalRepository) {
    if (phase == InspectionPhase.PICKUP) {
        val insp = rental.pickupInspection ?: Inspection(phase = InspectionPhase.PICKUP).also { rental.pickupInspection = it }
        insp.isCompleted = true
        insp.completedAt = System.currentTimeMillis()
        rental.status = RentalStatus.ACTIVE
    } else {
        val insp = rental.dropoffInspection ?: Inspection(phase = InspectionPhase.DROPOFF).also { rental.dropoffInspection = it }
        insp.isCompleted = true
        insp.completedAt = System.currentTimeMillis()
        rental.status = RentalStatus.RETURNED
    }
    rental.updatedAt = System.currentTimeMillis()
    repository.updateRental(rental)
}

private fun imageProxyToBitmap(image: ImageProxy): Bitmap {
    val planeProxy = image.planes[0]
    val buffer = planeProxy.buffer
    val bytes = ByteArray(buffer.remaining())
    buffer.get(bytes)
    val bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.size)
    val matrix = Matrix()
    matrix.postRotate(image.imageInfo.rotationDegrees.toFloat())
    return Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true)
}
