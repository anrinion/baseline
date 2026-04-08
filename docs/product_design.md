# 🧭 Product Core

**Baseline = present-moment self-care, zero pressure, zero history, zero network**

Non-negotiables:

* no backend
* no history (only current state)
* no scores, streaks, or trends
* everything explainable with sources
* works offline, fully private

---

# 🧩 V1 Feature Set

## 1. Main Screen (non-scroll, single view)

Layout has a **sane default** that adapts when modules are off (no empty columns — remaining tiles **grow**):

* **Row 1:** **Mental state** | **Sleep** (50/50 when both on; one tile spans full width if the other is off)
* **Row 2:** **Meds** | **Movement**
* **“I’m here”** full width between the 2×2 band and Food
* **Food** full width **below** the anchor, with **more vertical space** than the pair rows (denser glance data)

```
[ Mental state ] [ Sleep ]
[ Meds         ] [ Movement ]
[            “I’m here”            ]
[            Food (wide / tall)    ]
```

Notes:

* no scrolling
* no nesting
* each tile → modal popup (or full module UI where implemented)
* instant interaction, instant exit
* **Modules are optional:** turning a module off **removes** its slot; siblings expand — no dead space reserved for disabled modules.

**Custom drag/resize:** not in V1 — doable later with persisted layout and edit mode, but meaningfully more complex (gestures, accessibility, migration). The default above should stay polished first.

---

## 2. “I’m here” Button (core anchor)

* customizable text:

  * default: “I’m here”
  * optional: “I’m alive”, etc.

Behavior:

* tap → subtle visual confirmation (color, fade)
* no tracking, no memory
* no counters

Purpose:

* grounding (Gestalt “here and now”)
* lowest possible success action

---

## 3. Food Module

Items:

* Protein
* Greens
* Legumes (beans/chickpeas)
* Carbs (“fillers”)
* Small enjoyable item (“treat”)

Interaction:

* tap = done
* no quantities
* no timing
* resets daily

### Sources (accessible via “?”)

Explain:

* balance, not restriction
* behavioral activation role of treat
* non-restrictive eating principles

---

## 4. Movement

* single action: “moved a bit”

Optional microcopy:

* “any movement counts”

No intensity, no duration.

---

## 5. Sleep

* “I’m going to sleep”
* “I’m awake”

Shows:

* duration of last sleep (no history, no comparison)

---

## 6. Meds

* user-defined list
* checkboxes (today only)
* optional local reminders

No adherence stats. No history.

---

## 7. Mental state (CBT-inspired, lightweight, present-only)

*In the UI this is **“Mental state”** — still conceptually light CBT-style tooling, without clinical framing.*

### a) “Right now”

* select or input current feeling
* optional gentle suggestion

### b) “One small good thing”

* 1–3 short entries
* deleted daily

### c) “Thought lens”

* one cognitive distortion at a time
* short explanation + example

No logs. No past access.

---

## 8. Sources (per module, not a separate tile)

There is **no** standalone “Sources” module. Rationale and references live **next to each module**:

* a small **help (?)** on the grid tile and/or in the module sheet
* short, clear copy; linked or cited sources where the product ships real citations

Tone:

* simple
* transparent
* no overclaiming

⚠️ Requires careful curation → **further research needed** (per module)

---

# 🚫 Not in V1

* Help system → moved to v2
* backend / sync → never
* journaling history → never
* analytics → none

---

# 🌍 Languages

**Recommended set:**

* English
* Russian
* Spanish
* German
* French

Requirements:

* full UI translation
* tone-sensitive (not literal only)

---

# 🎨 Themes (V1)

4 themes:

* Light (neutral)
* Light (warm)
* Dark (true black)
* Dark (soft contrast)

No gamified colors. Calm palette.

---

# 🚪 Initial Screen (first launch)

Minimal:

1. Language selection
2. Theme selection
3. Optional:

   * meds setup
   * (help removed to v2)

Message:

> “No tracking. No pressure. Just today.”

---

# ⚙️ Settings Screen

* Language
* Theme
* “I’m here” text customization
* **Which modules appear on the main screen** (each module on/off)
* Meds list
* Notifications (local)
* Reset data
* About / philosophy

---

# 👤 Core User Flows

## Ultra-low energy

* open app
* tap “I’m here”
* close

## Basic functioning

* tap 1–2 food items
* meds check
* close

## Reflection moment

* Mental state → “one small good thing”
* close

Everything ≤ 30 seconds.

---

# 🧱 Architecture

## Stack

* Flutter
* Provider (state management)
* Hive (local storage)
* flutter_local_notifications

This is acceptable for your scope.

---

## Data Model

```
AppState
 ├── TodayState
 │    ├── food (bools)
 │    ├── movement (bool)
 │    ├── meds (map)
 │    ├── sleep (current session)
 │    ├── cbt_temp (text)
 │
 ├── Settings
 │    ├── meds list
 │    ├── language
 │    ├── theme
 │    ├── button text
 │    └── enabled modules (subset)
```

---

## Reset Logic

* on app open:

  * if date changed → wipe `TodayState`

No exceptions.

---

## Security / Privacy

* no internet permission
* all local
* optional encryption → **further research needed**

---

# 🧠 Scientific Positioning (final)

Core pillars:

* behavioral activation
* non-restrictive eating
* low cognitive load design
* present-focused interaction
* privacy by design

Everything must be:

> **simple, accurate, and sourced**