---
name: adaptive-mobile-design
description: Provide systematic design guidance for building mobile app interfaces that adapt seamlessly across all screen sizes, from ultra-small (4-inch, split-screen) to tablet and desktop-class devices. Use this skill when designing responsive layouts, choosing navigation patterns, or defining component behavior based on window size classes.
---

# Adaptive Mobile Design

This skill provides a structured, deterministic methodology for designing application interfaces that scale from the smallest mobile screen to expansive tablet and desktop environments. It integrates principles from Material Design and Apple Human Interface Guidelines, focusing on content adaptation, layout patterns, and input-appropriate interactions.

---

## Quick Rules

- Use **1 pane in Compact**, **2 panes in Expanded**
- **Reduce content via priority hierarchy**, not arbitrarily
- **Transform components**, don’t just scale them
- **Match navigation patterns to screen width**
- **Preserve state across resize and rotation**

---

## When to Use

Use this skill in the following scenarios:

- Designing a mobile app for phones, foldables, tablets, or desktop-class layouts
- Refactoring an interface to be responsive and adaptive
- Evaluating support for split-screen or multi-window environments
- Choosing navigation patterns across screen sizes
- Defining how components change across display contexts

---

## Core Methodology

Follow this four-step process when approaching any adaptive design task.

---

### Step 1: Classify the Target Window Sizes

Design for behavioral classes, not specific devices.

| Mode | Width Range (dp/pt) | Typical Scenario |
| :--- | :--- | :--- |
| **Micro (Sub-compact override)** | Under 400 | 4-inch phone, 50% split-screen |
| **Compact** | 400–599 | Standard phone portrait |
| **Medium** | 600–839 | Foldable unfolded, small tablet |
| **Expanded** | 840+ | Tablet landscape, desktop |

**Note:**
- `Compact`, `Medium`, and `Expanded` align with Material 3 window size classes
- `Micro` is a stricter override for extreme constraints

---

### Step 2: Determine Content State by Mode

Apply progressive disclosure using a strict priority system.

#### Content Priority Order

1. Primary value (core content)
2. Primary action
3. Secondary metadata
4. Secondary actions
5. Decorative/supporting content

**Rule:** Remove or compress content in reverse order as space decreases.

#### Mode Behavior

- **Expanded / Medium:** Full fidelity, all content and actions visible
- **Compact:** Show primary value + primary actions; move secondary items to overflow
- **Micro:** Show only the primary value + a single affordance (expand, navigate, or reveal)

---

### Step 3: Select Canonical Layout Pattern

Choose a layout based on the primary user task.

#### Pattern Selection Rules

- **Browse + inspect → List-Detail**
- **Create / manipulate / work → Supporting Pane**
- **Consume continuous content → Feed**

#### Pattern Definitions

- **List-Detail**
  - Compact: single stack (navigate to detail)
  - Medium/Expanded: side-by-side panes

- **Supporting Pane**
  - Primary workspace + secondary tools/context panel

- **Feed**
  - Single column across sizes
  - Adjust margins and grid density

#### Pane Count Rules

- Compact: **1 pane**
- Medium: **1–2 panes**
- Expanded: **2 panes (optionally 3 for complex workflows)**

---

### Step 4: Adapt Component Variants

Do not scale components—transform them.

| Component | Expanded / Medium | Compact / Micro |
| :--- | :--- | :--- |
| **Primary Navigation** | Navigation rail or persistent drawer | Bottom navigation or hamburger menu |
| **Data Display** | Tables, multi-column grids | Stacked cards or horizontal scroll |
| **List Item** | Image, title, subtitle, actions | Image + title only; actions hidden |
| **Search** | Expanded field with filters | Collapsed icon → expands on tap |
| **Buttons** | Text + icon | Icon-only or moved to menu |

---

## Navigation Transformation Rules

Navigation must remain structurally consistent across modes.

- Compact → Bottom navigation (3–5 top-level destinations)
- Medium → Navigation rail (same destinations, labeled)
- Expanded → Persistent drawer/sidebar

**Rule:** Never change the number or hierarchy of top-level destinations across modes.

---

## Layout and Spacing Guidelines

- **Grid:** Use a flexible 12-column grid  
  - ~360dp → 4 columns  
  - ~600dp → 8 columns  
  - 840dp+ → 12 columns  

- **Spacing:**
  - Base unit: 8dp
  - Phones: ~16dp margins
  - Tablets/Desktop: 24–40dp margins

- **Density:**
  - Compact: higher density
  - Expanded: more whitespace, not more clutter

- **Safe Areas:**
  - Always respect notches, gesture areas, and system UI insets

---

## Interaction Design by Input Method

### Touch (Micro / Compact)

- Minimum hit target: **44×44pt**
- No hover interactions
- Use:
  - Tap-to-expand
  - Long-press for secondary actions
  - Bottom sheets for menus

### Pointer & Keyboard (Medium / Expanded)

- Enable hover states and tooltips
- Support keyboard shortcuts (e.g., `Cmd/Ctrl + K`)
- Use anchored popovers instead of full-screen overlays

---

## Typography and Readability

- **Dynamic Type:** Respect system scaling; never hardcode sizes
- **Line Length:** Max 70–80 characters on large screens
- **Truncation:**
  - Use compact numbers (`3.2k`)
  - Use middle truncation for long strings when needed

---

## State Persistence During Resizing

The UI must adapt without resetting.

Always preserve:

- Scroll position
- Selected/focused item
- Open panes and navigation state

### Layout Transition Rules

- List-Detail:
  - Expanded → side-by-side panes
  - Compact → detail becomes a pushed screen

- Modals:
  - Expanded → dialog/popover
  - Compact → full-screen sheet

---

## Platform-Specific Considerations

### Apple (iOS / iPadOS)

- Respect safe areas and system gestures
- Support Split View, Slide Over, Stage Manager
- Navigation:
  - iPhone → tab bar
  - iPad → sidebar

### Android / Material Design

- Use window size classes for breakpoints
- Prefer:
  - Navigation rail (Medium)
  - Navigation drawer (Expanded)

---

## Common Anti-Patterns

- Scaling layouts instead of transforming them
- Hiding primary actions in overflow menus
- Changing navigation hierarchy across modes
- Relying on hover in touch contexts
- Resetting UI state on resize or rotation

---

## Using This Skill in Practice

When designing or reviewing an adaptive interface:

1. Identify or request:
   - Primary user tasks
   - Content hierarchy
   - Target platforms (iOS, Android, cross-platform)

2. Classify supported screen sizes using the four modes

3. Apply a clear content reduction strategy:
   - Use the priority hierarchy
   - Ensure Micro and Compact are intentional

4. Select a layout pattern using task-based rules

5. Verify:
   - Navigation adapts correctly across modes
   - Components transform (not scale)
   - Touch and pointer interactions are both supported

6. Ensure:
   - Grid and spacing are fluid
   - Safe areas are respected
   - State persists across resizing

---

## Fallback Assumptions (If Information Is Missing)

If the user does not specify key details:

- Assume **phone-first (Compact)**
- Assume **content consumption as primary task**
- Default to **Feed or List-Detail pattern**
- Apply standard navigation transformation rules

---

## Example

**Email App**

- Compact:
  - Message list → tap opens message (single pane)

- Medium:
  - Message list + message content side-by-side

- Expanded:
  - Message list + message + thread/details panel

This demonstrates how layout, navigation, and content scale together.

---