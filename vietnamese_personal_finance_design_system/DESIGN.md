---
name: Vietnamese Personal Finance Design System
colors:
  surface: '#f8f9fa'
  surface-dim: '#d9dadb'
  surface-bright: '#f8f9fa'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f4f5'
  surface-container: '#edeeef'
  surface-container-high: '#e7e8e9'
  surface-container-highest: '#e1e3e4'
  on-surface: '#191c1d'
  on-surface-variant: '#404752'
  inverse-surface: '#2e3132'
  inverse-on-surface: '#f0f1f2'
  outline: '#707883'
  outline-variant: '#bfc7d4'
  surface-tint: '#0061a4'
  primary: '#0061a4'
  on-primary: '#ffffff'
  primary-container: '#2196f3'
  on-primary-container: '#002c4f'
  inverse-primary: '#9ecaff'
  secondary: '#006e1c'
  on-secondary: '#ffffff'
  secondary-container: '#91f78e'
  on-secondary-container: '#00731e'
  tertiary: '#8b5000'
  on-tertiary: '#ffffff'
  tertiary-container: '#d37d00'
  on-tertiary-container: '#422300'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d1e4ff'
  primary-fixed-dim: '#9ecaff'
  on-primary-fixed: '#001d36'
  on-primary-fixed-variant: '#00497d'
  secondary-fixed: '#94f990'
  secondary-fixed-dim: '#78dc77'
  on-secondary-fixed: '#002204'
  on-secondary-fixed-variant: '#005313'
  tertiary-fixed: '#ffdcbe'
  tertiary-fixed-dim: '#ffb870'
  on-tertiary-fixed: '#2c1600'
  on-tertiary-fixed-variant: '#693c00'
  background: '#f8f9fa'
  on-background: '#191c1d'
  surface-variant: '#e1e3e4'
typography:
  display-lg:
    fontFamily: Hanken Grotesk
    fontSize: 57px
    fontWeight: '700'
    lineHeight: 64px
    letterSpacing: -0.25px
  headline-md:
    fontFamily: Hanken Grotesk
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
  title-lg:
    fontFamily: Hanken Grotesk
    fontSize: 22px
    fontWeight: '500'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: 0.5px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: 0.25px
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.5px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  gutter: 16px
  margin-mobile: 16px
  margin-tablet: 24px
---

## Brand & Style

This design system is built upon a **Modern Corporate** aesthetic, leveraging the structural integrity of **Material 3 (M3)** to foster trust and clarity. The brand personality is rooted in "Financial Mindfulness"—providing users with a calm, organized environment to manage their wealth. 

The visual language emphasizes transparency and precision. By utilizing M3's adaptive surfaces and tonal palettes, the interface avoids clutter, focusing instead on high-signal data. In the Vietnamese context, the design prioritizes high legibility for long currency strings (VND) and clear semantic signaling for budget health. The goal is to evoke a sense of security and control, turning the often-stressful task of money management into a streamlined, professional experience.

## Colors

The color palette is functionally driven to provide immediate feedback on financial health.

- **Primary (Blue):** Used for primary actions, navigation, and neutral financial data like "Total Balance."
- **Success (Green):** Specifically reserved for "Income," "Savings Goals Met," and "Under Budget" indicators.
- **Error (Red):** High-visibility signal for "Over-spending," "Overdue Bills," or "Negative Cash Flow."
- **Neutral (Gray/Off-white):** A soft `#F8F9FA` background reduces eye strain during long analytical sessions.

In **Dark Mode**, saturation is lowered to maintain accessibility standards. Semantic colors (Green/Red) transition to pastel equivalents to ensure they don't vibrate against dark backgrounds while maintaining their instructional meaning.

## Typography

This design system utilizes **Hanken Grotesk** for headlines to provide a sharp, modern fintech feel, while **Inter** is used for all functional body and UI text due to its exceptional legibility with Vietnamese diacritics.

### Key Rules:
- **Currency Display:** Financial amounts should always use `medium` or `bold` weights to ensure they are the primary focal point of any card.
- **Diacritics:** Line heights are slightly increased (1.5x for body) to ensure Vietnamese tone marks do not overlap or feel cramped.
- **Hierarchy:** Use `label-sm` in all-caps for category headers to create a distinct structural break between data sections.

## Layout & Spacing

The layout follows a **Fluid Grid** system based on an 8px square rhythm. 

- **Mobile:** 4-column grid with 16px margins.
- **Desktop/Tablet:** 12-column grid with 24px margins.
- **Financial Lists:** Use a 56px minimum touch target height for transaction line items to ensure ease of use on the go.
- **Data Density:** In analytical views, padding may be reduced to `sm` (8px) to allow for more granular chart data to be visible without excessive scrolling.

## Elevation & Depth

This design system adopts the **Tonal Layering** approach from Material 3. Depth is communicated through color shifts rather than heavy shadows.

- **Level 0 (Surface):** The main background (`#F8F9FA`).
- **Level 1 (Cards):** Slightly elevated using a subtle tint of the primary color or a 1dp shadow (Blur 4px, Opacity 0.05). Used for individual transaction items.
- **Level 2 (Active States):** Used for navigation bars and floating action buttons (FAB).
- **Glassmorphism:** Reserved exclusively for bottom sheets and modal overlays to maintain context of the underlying financial dashboard.

## Shapes

The shape language is **Rounded (Level 2)** to balance professionalism with modern approachability.

- **Standard Components:** Buttons and Input fields use a `0.5rem` (8px) radius.
- **Containers:** Large dashboard cards and bottom sheets use `rounded-xl` (`1.5rem` or 24px) to create a distinct "container" feel that separates different financial modules (e.g., Spending vs. Investments).
- **Selection Indicators:** Use pill-shapes (fully rounded) for chips and active tab indicators.

## Components

### Buttons
- **Primary:** Filled with `#2196F3`. White text. High emphasis for "Add Transaction."
- **Secondary:** Outlined with 1px stroke. Used for "View Report" or "Filter."

### Financial Status Indicators
- **Trend Arrows:** Small icons paired with percentage text. Green (`#4CAF50`) for upward trends in savings, Red (`#F44336`) for upward trends in spending.
- **Progress Bars:** Use a thick 8px stroke for budget tracking. Background track is 10% opacity of the semantic color.

### Charts & Data Viz
- **Donut Charts:** Use for category breakdowns. Use the Primary Blue for the largest slice to anchor the visual.
- **Line Graphs:** Smooth interpolation (bezier) with a subtle gradient fill below the line to denote volume.

### Cards
- **Transaction Cards:** Horizontal layout. Left: Category Icon (circular background). Center: Title and Timestamp. Right: Amount (Bolded, color-coded by type).

### Input Fields
- **Currency Input:** Specialized field with a fixed "đ" suffix or "VND" prefix. Large font size (`headline-md`) for the numeric value.
- **Date Picker:** M3 standard modal picker with localized Vietnamese month names.