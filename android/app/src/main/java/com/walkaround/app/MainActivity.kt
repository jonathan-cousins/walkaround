package com.walkaround.app

import android.Manifest
import android.content.pm.PackageManager
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.runtime.*
import androidx.core.content.ContextCompat
import com.walkaround.app.models.InspectionPhase
import com.walkaround.app.models.Rental
import com.walkaround.app.services.RentalRepository
import com.walkaround.app.ui.screens.*
import com.walkaround.app.ui.theme.WalkaroundTheme

class MainActivity : ComponentActivity() {

    private val permissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) { _ -> }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Request Camera & Location permissions
        requestPermissions()

        val repository = RentalRepository.getInstance(applicationContext)

        setContent {
            WalkaroundTheme {
                val rentals by repository.rentals.collectAsState()

                var currentScreen by remember { mutableStateOf<Screen>(Screen.Home) }
                var showNewRentalDialog by remember { mutableStateOf(false) }
                var showPaywall by remember { mutableStateOf(false) }
                var showOnboarding by remember { mutableStateOf(false) }

                when (val screen = currentScreen) {
                    is Screen.Home -> {
                        RentalListScreen(
                            rentals = rentals,
                            onStartWalkaround = { rental, phase ->
                                currentScreen = Screen.Camera(rental, phase)
                            },
                            onOpenDispute = { rental ->
                                currentScreen = Screen.Dispute(rental)
                            },
                            onAddNewRental = { showNewRentalDialog = true },
                            onOpenPaywall = { showPaywall = true },
                            onOpenOnboarding = { showOnboarding = true }
                        )

                        if (showNewRentalDialog) {
                            NewRentalDialog(
                                onDismiss = { showNewRentalDialog = false },
                                onConfirm = { newRental ->
                                    repository.addRental(newRental)
                                    showNewRentalDialog = false
                                }
                            )
                        }

                        if (showPaywall) {
                            PaywallScreen(onDismiss = { showPaywall = false })
                        }

                        if (showOnboarding) {
                            OnboardingScreen(onFinish = { showOnboarding = false })
                        }
                    }

                    is Screen.Camera -> {
                        GuidedCameraScreen(
                            rental = screen.rental,
                            phase = screen.phase,
                            onFinish = { currentScreen = Screen.Home },
                            onCancel = { currentScreen = Screen.Home }
                        )
                    }

                    is Screen.Dispute -> {
                        DisputeDossierScreen(
                            rental = screen.rental,
                            onBack = { currentScreen = Screen.Home }
                        )
                    }
                }
            }
        }
    }

    private fun requestPermissions() {
        val permissions = arrayOf(
            Manifest.permission.CAMERA,
            Manifest.permission.ACCESS_FINE_LOCATION,
            Manifest.permission.ACCESS_COARSE_LOCATION
        )
        val missing = permissions.filter {
            ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
        }
        if (missing.isNotEmpty()) {
            permissionLauncher.launch(missing.toTypedArray())
        }
    }
}

sealed class Screen {
    object Home : Screen()
    data class Camera(val rental: Rental, val phase: InspectionPhase) : Screen()
    data class Dispute(val rental: Rental) : Screen()
}
