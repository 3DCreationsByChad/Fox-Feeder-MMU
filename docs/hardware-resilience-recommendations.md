# Fox Feeder MMU — Hardware Resilience Recommendations

This document captures recommended hardware improvements to increase the long-term reliability and resilience of the Fox Feeder MMU.

---

## 1. ECAS Fitting Retention

**Problem:** ECAS push-fit connectors are the most common mechanical failure point in Bowden-based systems. Under repeated load/unload cycles (hundreds per multi-material print), the internal collet teeth wear and filament can creep or pop loose mid-print.

**Recommendations:**
- **Add collet clip retainers** (blue pneumatic clips) to the BOM. These snap over the ECAS fitting and prevent the collet from releasing under back-pressure. They cost fractions of a cent each and dramatically improve retention.
- **High-stress junctions** (Y-splitter exit, toolhead entry) should be prioritized for clips. Lane inlets see less cyclic load and are lower priority.
- **Alternative:** For builders who want maximum reliability, threaded PTFE couplers at the Y-splitter exit are an option, though they add cost and complexity.

**BOM Addition:**
- 8x collet clips (2-lane) / 12x collet clips (4-lane) — match ECAS fitting count

---

## 2. Sealed Needle Roller Bearings

**Problem:** The current open 5x9x9 needle roller bearings work well initially but accumulate filament dust, PTFE particulate, and ambient debris over time. This increases friction and can cause inconsistent filament feeding.

**Recommendation:**
- Specify **sealed/shielded 5x9x9 needle roller bearings** as a recommended upgrade in the BOM. The marginal cost increase (~$0.20-0.50 per bearing) is offset by significantly extended maintenance intervals.
- Open bearings should remain listed as the budget option.

---

## 3. MCU Board Recommendations

**Problem:** The BOM currently specifies "MCU of choice" with pin/driver count requirements. This flexibility is good but causes confusion — CAN bus boards vary significantly in pin layout, driver count, and firmware support. This is the most common builder support question.

**Recommendation:**
Add a tested/recommended board list to the BOM:

| Board | Lanes Supported | Notes |
|-------|----------------|-------|
| BTT MMB (CAN) | 4-lane | Purpose-built MMU board, ideal match |
| Fly SHT36/42 | 2-lane | Common, well-documented |
| BTT EBB36/42 | 2-lane | Widely available |

Include verified pin mappings for each recommended board, or link to community-verified configs.

---

## 4. Slacker Sensor Return Spring

**Problem:** The current design uses a single small rubber band as the return spring for the Slacker sensor slider. Rubber bands degrade with UV exposure, heat (especially near a printer), and simple age. A degraded band changes the sensor's tension threshold, causing false taut/slack readings.

**Recommendations (pick one):**
- **Small extension spring:** Consistent force over lifetime, cheap, easy to source. Specify spring rate and free length in the BOM.
- **Printed TPU leaf spring:** Stays within the "all-printable" philosophy. Design a flexure into the Slider W Bands part that provides return force without a separate component. TPU fatigue life is excellent for small deflections.

Either option provides more consistent and durable return force than a rubber band.

---

## 5. TMC2209 Hold Current for Parked Lanes

**Problem:** The current 0.1A hold current is low enough that parked lane steppers are essentially freewheeling. With stiffer filaments (PETG, nylon, PC), spring-back force in the Bowden tube can cause filament to creep backward in the parked lane.

**Recommendations:**
- **Short-term (software) — recommended now:** Increase hold current to 0.2A for parked lanes. This adds minimal heat but provides enough detent torque to resist creep. This is the most practical near-term fix.
- **Long-term (mechanical) — currently blocked:** A one-way clutch mechanism (see [sprocket-mechanism-design-spec.md](sprocket-mechanism-design-spec.md)) could mechanically prevent backflow. However, Rob has previously tested commercial one-way bearings and found they cause filament unspooling due to free-direction drag. The mechanical approach is paused pending further investigation — the software hold-current fix should be prioritized.

---

## 6. Filament Path Dust Management

**Problem:** BMG gears and needle bearings generate fine brass/steel particulate over thousands of cycles. Combined with filament dust, this accumulates in the mechanical path.

**Recommendation:**
- Add a **maintenance note** to documentation: clean needle bearings and gear teeth every ~500 tool changes with compressed air or a small brush.
- For sealed bearing adopters, this interval extends to ~2000+ changes.

---

## Priority Summary

| Improvement | Cost | Impact | Difficulty |
|-------------|------|--------|------------|
| ECAS collet clips | ~$1 total | High — prevents mid-print failures | Trivial |
| Sealed bearings | ~$3-6 total | Medium — extends maintenance cycle | Drop-in replacement |
| MCU board list | $0 | High — reduces builder confusion | Documentation only |
| Spring vs rubber band | ~$0.50 | Medium — consistent sensor behavior | Minor redesign |
| Hold current tweak | $0 | Low-Medium — helps stiff filaments | Config change |
| Dust maintenance note | $0 | Low — preventive | Documentation only |
