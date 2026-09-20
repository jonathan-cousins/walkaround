## 2024-09-20 - Icon-Only Navigation Controls Need ARIA Labels
**Learning:** Icon-only navigation and custom interactive elements (like the camera shutter button or next/prev zone arrows) in the app's critical audit flows lack screen-reader context.
**Action:** Always ensure explicitly added `aria-label`s on custom interactive components that rely purely on icons, particularly in specialized UI flows like camera viewfinders or multi-step navigation.
