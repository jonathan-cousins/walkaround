## 2026-09-27 - Icon-Only Button Accessibility Pattern
**Learning:** Found a recurring pattern in the Walkaround vanilla JS app where icon-only buttons (using Phosphor icons) lacked accessible text for screen readers. These buttons included critical controls like back navigation, modal closures, and camera shutters.
**Action:** Always ensure that any button containing only an icon tag (`<i>`) receives both an `aria-label` (for screen readers) and a `title` (for visual tooltips on hover). This must be applied consistently across static HTML elements and dynamically injected templates.
