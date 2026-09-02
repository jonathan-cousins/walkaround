## 2026-09-02 - ARIA Labels on Icon Buttons
**Learning:** Icon-only buttons without `aria-label` attributes are inaccessible to screen readers, meaning visually impaired users wouldn't know the button's function. In this app, many navigational and utility buttons (like close, back, flash toggle, and previous/next photo) lack these labels.
**Action:** Add descriptive `aria-label` attributes to all icon-only buttons (`.icon-btn`, `.icon-btn-trans`, `.nav-arrow-btn`, `.shutter-btn`) to ensure screen readers can announce their purpose clearly.
