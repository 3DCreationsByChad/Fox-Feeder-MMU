# 🦊 Fox Feeder + Happy Hare Integration Guide

This guide explains how to use **Happy Hare's beautiful interface** with **Fox Feeder's simple, reliable hardware**.

## 🎯 Why Happy Hare Integration?

### You Get:
✅ **Clean, organized UI** in Mainsail/Fluidd dashboards
✅ **Visual status indicators** for each filament lane
✅ **Dedicated MMU controls** (not scattered in macro lists)
✅ **Advanced features** when you need them (EndlessSpool, Spoolman, etc.)
✅ **Professional logging** and diagnostics
✅ **Same simple hardware** - no changes needed!

### You Keep:
✅ **Fox Feeder's proven filament handling**
✅ **Slacker sensor intelligence**
✅ **Low-cost, simple design**
✅ **Easy calibration with MEASURE_BOWDEN**

---

## 📋 Two Setup Options

### Option 1: Simple Mode (Current)
- **Best for**: Quick setup, beginners, "just works" approach
- **Time**: 5 minutes
- **Files**: Copy `WIP_MMU.cfg` to printer
- **Interface**: Standard Klipper macros in dashboard

### Option 2: Happy Hare Mode (This Guide)
- **Best for**: Clean UI, advanced features, better organization
- **Time**: 20-30 minutes
- **Files**: Install Happy Hare + Fox Feeder configs
- **Interface**: Dedicated MMU dashboard with visual feedback

> **💡 Tip**: You can switch between modes anytime! Both use the same hardware.

---

## 🚀 Installation: Happy Hare Mode

### Prerequisites
- Klipper installed and working
- Fox Feeder hardware assembled and wired
- SSH access to your Raspberry Pi
- Internet connection

### Step 1: Install Happy Hare

SSH into your Raspberry Pi and run:

```bash
cd ~
git clone https://github.com/moggieuk/Happy-Hare.git
cd Happy-Hare
./install.sh
```

**During installation:**
- Select "Other/Custom MMU" when asked for MMU type
- Choose "2" for number of gates/lanes
- Answer "No" to encoder support
- Answer "Yes" to toolhead sensor (Slacker taut sensor)

### Step 2: Copy Fox Feeder Configs

```bash
# Create Happy Hare config directory
mkdir -p ~/printer_data/config/mmu

# Copy Fox Feeder Happy Hare configs
cp ~/Fox-Feeder-MMU/Config/HappyHare/* ~/printer_data/config/mmu/
```

### Step 3: Update Your printer.cfg

Add this line to your `printer.cfg`:

```ini
# Fox Feeder MMU with Happy Hare
[include mmu/mmu.cfg]
```

**Important**: Comment out or remove your old Fox Feeder include:
```ini
# [include WIP_MMU.cfg]  # OLD - Disabled for Happy Hare mode
```

### Step 4: Verify MCU UUID

Check that your CAN-bus UUID matches in `mmu.cfg`:

```bash
~/klippy-env/bin/python ~/klipper/scripts/canbus_query.py can0
```

Update the UUID in `mmu/mmu.cfg` if different:
```ini
[mcu pcu]
canbus_uuid: YOUR_UUID_HERE  # Update this!
```

### Step 5: Restart Klipper

```bash
sudo systemctl restart klipper
```

Check for errors in your Mainsail/Fluidd console.

### Step 6: Initial Calibration

Run these commands in your console:

```gcode
# Home the MMU
MMU_HOME

# Check sensor status
FOX_FEEDER_STATUS

# Load filament into lane 0 manually, then:
MMU_CALIBRATE_BOWDEN LANE=0

# Repeat for lane 1
MMU_CALIBRATE_BOWDEN LANE=1
```

### Step 7: Test Tool Changes

```gcode
# Load T0
T0

# Switch to T1
T1

# Check status
MMU_STATUS
```

---

## 🎛️ Happy Hare Interface Features

### Dashboard Controls You'll See:

1. **MMU Status Panel**
   - Current tool/gate
   - Filament position
   - Sensor states
   - Gate availability

2. **Quick Actions**
   - `MMU_HOME` - Initialize MMU
   - `MMU_STATUS` - View detailed status
   - `MMU_EJECT` - Eject current filament
   - `MMU_RECOVER` - Recover from errors

3. **Tool Selection**
   - `T0` - Load lane 0
   - `T1` - Load lane 1
   - Automatic tool changing during prints

4. **Calibration**
   - `MMU_CALIBRATE_BOWDEN` - Measure bowden length
   - `MMU_CALIBRATE_GATES` - Calibrate gate positions
   - `MMU_CALIBRATE_ENCODER` - (Not used on Fox Feeder)

5. **Statistics**
   - Gate usage tracking
   - Swap success rates
   - Heat maps showing reliability

---

## 🔧 Configuration Guide

### Bowden Length

Your current bowden length is **980mm** (from `WIP_MMU.cfg`). Happy Hare uses this in `mmu_parameters.cfg`:

```ini
calibration_bowden_length: 980
```

To recalibrate:
```gcode
MMU_CALIBRATE_BOWDEN LANE=0
```

### Extruder Feed Length

Currently **105mm** (distance to clear extruder). Configured in `mmu_parameters.cfg`:

```ini
extruder_load_length: 105
extruder_unload_length: 105
```

### Slacker Sensor Behavior

The Slacker sensors (taut/slack) are mapped to Happy Hare's feedback system:

- **Taut sensor** → Toolhead sensor (detects filament at nozzle)
- **Slack sensor** → Extruder entry sensor (detects filament entering gears)

Active monitoring during prints prevents jams!

### Tip Forming

Fox Feeder's proven `FORM_TIP` macro is preserved:

```ini
form_tip_macro: _MMU_FORM_TIP
```

Happy Hare calls this automatically during unloads.

---

## 🎨 Customization

### Changing Number of Lanes

To expand to 4 lanes in the future:

**1. Update `mmu_hardware.cfg`:**
```ini
mmu_num_gates: 4  # Change from 2 to 4
```

**2. Add stepper configs for lanes 2-3:**
```ini
[manual_stepper gear_stepper_2]
# ... (copy from gear_stepper_0, update pins)

[manual_stepper gear_stepper_3]
# ... (copy from gear_stepper_0, update pins)
```

**3. Add sensors:**
```ini
[filament_switch_sensor mmu_gate_2]
switch_pin: ^pcu:sensor_2

[filament_switch_sensor mmu_gate_3]
switch_pin: ^pcu:sensor_3
```

### Enabling EndlessSpool

Automatically switch to backup spool when one runs out:

**In `mmu_parameters.cfg`:**
```ini
enable_endless_spool: 1  # Already enabled!
```

**Map spools:**
```gcode
MMU_ENDLESS_SPOOL_GROUPS GROUPS=0,0,1,1
# Gates 0,1 = Group 0 (same color)
# Gates 2,3 = Group 1 (different color)
```

### Spoolman Integration

Track filament usage and remaining length:

**In `mmu_parameters.cfg`:**
```ini
enable_spoolman: 1
spoolman_url: http://YOUR_PI_IP:7912
```

Then assign spool IDs in Happy Hare UI.

---

## 🐛 Troubleshooting

### "MMU not homed" error
```gcode
MMU_HOME
```

### Sensors not detecting
```gcode
# Check sensor states
QUERY_FILAMENT_SENSOR SENSOR=mmu_gate_0
QUERY_FILAMENT_SENSOR SENSOR=mmu_taut
QUERY_FILAMENT_SENSOR SENSOR=mmu_slack

# Verify wiring matches WIP_MMU.cfg pin assignments
```

### Wrong bowden length
```gcode
# Re-measure
MMU_CALIBRATE_BOWDEN LANE=0
MMU_CALIBRATE_BOWDEN LANE=1

# Or manually set in mmu_parameters.cfg:
# calibration_bowden_length: 980
```

### Tool change fails
```gcode
# Check detailed status
MMU_STATUS

# Manual recovery
MMU_RECOVER

# Check logs
MMU_DUMP
```

### Happy Hare not loading
Check Klipper logs:
```bash
tail -f ~/printer_data/logs/klippy.log
```

Look for errors related to `mmu` or `happy_hare`.

---

## 📊 Comparison: Simple vs Happy Hare

| Feature | Simple Mode | Happy Hare Mode |
|---------|-------------|-----------------|
| **Setup Time** | 5 min | 30 min |
| **Interface** | Basic macros | Dedicated UI |
| **Visual Feedback** | ❌ Text only | ✅ Graphs, heatmaps |
| **Statistics** | ❌ None | ✅ Detailed tracking |
| **EndlessSpool** | ⚠️ Manual | ✅ Automatic |
| **Error Recovery** | ⚠️ Manual | ✅ Automatic retry |
| **Spoolman** | ❌ No | ✅ Yes |
| **Slicer Integration** | ⚠️ Basic | ✅ Advanced |
| **Learning Curve** | Easy | Moderate |
| **Customization** | High | Very High |

---

## 🔄 Switching Between Modes

### Happy Hare → Simple

1. Comment out Happy Hare in `printer.cfg`:
   ```ini
   # [include mmu/mmu.cfg]
   ```

2. Enable simple mode:
   ```ini
   [include WIP_MMU.cfg]
   ```

3. Restart Klipper

### Simple → Happy Hare

Reverse the above steps!

---

## 📚 Additional Resources

- **Happy Hare Documentation**: https://github.com/moggieuk/Happy-Hare/wiki
- **Happy Hare Discord**: https://discord.gg/happy-hare
- **Fox Feeder Repository**: https://github.com/3DCreationsByChad/Fox-Feeder-MMU
- **Klipper Documentation**: https://www.klipper3d.org/

---

## 🙏 Credits

- **Fox Feeder Hardware**: Chad (3DCreationsByChad)
- **Happy Hare Software**: moggieuk
- **Integration**: Community collaboration

---

## 📝 License

This integration guide is MIT licensed, matching both Fox Feeder and Happy Hare projects.

---

**Questions? Issues?**
Open an issue on the Fox Feeder repository or ask in the Happy Hare Discord!

Happy printing! 🎉
