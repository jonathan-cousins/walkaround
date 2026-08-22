package com.walkaround.app.models

enum class FuelLevel(val title: String, val fraction: Float) {
    FULL("Full (8/8)", 1.0f),
    SEVEN_EIGHTHS("7/8 Full", 0.875f),
    THREE_QUARTERS("3/4 Full", 0.75f),
    HALF("1/2 Full", 0.5f),
    ONE_QUARTER("1/4 Full", 0.25f),
    EMPTY("Empty (Need Gas)", 0.05f)
}
