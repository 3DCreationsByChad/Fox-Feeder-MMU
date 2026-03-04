# Fox Feeder MMU - Happy Hare Integration Notes

## Overview

The Fox Feeder MMU is a **type-B (VirtualSelector)** design, the same category as
Box Turtle, Night Owl, and QuattroBox. Each lane has its own gear stepper motor —
there is no shared selector servo. This makes it natively compatible with Happy Hare's
VirtualSelector architecture.

The Fox Feeder's unique "Slacker" sensor system maps directly to Happy Hare's
`sync_feedback_tension_pin` and `sync_feedback_compression_pin` — no encoder needed.

---

## Hardware Mapping: Fox Feeder → Happy Hare

| Fox Feeder Component | Happy Hare Equivalent | Pin | Notes |
|---|---|---|---|
| `stepper_0` (extruder_stepper) | `stepper_mmu_gear` | PB15/PB14/PA8/PA10 | Base gear stepper |
| `stepper_1` (extruder_stepper) | `stepper_mmu_gear_1` | PD2/PB13/PD1/PC7 | Additional gear stepper |
| `sensor_0` (filament_switch) | `post_gear_switch_pin_0` | PB9 | Gate 0 filament sensor |
| `sensor_1` (filament_switch) | `post_gear_switch_pin_1` | PB8 | Gate 1 filament sensor |
| `taut` (filament_switch) | `sync_feedback_tension_pin` | PA3 | Slacker tension sensor |
| `slack` (filament_switch) | `sync_feedback_compression_pin` | PA4 | Slacker compression sensor |
| CAN bus MCU (`pcu`) | `[mcu mmu]` canbus_uuid | - | Same CAN connection |
| TMC2209 @ 0.8A | TMC2209 @ 0.7-0.8A | - | Compatible |
| CW2 50:10 gear ratio | `gear_ratio: 50:10` | - | Same |

## What the Current Fox Feeder Hardware Supports (No Changes Needed)

1. **Per-lane gear steppers** — Maps perfectly to Happy Hare's type-B gear stepper model
2. **Post-gear filament sensors** — Used as `gate_homing_endstop: mmu_gate` for reliable loading
3. **Slacker taut/slack sensors** — Direct mapping to Happy Hare's sync feedback system
4. **CAN bus MCU** — Fully supported by Happy Hare
5. **TMC2209 UART drivers** — Standard Happy Hare driver configuration

## What the Current Fox Feeder Config Was Doing Manually (Now Handled by Happy Hare)

| Old Fox Feeder Macro | Happy Hare Replacement |
|---|---|
| `SYNC_EXTRUDER` / `ISOLATE_EXTRUDER` | Built-in sync controller |
| `FORM_TIP` (hardcoded G-code moves) | `_MMU_FORM_TIP` with tunable variables |
| `LOAD_FILAMENT` (350-iteration polling loops) | `MMU_LOAD` with proper state machine |
| `REMOVE_FILAMENT` (350-iteration polling loops) | `MMU_UNLOAD` with proper state machine |
| `CHECK_STATUS` (manual lane probing) | `MMU_CHECK_GATE` / automatic gate status |
| `SET_LANE` (manual active lane tracking) | Automatic tool-to-gate mapping |
| `MEASURE_BOWDEN` (manual bowden measurement) | `MMU_CALIBRATE_BOWDEN` with auto-calibration |
| `_SELF_CENTER` (find neutral Slacker position) | `toolhead_post_load_tension_adjust: 1` |
| Slacker enable/disable via SET_FILAMENT_SENSOR | `sync_feedback_enabled: 1` |
| `_FILAMENT_VARS` variable store | `mmu_vars.cfg` persisted variables |

## Recommended Hardware Improvements (Optional)

### 1. Pre-Gate Sensors (Recommended)
**What:** Add a filament switch sensor at the entrance of each lane (before the gear)
**Why:** Enables:
- `gate_autoload: 1` — automatic filament detection when inserted
- Endless spool detection — knows when a spool runs out vs filament jam
- Better gate status reporting
**Config:** `pre_gate_switch_pin_0`, `pre_gate_switch_pin_1` in `[mmu_sensors]`
**Hardware:** Simple microswitch or optical sensor per lane

### 2. NeoPixel LED Chain (Nice to Have)
**What:** Add a strip of NeoPixels (1-2 per lane)
**Why:** Happy Hare provides per-gate LED status:
- Loading/unloading animation
- Filament color display
- Error indication
- Gate availability status
**Config:** `[neopixel mmu_leds]` + `[mmu_leds]` sections
**Hardware:** WS2812B chain, one data pin needed

### 3. Toolhead Entry Sensor (Nice to Have)
**What:** Filament switch sensor near extruder gears
**Why:** Changes `extruder_homing_endstop` from `collision` to `extruder` for more
reliable extruder entry detection. Collision detection works but can be less precise.
**Config:** `extruder_switch_pin` in `[mmu_sensors]` (on printer MCU, not MMU MCU)

### 4. Eject Buttons (Nice to Have)
**What:** Pushbutton per lane for manual filament eject
**Why:** Convenient for filament changes without console commands
**Config:** Happy Hare addon `mmu_eject_buttons_hw.cfg`
**Hardware:** Simple pushbutton per lane, one GPIO pin each

## Hardware NOT Needed

- **Encoder** — The Slacker sensor system provides equivalent functionality for
  sync feedback. An encoder would add redundancy but is not required.
- **Selector motor** — Type-B design has no selector
- **Servo** — Type-B design has no servo
- **ESpooler (DC motors)** — The Slacker's passive buffer mechanism handles
  filament tension management. DC motor espoolers (as used in Box Turtle) are
  an alternative approach but not needed when the Slacker is working well.

## Sensor Position Clarification

**Important:** The current Fox Feeder sensors (`sensor_0`/`sensor_1` on PB9/PB8)
are mapped as **post-gear sensors** (`post_gear_switch_pin`) in this config. This
means they detect filament **after** it passes through the gear drive.

If the sensors are actually positioned **before** the gear drive (at the lane entrance),
they should instead be mapped as `pre_gate_switch_pin` and you would need to change
`gate_homing_endstop` to `mmu_gear` (using TMC stallguard for gate homing) or add
separate post-gear sensors.

Verify the physical sensor placement and adjust accordingly.

## Slacker Buffer Dimensions

The sync feedback parameters need to match the physical Slacker mechanism:

- `sync_feedback_buffer_range: 6` — Distance (mm) between where the taut sensor
  triggers and where the slack sensor triggers. Measure the physical travel.
- `sync_feedback_buffer_maxrange: 12` — Total end-to-end travel range of the
  Slacker buffer mechanism.

These values affect how aggressively Happy Hare corrects gear speed during printing.
If the buffer range is wrong, the sync feedback will over-correct or under-correct.

## Fox Feeder as a Happy Hare Vendor Preset

Fox Feeder is designed to be its **own vendor preset** in Happy Hare — not a
modified BoxTurtle. The Fox Feeder philosophy is simplicity:

| | BoxTurtle | Fox Feeder |
|---|---|---|
| Encoder | No | No |
| ESpooler (DC motors) | **Yes** | **No** (passive Slacker) |
| Gate homing max | 300mm | 70mm |
| Parking distance | 100mm | 23mm |
| Final eject distance | 100mm | 0mm |
| Sync feedback | Yes | Yes (Slacker) |
| Pre-gate sensors | Yes | Optional |
| LED chain | Yes | Optional |

The `vendor_preset/` directory contains the exact code snippets needed to register
Fox Feeder as a vendor in Happy Hare's `install.sh` and `extras/mmu_machine.py`.

## Installation Steps

1. Install Happy Hare following the official instructions
2. During install, select **Fox Feeder v1.0** (once the vendor preset is merged)
   - Or select **Other** and manually apply the FoxFeeder config files
3. Copy these config files to your Happy Hare config directory:
   - `mmu.cfg` — MCU and pin aliases
   - `mmu_hardware.cfg` — Hardware definitions
   - `mmu_parameters.cfg` — Tuning parameters
4. Remove or disable the old `WIP_MMU.cfg` and any FriendlyFox macros
5. Run Happy Hare calibration:
   - `MMU_CALIBRATE_BOWDEN` — Measures bowden length automatically
   - `MMU_CALIBRATE_GATES` — Calibrates per-gate rotation distance
6. Tune tip forming parameters in `mmu_macro_vars.cfg`

## PCU Board Pin Compatibility

The Fox Feeder's PCU board pin layout (PA/PB/PC/PD naming, STM32-based, CAN bus)
is very similar to the **BTT MMB CAN v1.0** board used by Box Turtle. In fact,
comparing the pin assignments:

| Function | Fox Feeder PCU | BTT MMB v1.0 |
|---|---|---|
| Gear 0 step | PB15 | PB15 |
| Gear 0 dir | PB14 | PB14 |
| Gear 0 enable | PA8 | PA8 |
| Gear 0 uart | PA10 | PA10 |
| Gear 1 step | PD2 | PD2 |
| Gear 1 dir | PB13 | PB13 |
| Gear 1 enable | PD1 | PD1 |
| Gear 1 uart | PC7 | PC7 |

**The Fox Feeder PCU appears to use the same (or very similar) board as the BTT
MMB CAN v1.0.** This is useful for pin reference, but Fox Feeder has its own
vendor preset — it is NOT a modified BoxTurtle.

If the board is indeed a BTT MMB CAN, there are additional pins available for
pre-gate sensors and NeoPixels that the current Fox Feeder config doesn't use.
