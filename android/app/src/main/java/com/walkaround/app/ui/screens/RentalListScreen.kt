package com.walkaround.app.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.CameraAlt
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Description
import androidx.compose.material.icons.filled.Shield
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.walkaround.app.models.InspectionPhase
import com.walkaround.app.models.Rental
import com.walkaround.app.models.RentalAgency
import com.walkaround.app.models.RentalStatus
import com.walkaround.app.ui.components.StatusPill
import com.walkaround.app.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RentalListScreen(
    rentals: List<Rental>,
    onStartWalkaround: (Rental, InspectionPhase) -> Unit,
    onOpenDispute: (Rental) -> Unit,
    onAddNewRental: () -> Unit,
    onOpenPaywall: () -> Unit,
    onOpenOnboarding: () -> Unit
) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        text = "Walkaround",
                        fontWeight = FontWeight.Bold,
                        fontSize = 20.sp
                    )
                },
                navigationIcon = {
                    Button(
                        onClick = onOpenPaywall,
                        colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFFEF3C7)),
                        shape = RoundedCornerShape(16.dp),
                        contentPadding = PaddingValues(horizontal = 10.dp, vertical = 4.dp),
                        modifier = Modifier.padding(start = 12.dp)
                    ) {
                        Text("👑 PRO", color = AmberWarning, fontSize = 11.sp, fontWeight = FontWeight.Bold)
                    }
                },
                actions = {
                    IconButton(onClick = onOpenOnboarding) {
                        Text("❓", fontSize = 16.sp)
                    }
                    IconButton(
                        onClick = onAddNewRental,
                        modifier = Modifier
                            .padding(end = 8.dp)
                            .background(EmeraldPrimary, CircleShape)
                            .size(36.dp)
                    ) {
                        Icon(Icons.Default.Add, contentDescription = "Add Rental", tint = Color.White)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = PorcelainBg)
            )
        },
        containerColor = PorcelainBg
    ) { padding ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(horizontal = 16.dp),
            verticalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            // Hero Card: 30-Second Walkaround Shield
            item {
                Card(
                    shape = RoundedCornerShape(20.dp),
                    colors = CardDefaults.cardColors(containerColor = CardSurface),
                    elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(top = 4.dp)
                ) {
                    Column(modifier = Modifier.padding(20.dp)) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Text(
                                "⚡ FAST 30-SEC CHECK-IN",
                                color = EmeraldPrimary,
                                fontSize = 11.sp,
                                fontFamily = FontFamily.Monospace,
                                fontWeight = FontWeight.Bold
                            )
                        }
                        Spacer(modifier = Modifier.height(6.dp))
                        Text(
                            "Avoid Surprise Damage Bills",
                            fontSize = 18.sp,
                            fontWeight = FontWeight.Bold,
                            color = TextPrimary
                        )
                        Spacer(modifier = Modifier.height(4.dp))
                        Text(
                            "Walk around your car and snap 5 angles before leaving the lot. We auto-stamp GPS & time onto your photos.",
                            fontSize = 13.sp,
                            color = TextSecondary,
                            lineHeight = 18.sp
                        )
                        Spacer(modifier = Modifier.height(16.dp))
                        Button(
                            onClick = {
                                val target = rentals.firstOrNull() ?: Rental.createSample()
                                onStartWalkaround(target, InspectionPhase.PICKUP)
                            },
                            colors = ButtonDefaults.buttonColors(containerColor = EmeraldPrimary),
                            shape = RoundedCornerShape(12.dp),
                            modifier = Modifier.fillMaxWidth().height(46.dp)
                        ) {
                            Icon(Icons.Default.CameraAlt, contentDescription = null, modifier = Modifier.size(18.dp))
                            Spacer(modifier = Modifier.width(8.dp))
                            Text("Start 30-Sec Walkaround", fontWeight = FontWeight.Bold)
                        }
                    }
                }
            }

            // Section Header
            item {
                Row(
                    modifier = Modifier.fillMaxWidth().padding(top = 8.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        "ACTIVE VEHICLE DOSSIERS",
                        fontSize = 12.sp,
                        fontFamily = FontFamily.Monospace,
                        fontWeight = FontWeight.Bold,
                        color = TextSecondary
                    )
                    Text("${rentals.size} Vehicles", fontSize = 12.sp, color = TextSecondary)
                }
            }

            // Rental Cards
            items(rentals, key = { it.id }) { rental ->
                RentalCard(
                    rental = rental,
                    onStartPickup = { onStartWalkaround(rental, InspectionPhase.PICKUP) },
                    onStartDropoff = { onStartWalkaround(rental, InspectionPhase.DROPOFF) },
                    onOpenDispute = { onOpenDispute(rental) }
                )
            }

            item {
                Spacer(modifier = Modifier.height(30.dp))
            }
        }
    }
}

@Composable
fun RentalCard(
    rental: Rental,
    onStartPickup: () -> Unit,
    onStartDropoff: () -> Unit,
    onOpenDispute: () -> Unit
) {
    Card(
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = CardSurface),
        elevation = CardDefaults.cardElevation(defaultElevation = 1.dp),
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                StatusPill(status = rental.status)
                Text(
                    text = rental.agency.title,
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Bold,
                    color = TextSecondary
                )
            }

            Spacer(modifier = Modifier.height(10.dp))

            Text(
                text = rental.vehicleTitle,
                fontSize = 17.sp,
                fontWeight = FontWeight.Bold,
                color = TextPrimary
            )

            Spacer(modifier = Modifier.height(4.dp))

            Row(verticalAlignment = Alignment.CenterVertically) {
                Box(
                    modifier = Modifier
                        .background(Color(0xFFF1F5F9), RoundedCornerShape(6.dp))
                        .padding(horizontal = 6.dp, vertical = 2.dp)
                ) {
                    Text(
                        text = "${rental.licensePlate} (${rental.stateOrCountry})",
                        fontSize = 11.sp,
                        fontFamily = FontFamily.Monospace,
                        fontWeight = FontWeight.Bold
                    )
                }
                if (rental.agreementNumber.isNotBlank()) {
                    Spacer(modifier = Modifier.width(8.dp))
                    Text("• Res #${rental.agreementNumber}", fontSize = 12.sp, color = TextSecondary)
                }
            }

            Spacer(modifier = Modifier.height(14.dp))
            HorizontalDivider(color = BorderSubtle, thickness = 0.8.dp)
            Spacer(modifier = Modifier.height(12.dp))

            // Inspection Step Indicators
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                // Pickup Badge
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .background(if (rental.hasPickupCompleted) Color(0xFFF0FDF4) else Color(0xFFF8FAFC), RoundedCornerShape(10.dp))
                        .clickable { onStartPickup() }
                        .padding(10.dp)
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(
                            imageVector = if (rental.hasPickupCompleted) Icons.Default.CheckCircle else Icons.Default.CameraAlt,
                            contentDescription = null,
                            tint = if (rental.hasPickupCompleted) EmeraldPrimary else TextSecondary,
                            modifier = Modifier.size(18.dp)
                        )
                        Spacer(modifier = Modifier.width(6.dp))
                        Column {
                            Text("1. PICK-UP", fontSize = 10.sp, fontWeight = FontWeight.Bold, color = TextSecondary)
                            Text(if (rental.hasPickupCompleted) "Verified" else "Start (5 Shots)", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = if (rental.hasPickupCompleted) EmeraldPrimary else TextPrimary)
                        }
                    }
                }

                // Dropoff Badge
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .background(if (rental.hasDropoffCompleted) Color(0xFFF0FDF4) else Color(0xFFF8FAFC), RoundedCornerShape(10.dp))
                        .clickable { onStartDropoff() }
                        .padding(10.dp)
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(
                            imageVector = if (rental.hasDropoffCompleted) Icons.Default.CheckCircle else Icons.Default.CameraAlt,
                            contentDescription = null,
                            tint = if (rental.hasDropoffCompleted) EmeraldPrimary else TextSecondary,
                            modifier = Modifier.size(18.dp)
                        )
                        Spacer(modifier = Modifier.width(6.dp))
                        Column {
                            Text("2. RETURN", fontSize = 10.sp, fontWeight = FontWeight.Bold, color = TextSecondary)
                            Text(if (rental.hasDropoffCompleted) "Verified" else "Start Return", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = if (rental.hasDropoffCompleted) EmeraldPrimary else TextPrimary)
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(12.dp))

            // Primary Dispute Action Button
            Button(
                onClick = onOpenDispute,
                colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFFEF2F2)),
                shape = RoundedCornerShape(10.dp),
                modifier = Modifier.fillMaxWidth().height(42.dp)
            ) {
                Icon(Icons.Default.Shield, contentDescription = null, tint = Color(0xFFDC2626), modifier = Modifier.size(16.dp))
                Spacer(modifier = Modifier.width(8.dp))
                Text("I Got Billed (Dispute Dossier & Letter)", color = Color(0xFFDC2626), fontSize = 12.sp, fontWeight = FontWeight.Bold)
            }
        }
    }
}
