package com.walkaround.app.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.walkaround.app.models.RentalStatus
import com.walkaround.app.ui.theme.AmberLight
import com.walkaround.app.ui.theme.AmberWarning
import com.walkaround.app.ui.theme.EmeraldLight
import com.walkaround.app.ui.theme.EmeraldPrimary

@Composable
fun StatusPill(status: RentalStatus) {
    val (bgColor, textColor) = when (status) {
        RentalStatus.ACTIVE -> EmeraldLight to EmeraldPrimary
        RentalStatus.UPCOMING -> Color(0xFFEFF6FF) to Color(0xFF2563EB)
        RentalStatus.RETURNED -> Color(0xFFF1F5F9) to Color(0xFF64748B)
        RentalStatus.DISPUTED -> AmberLight to AmberWarning
    }

    Box(
        modifier = Modifier
            .background(color = bgColor, shape = RoundedCornerShape(12.dp))
            .padding(horizontal = 8.dp, vertical = 3.dp)
    ) {
        Text(
            text = status.title.uppercase(),
            color = textColor,
            fontSize = 10.sp,
            fontWeight = FontWeight.Bold
        )
    }
}
