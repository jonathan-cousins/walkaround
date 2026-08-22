package com.walkaround.app.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Speed
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.walkaround.app.models.FuelLevel
import com.walkaround.app.ui.theme.EmeraldPrimary
import com.walkaround.app.ui.theme.PorcelainBg
import com.walkaround.app.ui.theme.TextPrimary
import com.walkaround.app.ui.theme.TextSecondary

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DashboardCaptureScreen(
    initialOdometer: String = "",
    initialUnit: String = "mi",
    initialFuel: FuelLevel = FuelLevel.FULL,
    onSave: (String, String, FuelLevel) -> Unit,
    onCancel: () -> Unit
) {
    var odometer by remember { mutableStateOf(initialOdometer) }
    var unit by remember { mutableStateOf(initialUnit) }
    var fuel by remember { mutableStateOf(initialFuel) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Dashboard & Mileage Audit", fontWeight = FontWeight.Bold, fontSize = 18.sp) },
                navigationIcon = {
                    IconButton(onClick = onCancel) {
                        Icon(Icons.Default.Close, contentDescription = "Close")
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = PorcelainBg)
            )
        },
        containerColor = PorcelainBg
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(16.dp)
                .verticalScroll(rememberScrollState()),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Card 1: Odometer
            Card(
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = Color.White),
                modifier = Modifier.fillMaxWidth()
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("ODOMETER READING", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = TextSecondary)
                    Spacer(modifier = Modifier.height(8.dp))
                    OutlinedTextField(
                        value = odometer,
                        onValueChange = { odometer = it },
                        placeholder = { Text("e.g. 24,185") },
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                        singleLine = true,
                        leadingIcon = { Icon(Icons.Default.Speed, contentDescription = null, tint = EmeraldPrimary) },
                        modifier = Modifier.fillMaxWidth()
                    )
                    Spacer(modifier = Modifier.height(10.dp))
                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        FilterChip(
                            selected = unit == "mi",
                            onClick = { unit = "mi" },
                            label = { Text("Miles (mi)") }
                        )
                        FilterChip(
                            selected = unit == "km",
                            onClick = { unit = "km" },
                            label = { Text("Kilometers (km)") }
                        )
                    }
                }
            }

            // Card 2: Fuel Level
            Card(
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = Color.White),
                modifier = Modifier.fillMaxWidth()
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("FUEL / BATTERY CHARGE", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = TextSecondary)
                    Spacer(modifier = Modifier.height(10.dp))
                    FuelLevel.values().forEach { lvl ->
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(vertical = 4.dp)
                        ) {
                            RadioButton(
                                selected = fuel == lvl,
                                onClick = { fuel = lvl }
                            )
                            Text(
                                text = lvl.title,
                                fontSize = 14.sp,
                                fontWeight = if (fuel == lvl) FontWeight.Bold else FontWeight.Normal,
                                modifier = Modifier.padding(start = 8.dp)
                            )
                        }
                    }
                }
            }

            // Anti-Scam Notice
            Card(
                shape = RoundedCornerShape(14.dp),
                colors = CardDefaults.cardColors(containerColor = Color(0xFFFEF3C7)),
                modifier = Modifier.fillMaxWidth()
            ) {
                Column(modifier = Modifier.padding(14.dp)) {
                    Text("💡 Why this matters:", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = Color(0xFFB45309))
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                        "Rental companies often bill $9.99/gallon for missing fuel even if you returned it full. A timestamped dashboard photo disproves this instantly.",
                        fontSize = 12.sp,
                        color = Color(0xFF92400E),
                        lineHeight = 16.sp
                    )
                }
            }

            Spacer(modifier = Modifier.height(10.dp))

            Button(
                onClick = { onSave(odometer, unit, fuel) },
                colors = ButtonDefaults.buttonColors(containerColor = EmeraldPrimary),
                shape = RoundedCornerShape(12.dp),
                modifier = Modifier.fillMaxWidth().height(48.dp)
            ) {
                Text("Save Mileage & Fuel Audit", fontWeight = FontWeight.Bold)
            }
        }
    }
}
