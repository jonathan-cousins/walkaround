package com.walkaround.app.ui.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.PathEffect
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.unit.dp
import com.walkaround.app.models.WireframeType

@Composable
fun GhostOverlay(type: WireframeType) {
    Canvas(modifier = Modifier.fillMaxSize()) {
        val w = size.width
        val h = size.height
        val dashEffect = PathEffect.dashPathEffect(floatArrayOf(20f, 15f), 0f)
        val strokeColor = Color.White.copy(alpha = 0.5f)

        // Outer Bounding Box
        drawRoundRect(
            color = strokeColor,
            topLeft = Offset(w * 0.1f, h * 0.22f),
            size = Size(w * 0.8f, h * 0.52f),
            cornerRadius = CornerRadius(24.dp.toPx()),
            style = Stroke(width = 3.dp.toPx(), pathEffect = dashEffect)
        )

        // Center Alignment Crosshairs
        val centerX = w / 2f
        val centerY = h * 0.48f
        val armLen = 30.dp.toPx()

        drawLine(
            color = Color.White.copy(alpha = 0.8f),
            start = Offset(centerX - armLen, centerY),
            end = Offset(centerX + armLen, centerY),
            strokeWidth = 2.dp.toPx()
        )
        drawLine(
            color = Color.White.copy(alpha = 0.8f),
            start = Offset(centerX, centerY - armLen),
            end = Offset(centerX, centerY + armLen),
            strokeWidth = 2.dp.toPx()
        )
    }
}
