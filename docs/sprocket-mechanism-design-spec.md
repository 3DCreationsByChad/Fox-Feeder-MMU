# Single-Direction Sprocket Mechanism — Design Specification

## Overview

This document specifies a **ball-sprag one-way clutch** to replace the current printed TPU pinwheel roller clutch in the Fox Feeder MMU. The mechanism allows filament to feed freely toward the toolhead while mechanically preventing backflow when the lane is parked.

---

## Problem Statement

The current roller clutch uses **printed TPU pinwheel fingers** as one-way sprag elements. These have several limitations:

1. **Print tolerance sensitivity** — the pinwheel overhangs require post-processing ("gently free them up after printing") and vary with printer calibration, TPU brand, and ambient conditions.
2. **Fatigue failure** — the fingers have already required "beefing up" (commit b6c9adb), indicating the original geometry was failing under cyclic load.
3. **Inconsistent engagement** — TPU stiffness varies with temperature and humidity, causing the locking force to be unpredictable.
4. **Wear** — filament dust and repeated deflection cycles degrade the printed sprags over time.

---

## Proposed Solution: Ball-Sprag One-Way Clutch

Replace the printed pinwheel fingers with **small steel ball bearings sitting in ramped pockets**. The balls wedge between the inner shaft (existing 5mm dowel) and the outer race (printed TPU housing) in one rotational direction, and release freely in the other.

### How It Works

```
CROSS-SECTION VIEW (looking down the shaft axis)

          ╭─── TPU Outer Race ───╮
         ╱                        ╲
        │    ╭──── Ramp ────╮      │
        │   ╱    ●ball       ╲     │   ← Ball wedges in narrow end = LOCKED
        │  ╱                  ╲    │   ← Ball rolls to wide end = FREE
        │ ╱     5mm Dowel      ╲   │
        │╱     ┌────────┐      ╲│
        │      │        │       │
        │╲     │ shaft  │      ╱│
        │ ╲    └────────┘     ╱ │
        │  ╲                 ╱  │
        │   ╲    ●ball      ╱   │
        │    ╰──── Ramp ───╯    │
         ╲                     ╱
          ╰────────────────────╯

SIDE VIEW (ramp profile):

        Outer Race Wall
        ═══════════════════════╗
                          ●    ║ ← LOCKED (ball wedged, narrow gap)
                      ●        ║
                  ●             ║ ← FREE (ball rolls to wide gap)
        ─────────────────────────  ← 5mm Dowel Surface

        |←── ramp length ──→|

        Ramp angle: 5-7°
```

### Locking Direction
- **LOCKED:** When the shaft tries to rotate in the "backflow" direction, balls roll into the narrow end of the ramp and wedge between shaft and race. Friction locks the shaft.
- **FREE:** When the shaft rotates in the "feed" direction, balls roll to the wide end of the ramp. No contact pressure, shaft spins freely.

---

## Design Parameters

### Ball Specifications

| Parameter | Value | Notes |
|-----------|-------|-------|
| Ball diameter | 2.5mm | Standard precision steel balls, widely available |
| Ball material | Chrome steel (AISI 52100) or stainless | Hardened, low friction against steel dowel |
| Balls per clutch | 3 | Evenly spaced at 120 degrees for balanced engagement |
| Ball grade | G100 or better | Hobby-grade precision is sufficient |

**Why 2.5mm:** The gap between a 5mm dowel (2.5mm radius) and a ~6mm inner bore on the outer race is ~0.5mm nominal. A 2.5mm ball in a ramp that varies from 2.6mm to 2.3mm gap provides reliable wedging with good contact area.

### Ramp Geometry

| Parameter | Value | Notes |
|-----------|-------|-------|
| Ramp angle | 5-7 degrees | 5° = stronger lock, harder release. 7° = easier release, lighter lock. Start with 6°. |
| Ramp length | ~4mm | Enough travel for ball to fully disengage |
| Wedge interference | 0.1-0.2mm | Amount the ball compresses the TPU race at full lock |
| Number of ramps | 3 | One per ball, evenly spaced |

### Race Specifications

| Component | Material | Notes |
|-----------|----------|-------|
| Inner race | Existing 5mm steel dowel | Hardened surface ideal for ball contact |
| Outer race | Printed TPU (Shore 95A) | Slight compliance ensures reliable engagement; same material as current roller clutch |
| Ramp pockets | Printed into outer race inner bore | Shaped recesses that guide balls along the ramp |

### Critical Tolerances

| Dimension | Tolerance | Notes |
|-----------|-----------|-------|
| Outer race inner bore (wide end) | 5mm + ball dia + 0.15mm clearance | Ball must roll freely at wide end |
| Outer race inner bore (narrow end) | 5mm + ball dia - 0.10mm interference | Ball must wedge at narrow end; TPU compliance absorbs this |
| Ramp surface finish | As-printed is acceptable | TPU layer lines actually help grip |
| Ball pocket depth | Ball diameter - 0.3mm | Balls must not fall out axially; retained by pocket walls |

---

## Integration with Existing Design

### What Changes

| Component | Current | New |
|-----------|---------|-----|
| Roller Clutch Inner | TPU with printed pinwheel fingers | TPU with 3 ramped ball pockets |
| Roller Clutch Outer | TPU housing | Unchanged (or minor bore adjustment) |
| New BOM items | — | 3x 2.5mm steel balls per lane |
| 5mm Dowels | Existing | Unchanged |
| Assembly | Free pinwheel fingers post-print | Drop balls into pockets, slide onto dowel |

### What Stays the Same

- Roller Clutch Outer dimensions and mounting
- 5mm dowel shafts
- Overall roller assembly envelope
- All other mechanical components
- Frame, motor plates, extruder bodies
- Electrical/sensor system

### BOM Addition

| Component | 2-Lane | 4-Lane | Source |
|-----------|--------|--------|--------|
| 2.5mm chrome steel balls | 6 (3 per lane) | 12 (3 per lane) | Amazon, AliExpress, hobby suppliers |

**Estimated cost addition:** < $2 for a pack of 50-100 balls (lifetime supply).

---

## Assembly Procedure

1. **Print the new Roller Clutch Inner** in TPU (Shore 95A, medium-hard). The ramp pockets will be visible as three evenly-spaced recesses on the inner bore.

2. **Drop 3 steel balls** into the ramp pockets. They should sit loosely in the wide end of each ramp.

3. **Slide the assembly onto the 5mm dowel.** The balls will self-center between the dowel and the printed ramp surfaces.

4. **Test rotation by hand:**
   - Rotate in the "feed" direction → should spin freely with minimal resistance
   - Rotate in the "backflow" direction → should lock firmly after ~1-2mm of rotation

5. **If too tight:** Sand or ream the narrow end of the ramp pockets slightly to increase the gap by 0.05mm.

6. **If too loose (doesn't lock):** Print with slightly tighter tolerances or use 2.6mm balls.

7. **Assemble into Roller Clutch Outer** as before.

---

## Design Validation Checklist

Before finalizing the CAD for printing:

- [ ] Verify ramp angle locks reliably with chosen ball size (print test coupon first)
- [ ] Confirm balls are retained axially (don't fall out when tilted)
- [ ] Test with filament loaded — feed direction should have negligible added resistance
- [ ] Test backflow prevention — pull filament backward by hand, should lock immediately
- [ ] Cycle test — 100+ load/unload cycles, verify consistent engagement
- [ ] Temperature test — verify operation at typical enclosure temperatures (30-50C)
- [ ] Verify no interference with existing Roller Clutch Outer or idler assembly
- [ ] Test with multiple filament types (PLA, PETG, TPU, ABS) for varying stiffness

---

## Alternative Approaches Considered

### A. Printed Sprocket + Pawl (Ratchet)
- Toothed wheel with spring-loaded pawl
- **Rejected because:** Discrete tooth pitch limits resolution to ~1-2mm steps. Audible clicking during feed. Pawl spring is a wear item. More complex to print reliably.

### B. Current Pinwheel Sprags (Status Quo)
- Printed TPU fingers that flex to allow forward rotation
- **Being replaced because:** Tolerance-sensitive, fatigue-prone, inconsistent across prints and TPU batches. Already required strengthening once.

### C. Wrap-Spring Clutch
- Tightly wound spring around shaft, tightens in one direction
- **Deferred because:** Requires a specific sourced spring (not printable), adds a sourcing/specification requirement. Could be revisited if ball-sprag proves insufficient for high-torque scenarios.

### D. Commercial One-Way Bearings
- Off-the-shelf needle roller one-way bearings (e.g., HF0612)
- **Deferred because:** Adds cost ($2-5 per lane), requires specific shaft tolerances, goes against the "printable + cheap" philosophy. Good fallback if printed solution underperforms.

---

## Next Steps

1. **Design the new Roller Clutch Inner** in CAD with 3 ramped ball pockets
2. **Print a test coupon** — a simple cylinder with one ramp pocket and a dowel, to dial in the ramp angle before committing to the full part
3. **Validate with 2.5mm balls** — if engagement is too aggressive, try 2.0mm; if too weak, try 3.0mm
4. **Update the STLs** once geometry is validated
5. **Update the BOM** to include steel balls
6. **Document assembly** with photos/diagrams of ball placement
