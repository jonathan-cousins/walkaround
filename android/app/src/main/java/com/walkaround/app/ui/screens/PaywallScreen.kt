package com.walkaround.app.ui.screens

import android.content.Intent
import android.net.Uri
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.walkaround.app.ui.theme.EmeraldPrimary
import com.walkaround.app.ui.theme.PorcelainBg
import com.walkaround.app.ui.theme.TextPrimary
import com.walkaround.app.ui.theme.TextSecondary

@Composable
fun PaywallScreen(
    onDismiss: () -> Unit
) {
    val context = LocalContext.current
    var selectedPlan by remember { mutableStateOf(1) } // 0: Single, 1: Annual, 2: Lifetime

    Surface(
        modifier = Modifier.fillMaxSize(),
        color = PorcelainBg
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .statusBarsPadding()
                .padding(20.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.End) {
                IconButton(onClick = onDismiss) {
                    Icon(Icons.Default.Close, contentDescription = "Close")
                }
            }

            Text("👑", fontSize = 42.sp)
            Spacer(modifier = Modifier.height(10.dp))
            Text(
                "Protect Yourself from\nUnexpected Damage Bills",
                fontSize = 20.sp,
                fontWeight = FontWeight.Bold,
                textAlign = TextAlign.Center,
                color = TextPrimary
            )
            Spacer(modifier = Modifier.height(6.dp))
            Text(
                "Rental agencies bill thousands daily for pre-existing scratches. Walkaround gives you clear, timestamped proof of your car's true condition.",
                fontSize = 13.sp,
                color = TextSecondary,
                textAlign = TextAlign.Center,
                lineHeight = 18.sp
            )

            Spacer(modifier = Modifier.height(24.dp))

            // Plan Options
            val plans = listOf(
                Triple("Single Trip Pass", "$2.99", "1 car check-in & certified PDF"),
                Triple("Annual Pro Pass", "$19.99 / yr", "Unlimited rentals + dispute pack (Recommended)"),
                Triple("Lifetime Unlimited", "$39.99", "One-time purchase forever")
            )

            plans.forEachIndexed { index, triple ->
                val isSelected = selectedPlan == index
                Card(
                    shape = RoundedCornerShape(14.dp),
                    colors = CardDefaults.cardColors(containerColor = if (isSelected) Color(0xFFF0FDF4) else Color.White),
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 5.dp)
                        .border(
                            width = if (isSelected) 2.dp else 1.dp,
                            color = if (isSelected) EmeraldPrimary else Color(0xFFE2E8F0),
                            shape = RoundedCornerShape(14.dp)
                        )
                        .clickable { selectedPlan = index }
                ) {
                    Row(
                        modifier = Modifier.padding(16.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Column(modifier = Modifier.weight(1f)) {
                            Text(triple.first, fontWeight = FontWeight.Bold, fontSize = 15.sp, color = TextPrimary)
                            Text(triple.third, fontSize = 11.sp, color = TextSecondary)
                        }
                        Text(triple.second, fontWeight = FontWeight.Bold, fontSize = 16.sp, color = if (isSelected) EmeraldPrimary else TextPrimary)
                    }
                }
            }

            Spacer(modifier = Modifier.weight(1f))

            Button(
                onClick = { onDismiss() },
                colors = ButtonDefaults.buttonColors(containerColor = EmeraldPrimary),
                shape = RoundedCornerShape(14.dp),
                modifier = Modifier.fillMaxWidth().height(50.dp)
            ) {
                Text("Continue", fontWeight = FontWeight.Bold, fontSize = 16.sp)
            }

            Spacer(modifier = Modifier.height(14.dp))

            Row(horizontalArrangement = Arrangement.Center, modifier = Modifier.fillMaxWidth()) {
                Text(
                    "Terms of Service",
                    fontSize = 11.sp,
                    color = TextSecondary,
                    modifier = Modifier.clickable {
                        context.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("https://walkaround.app/terms")))
                    }
                )
                Text(" • ", fontSize = 11.sp, color = TextSecondary)
                Text(
                    "Privacy Policy",
                    fontSize = 11.sp,
                    color = TextSecondary,
                    modifier = Modifier.clickable {
                        context.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("https://walkaround.app/privacy")))
                    }
                )
            }
        }
    }
}
