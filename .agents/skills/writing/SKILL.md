---
name: writing
description: Reads app localization files (app_en.arb, app_ru.arb, and others) and ensures all text aligns with Baseline's calm, low-pressure, inclusive, and evidence-informed style.
---

# Baseline Localization Skill

This skill helps ensure that all localized strings in the app remain consistent with the Baseline product spirit: gentle, supportive, non-judgmental, low-burden, and evidence-informed. It also handles Russian-specific conventions and structured help-button content.

## When to Use

- Use this skill when reviewing or updating localization files (`.arb`) for Baseline.
- Use when adding new text strings or features to ensure tone consistency.
- Use when validating translations for accuracy and alignment with Baseline principles.

## Instructions

- Load all localization files (e.g., `app_en.arb`, `app_ru.arb`) into the agent environment.
- Parse each key-value pair and check for:

  **Tone & Style:**
  - Gentle, supportive, neutral, low-pressure.
  - Avoid words like "must," "fail," "wrong," or any advertising/marketing phrasing.
  - Russian-specific: address the user as "ты," avoid assuming gender, and use neutral constructions like поел(а), сделал(а).

  **Consistency & Alignment:**
  - Maintain Baseline principles: no calorie counting, no scoring, no pressure.
  - Preserve variable placeholders (e.g., `{username}`) and formatting.
  - Avoid triggering language in all modules. Triggering content includes anything that could provoke shame, guilt, anxiety, or distress, especially for users with depression, anxiety, PTSD, eating disorders, or gender-related challenges. Examples include: judging food choices, labeling behaviors as “good” or “bad,” shaming missed tasks, pressuring exercise or sleep, or implying the user is failing. Neutral, supportive, low-pressure terms should be used instead (e.g., “fillers” for carbs, “mood booster” for optional treats). Informal, alive, or slightly irreverent language is fine as long as it does not shame or trigger distress.

  **Help Buttons:**
  - Each help or informational button should follow this structure:
    1. **What is it:** describe the feature or action clearly.
    2. **Why is it helpful:** explain the general benefit for the user.
    3. **Evidence:** include references to studies in Harvard format (in-text citations).
    4. **Alive, self-aware tone (optional):** a brief note written as if the developer knows the user is reading it. It can be slightly direct, joking, personal, and break the fourth wall, but must never advertise or pressure the user.

- Suggest wording edits to match Baseline’s spirit while retaining meaning.
- Flag any text introducing gamification, scoring, or pressure for removal or rephrasing.
- Provide a summary report of strings reviewed, with suggested changes for translators and developers.
- Use the "ask questions" tool if clarification is needed on tone, Russian specifics, or intended meaning.

**Best Practices:**

- Preserve simplicity and neutrality.
- Use inclusive language and avoid assumptions about the user’s gender.
- For Russian text, use casual, friendly “ты” without implying gender.
- Ensure help-button content is structured and evidence-based.
- Review translations to ensure tone matches across languages, not just literal meaning.