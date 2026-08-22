package com.walkaround.app.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable

private val LightColorScheme = lightColorScheme(
    primary = EmeraldPrimary,
    onPrimary = CardSurface,
    secondary = AmberWarning,
    background = PorcelainBg,
    surface = CardSurface,
    onSurface = TextPrimary,
    outline = BorderSubtle
)

@Composable
fun WalkaroundTheme(
    content: @Composable () -> Unit
) {
    MaterialTheme(
        colorScheme = LightColorScheme,
        typography = Typography,
        content = content
    )
}
