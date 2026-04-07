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

Grid layout (fixed):

```
[ Food      ] [ Movement ]
[ Sleep     ] [ Meds     ]
[ CBT       ] [ Sources  ]

[   “I’m here” button   ]
```

Notes:

* no scrolling
* no nesting
* each tile → modal popup
* instant interaction, instant exit

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

## 7. CBT (lightweight, present-only)

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

## 8. Sources

This is a dedicated tile.

Contains:

* all modules explained
* short, clear reasoning
* linked or cited sources

Structure:

* topic → explanation → references

Tone:

* simple
* transparent
* no overclaiming

⚠️ Requires careful curation → **further research needed**

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

* CBT → “one small good thing”
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
 │    └── button text
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