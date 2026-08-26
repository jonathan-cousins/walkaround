## 2024-03-01 - Phosphor Icon Button Accessibility Pattern
**Learning:** The Walkaround web app uses a pattern of creating icon-only buttons with Phosphor icons (e.g., `<button class="icon-btn"><i class="ph-bold ph-caret-left"></i></button>`). These lack explicit text, making navigation and key interactions (like back, close modal, add rental) completely invisible or un-descriptive to screen readers.
**Action:** Always ensure that `aria-label` attributes are added to buttons that contain only icons. Also, ensure focus states are clearly visible for keyboard navigation.
