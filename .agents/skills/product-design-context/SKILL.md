---
name: product-design-context
description: Use the product design document (`docs/product_design.md`) as the authoritative source for all design and implementation decisions. This skill ensures that any design, layout, component, or interaction guidance respects the current product principles and constraints.
---

# Product Design Context

This skill provides a framework for applying the product design document as the **primary authority** in all design-related decisions. It does **not contain any product-specific rules or assumptions**. The design doc may change at any time, and the skill remains applicable.

---

## Core Rules

1. **Always reference the product design document** before making decisions.  
2. **Do not encode any product-specific content** in this skill.  
3. **All other skills must check against the design document** before applying recommendations.  
4. **If a proposed action conflicts with the design document**, flag it or adjust the proposal to align with the document.  
5. **Do not make assumptions** about modules, layouts, themes, or features outside what the document specifies.  

---

## When to Apply

- Before applying any layout, component, color, or UX guidance.  
- When evaluating design proposals or reviewing system decisions.  
- Any time an agent needs product-specific context to make choices.  

---

## Workflow

1. **Consult the design document** to extract relevant constraints, priorities, and principles.  
2. **Use the extracted information** to filter, validate, or adjust design proposals.  
3. **Never store or hardcode any design doc content** in this skill.  
4. **Flag discrepancies** if a proposed design or behavior contradicts the current product document.  
5. **If the design doc changes**, all subsequent decisions automatically reflect the updated document.  

---

## Integration with Other Skills

- This skill acts as a **constraint layer** for all other design-related skills.  
- Any skill that produces design output must **check with this skill first** to ensure compliance.  
- Provides **guidance on alignment**, but contains **no instructions about specific modules, layouts, or features**.  

---

## Anti-Patterns

- Encoding product-specific assumptions in this skill.  
- Ignoring the design document when applying other skills.  
- Treating generic design rules as authoritative over the product document.  

---

## Fallback Behavior

If the design document is unavailable or unclear:

- Default to requesting clarification before proceeding.  
- Do not attempt to fill in gaps with assumptions.  
- Mark the action as pending until the product document is available.  