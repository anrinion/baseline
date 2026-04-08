---
name: color-schemas
description: Define application color themes using classic, well-known color schemes as a starting point. This skill provides a catalog of proven palettes and guidance on adapting them to mobile app design systems, including semantic mapping, accessibility considerations, and complementary design tokens.
---

# Color Schemas

This skill provides a structured and deterministic approach to selecting and implementing a color theme for a mobile application. It builds on classic, time-tested color schemes and adapts them into modern, semantic design systems suitable for iOS, Android, and cross-platform apps.

---

## Quick Rules

- Never use raw hex values directly in UI → always map to semantic tokens  
- Choose **1 primary accent**, limit total accents to 2–3  
- Ensure **WCAG contrast compliance** before finalizing  
- Keep **semantic tokens identical across light/dark modes**  
- Adjust colors slightly if needed—preserve mood, not exact hex  

---

## When to Use

Use this skill when:

- Starting a new project and defining a color system
- Evaluating or improving accessibility of an existing palette
- Creating light/dark theme variants
- Converting a palette into semantic design tokens
- Standardizing colors across a design system

---

## What a Color Schema Includes

A complete schema defines functional roles, not just colors:

- **Backgrounds**: base surfaces, elevated surfaces
- **Foregrounds**: text, icons, placeholders
- **Accents**: primary and secondary actions
- **Status Colors**: success, warning, error, info
- **Borders/Separators**: structure and grouping

---

## Core Methodology

Follow this process when selecting or implementing a color schema.

---

### Step 1: Select a Base Scheme by Product Intent

Choose a scheme based on the desired emotional tone.

#### Selection Heuristic

- Productivity / reading → **Solarized, Nord**
- Creative / expressive → **Dracula, Monokai**
- Lifestyle / warm → **Gruvbox**
- Neutral / professional → **Tomorrow Night, Nord**

**Rule:** Do not mix multiple base schemes. Start from one and adapt.

---

### Step 2: Define Accent Strategy

Accent colors must be controlled and intentional.

#### Rules

- Choose **one primary accent** (used for main actions)
- Optionally define **one secondary accent**
- Use additional accents only for:
  - Data visualization
  - Status differentiation

#### Priority Order

1. Primary action color (`primary`, `tint`)
2. Secondary accent
3. Status colors
4. Decorative accents (lowest priority)

**Avoid:** Using all available palette colors in UI controls.

---

### Step 3: Map to Semantic Tokens

Never apply raw hex values directly. Create a semantic layer.

#### Core Tokens

| Semantic Token | Mapping | Purpose |
| :--- | :--- | :--- |
| `systemBackground` | Scheme Background | Root background |
| `secondaryBackground` | Scheme Surface | Cards, sheets |
| `label` | Primary Text | High emphasis text |
| `secondaryLabel` | Secondary Text | Captions, hints |
| `primary` / `tint` | Primary Accent | Buttons, links |
| `secondaryAccent` | Secondary Accent | Secondary actions |
| `destructive` | Error color | Critical actions |
| `separator` | Text @ 20–30% opacity | Borders |

#### Rule

Semantic meaning must stay constant across themes. Only color values change.

---

### Step 4: Adapt for Light and Dark Modes

Define both variants using the same token structure.

#### Rules

- Keep **identical token names**
- Adjust:
  - Background luminance
  - Text contrast
  - Surface elevation

#### Transformation Guidelines

- Light → Dark:
  - Invert luminance, not hue
  - Reduce saturation slightly in dark mode
- Dark → Light:
  - Increase contrast without making colors harsh

---

### Step 5: Validate Accessibility

Accessibility is mandatory, not optional.

#### WCAG Requirements

- Body text → **≥ 4.5:1**
- Large text → **≥ 3:1**
- UI elements (icons, borders) → **≥ 3:1**

#### Adjustment Rules

If contrast fails:

1. Adjust brightness (lighter/darker)
2. Then adjust saturation
3. Avoid shifting hue unless necessary

Preserve the scheme’s overall character.

---

## Classic Color Schemes Catalog

Use these as starting points, not rigid definitions.

---

### Solarized

Balanced and low-contrast, optimized for long reading.

- Light BG: `#FDF6E3`
- Dark BG: `#002B36`
- Accent: `#268BD2`, `#2AA198`, `#B58900`
- Error: `#DC322F`

Mood: Calm, academic, low eye strain

---

### Monokai

High contrast with vibrant accents.

- BG: `#272822`
- Text: `#F8F8F2`
- Accents: `#F92672`, `#66D9EF`, `#A6E22E`, `#FD971F`

Mood: Energetic, developer-focused

---

### Gruvbox

Warm, retro, highly distinctive.

- Light BG: `#FBF1C7`
- Dark BG: `#282828`
- Accents: `#D65D0E`, `#076678`, `#79740E`

Mood: Warm, vintage, approachable

---

### Tomorrow Night

Neutral and balanced dark theme.

- BG: `#1D1F21`
- Text: `#C5C8C6`
- Accents: `#CC6666`, `#81A2BE`, `#B5BD68`

Mood: Professional, understated

---

### Dracula

Bold, high-energy dark theme.

- BG: `#282A36`
- Accents: `#BD93F9`, `#FF79C6`, `#8BE9FD`, `#50FA7B`

Mood: Playful, expressive

---

### Nord

Cool, desaturated palette.

- BG: `#2E3440`
- Text: `#ECEFF4`
- Accents: `#81A1C1`, `#88C0D0`, `#A3BE8C`

Mood: Calm, minimal, professional

---

## Color Role Constraints

To maintain consistency:

- Background layers: max **3 levels** (base, surface, elevated)
- Text levels: max **3 levels** (primary, secondary, disabled)
- Interactive colors: **1 primary + 1 secondary**
- Status colors: fixed semantic meanings (never repurpose)

---

## Interaction States

Define state variants for all interactive colors:

- Default
- Hover (if applicable)
- Pressed
- Disabled

#### Rule

State changes should modify:
- Opacity
- Brightness

Avoid introducing new colors for states.

---

## Common Anti-Patterns

- Using raw hex values directly in components
- Using too many accent colors
- Insufficient contrast between text and background
- Changing semantic meaning between light/dark modes
- Using color alone to convey meaning (no icons/text support)
- Over-saturating dark themes (causes eye strain)

---

## Complementary Design Tokens

Color should align with other system tokens.

- **Spacing**: 8pt grid (8 / 16 / 24)
- **Radius**: 4 / 8 / 12 / full
- **Motion**:
  - High-energy palette → faster motion
  - Calm palette → smoother, slower motion

---

## Using This Skill in Practice

When asked to define a color system:

1. Identify:
   - Product type
   - Desired emotional tone

2. Select **2–3 candidate schemes**

3. Choose one and:
   - Define primary + secondary accents
   - Map all semantic tokens

4. Validate:
   - Contrast ratios
   - Visual hierarchy clarity

5. Produce:
   - Token table
   - Light + dark variants

---

## Fallback Assumptions

If the user provides no guidance:

- Default to **Nord or Solarized**
- Assume **productivity use case**
- Use **one blue accent as primary**
- Generate both light and dark variants

---

## Example

**Finance App (Nord-based)**

- Primary: Muted blue (`#81A1C1`)
- Background: Dark slate (`#2E3440`)
- Surface: Slightly lighter slate
- Text: High-contrast light gray
- Success: Green (`#A3BE8C`)
- Error: Red (`#BF616A`)

Result: Calm, trustworthy, low visual fatigue interface.

---