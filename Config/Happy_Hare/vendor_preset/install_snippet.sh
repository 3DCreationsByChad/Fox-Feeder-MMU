#!/bin/bash
# ============================================================================
# Fox Feeder Vendor Preset for Happy Hare install.sh
#
# This file contains the exact code snippets to add to Happy Hare's install.sh
# and extras/mmu_machine.py to register Fox Feeder as an official vendor.
#
# Fox Feeder Design Philosophy:
#   - Simple, low-cost, no unnecessary complexity
#   - No encoder (Slacker sync feedback replaces it)
#   - No espooler DC motors (Slacker is a passive buffer)
#   - No selector/servo (type-B: per-lane gear steppers)
#   - Minimal sensor count: post-gear + Slacker taut/slack
# ============================================================================

# ─────────────────────────────────────────────────────────────────────────────
# 1. Add to install.sh — option declaration (near other vendor options)
# ─────────────────────────────────────────────────────────────────────────────
#
#   option FOX_FEEDER     'Fox Feeder v1.0'
#

# ─────────────────────────────────────────────────────────────────────────────
# 2. Add to install.sh — case block (inside the vendor case statement)
# ─────────────────────────────────────────────────────────────────────────────

: << 'INSTALL_SH_CASE_BLOCK'
            "$FOX_FEEDER")
                HAS_ENCODER=no
                HAS_SELECTOR=no
                HAS_SERVO=no
                # No HAS_ESPOOLER — Fox Feeder uses passive Slacker buffer

                _hw_mmu_vendor="FoxFeeder"
                _hw_mmu_version="1.0"
                _hw_selector_type=VirtualSelector
                _hw_variable_bowden_lengths=0
                _hw_variable_rotation_distances=1
                _hw_require_bowden_move=1
                _hw_filament_always_gripped=1
                _hw_gear_gear_ratio="50:10"
                _hw_gear_run_current=0.8
                _hw_gear_hold_current=0.1

                # Extruder homing: collision detection (no toolhead sensor needed)
                _param_extruder_homing_endstop="collision"
                _param_extruder_collision_homing_current=30

                # Gate: post-gear sensor homing, short distances (compact design)
                _param_gate_homing_endstop="mmu_gate"
                _param_gate_homing_max=70
                _param_gate_preload_homing_max=70
                _param_gate_preload_parking_distance=-10
                _param_gate_unload_buffer=50
                _param_gate_parking_distance=23
                _param_gate_autoload=1
                _param_gate_final_eject_distance=0
                _param_has_filament_buffer=0

                # Auto-calibration: let Happy Hare measure bowden and tune gears
                _param_autocal_bowden_length=1
                _param_autotune_bowden_length=1
                _param_skip_cal_rotation_distance=0
                _param_autotune_rotation_distance=1
                _param_skip_cal_encoder=1
                _param_autotune_encoder=0

                # Slacker sync feedback: the core Fox Feeder feature
                _param_sync_feedback_enabled=1
                _param_sync_feedback_buffer_range=6
                _param_sync_feedback_buffer_maxrange=12
                ;;
INSTALL_SH_CASE_BLOCK

# ─────────────────────────────────────────────────────────────────────────────
# 3. Add to extras/mmu_machine.py — vendor constant (near other constants)
# ─────────────────────────────────────────────────────────────────────────────
#
#   VENDOR_FOX_FEEDER     = "FoxFeeder"
#

# ─────────────────────────────────────────────────────────────────────────────
# 4. Add to extras/mmu_machine.py — UNIT_ALT_DISPLAY_NAMES dict
# ─────────────────────────────────────────────────────────────────────────────
#
#   VENDOR_FOX_FEEDER: "Fox Feeder",
#

# ─────────────────────────────────────────────────────────────────────────────
# 5. Add to extras/mmu_machine.py — VENDORS list
# ─────────────────────────────────────────────────────────────────────────────
#
#   Add VENDOR_FOX_FEEDER to the VENDORS list
#

# ─────────────────────────────────────────────────────────────────────────────
# 6. Add to extras/mmu_machine.py — elif block in MmuMachine.__init__
# ─────────────────────────────────────────────────────────────────────────────

: << 'MMU_MACHINE_PY_ELIF'
            elif self.mmu_vendor == VENDOR_FOX_FEEDER:
                selector_type = 'VirtualSelector'
                variable_rotation_distances = 1
                variable_bowden_lengths = 0
                require_bowden_move = 1
                filament_always_gripped = 1
                can_crossload = 1
                has_bypass = 0
MMU_MACHINE_PY_ELIF
