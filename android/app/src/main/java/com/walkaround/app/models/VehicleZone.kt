package com.walkaround.app.models

enum class WireframeType {
    FRONT,
    DRIVER_SIDE,
    REAR,
    PASSENGER_SIDE,
    WHEEL,
    WINDSHIELD,
    ROOF,
    INTERIOR_DASH
}

enum class VehicleZoneId(
    val title: String,
    val shortTitle: String,
    val instruction: String,
    val wireframeType: WireframeType,
    val isRequiredForBasicPass: Boolean
) {
    FRONT_BUMPER("Front Bumper & Hood", "Front", "Stand 6ft back facing front. Check lower lip, grill & license plate.", WireframeType.FRONT, true),
    DRIVER_SIDE("Driver Side & Wheels", "Driver Side", "Stand 8ft back. Capture entire left profile, doors and wheels.", WireframeType.DRIVER_SIDE, true),
    REAR_BUMPER("Rear Bumper & Trunk", "Rear", "Stand 6ft back facing rear. Check bumper corners, trunk & lights.", WireframeType.REAR, true),
    PASSENGER_SIDE("Passenger Side & Wheels", "Pass Side", "Stand 8ft back. Capture entire right profile, doors and wheels.", WireframeType.PASSENGER_SIDE, true),
    DASHBOARD_ODOMETER("Dashboard (Odometer & Fuel)", "Dashboard", "Ignition ON. Capture odometer digits and fuel gauge needle.", WireframeType.INTERIOR_DASH, true),

    // Extended 12-zone items
    DRIVER_FRONT_WHEEL("Driver Front Wheel & Tire", "D. Front Rim", "Inspect rim for curb rash and tire sidewalls for bubbles.", WireframeType.WHEEL, false),
    DRIVER_REAR_WHEEL("Driver Rear Wheel & Tire", "D. Rear Rim", "Inspect rear rim for curb rash and tire condition.", WireframeType.WHEEL, false),
    PASSENGER_FRONT_WHEEL("Passenger Front Wheel & Tire", "P. Front Rim", "Inspect passenger front rim for curb rash.", WireframeType.WHEEL, false),
    PASSENGER_REAR_WHEEL("Passenger Rear Wheel & Tire", "P. Rear Rim", "Inspect passenger rear rim for curb rash.", WireframeType.WHEEL, false),
    WINDSHIELD("Windshield & Roof", "Windshield", "Check glass for rock chips, star cracks, and wiper scratches.", WireframeType.WINDSHIELD, false),
    ROOF_SURFACE("Roof Surface", "Roof", "Check roof panel for hail dents or luggage rack scratches.", WireframeType.ROOF, false),
    INTERIOR_CABIN("Interior Cabin & Seats", "Interior", "Check seat upholstery for tears, stains, and console condition.", WireframeType.INTERIOR_DASH, false);

    companion object {
        val quick5Zones = listOf(
            FRONT_BUMPER,
            DRIVER_SIDE,
            REAR_BUMPER,
            PASSENGER_SIDE,
            DASHBOARD_ODOMETER
        )
    }
}
