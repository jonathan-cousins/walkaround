package com.walkaround.app.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.walkaround.app.ui.theme.EmeraldPrimary
import com.walkaround.app.ui.theme.PorcelainBg
import com.walkaround.app.ui.theme.TextPrimary
import com.walkaround.app.ui.theme.TextSecondary

@Composable
fun OnboardingScreen(
    onFinish: () -> Unit
) {
    var step by remember { mutableStateOf(0) }

    val slides = listOf(
        Triple("📸", "STEP 1: 30-SEC WALKTHROUGH", "Follow the friendly wireframes around 5 perimeter angles. We automatically burn UTC time and GPS into your photos."),
        Triple("⚠️", "STEP 2: PRE-EXISTING DAMAGE", "Spot a scratch or curb rash on a rim? Tap on screen to pin it directly onto the inspection report."),
        Triple("⏱️", "STEP 3: DASHBOARD CHECK", "Snap one photo of the odometer and fuel gauge with ignition ON so the rental agency can never bill you for 'missing gas.'"),
        Triple("🛡️", "STEP 4: 1-TAP DISPUTE PACK", "If an agency sends a surprise bill weeks later, tap 1 button to export a structured PDF comparison dossier and rebuttal letter.")
    )

    val current = slides[step]

    Surface(
        modifier = Modifier.fillMaxSize(),
        color = PorcelainBg
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .statusBarsPadding()
                .padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                Text("STEP ${step + 1} OF ${slides.size}", fontSize = 11.sp, fontFamily = FontFamily.Monospace, fontWeight = FontWeight.Bold, color = TextSecondary)
                TextButton(onClick = onFinish) {
                    Text("Skip", color = EmeraldPrimary, fontWeight = FontWeight.Bold)
                }
            }

            Spacer(modifier = Modifier.weight(0.8f))

            Text(current.first, fontSize = 64.sp)
            Spacer(modifier = Modifier.height(20.dp))
            Text(current.second, fontSize = 12.sp, fontFamily = FontFamily.Monospace, fontWeight = FontWeight.Bold, color = EmeraldPrimary)
            Spacer(modifier = Modifier.height(10.dp))
            Text(
                current.third,
                fontSize = 15.sp,
                textAlign = TextAlign.Center,
                color = TextPrimary,
                lineHeight = 22.sp,
                modifier = Modifier.padding(horizontal = 10.dp)
            )

            Spacer(modifier = Modifier.weight(1f))

            Button(
                onClick = {
                    if (step < slides.size - 1) step++ else onFinish()
                },
                colors = ButtonDefaults.buttonColors(containerColor = EmeraldPrimary),
                shape = RoundedCornerShape(14.dp),
                modifier = Modifier.fillMaxWidth().height(50.dp)
            ) {
                Text(if (step == slides.size - 1) "Start My First Walkaround (Free)" else "Next Step", fontWeight = FontWeight.Bold, fontSize = 15.sp)
            }
        }
    }
}
