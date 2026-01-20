# Brightness Restore Bug Fix

## Problem
After the screen dims due to inactivity (150 seconds), moving the mouse should restore brightness to its previous level. However, the screen was staying dark or getting darker instead of brightening.

## Root Cause
The idle timeout command combined save and set operations in a single command:
```javascript
"onTimeout": "ambxst brightness 10 -s"
```

This could cause timing issues where the brightness save captured the wrong value during rapid idle/resume cycles.

## Solution
The command has been split into two sequential operations:
```javascript
"onTimeout": "ambxst brightness -s && ambxst brightness 10"
```

This ensures:
1. Save completes before dimming starts (via `&&` operator)
2. Saved brightness always reflects pre-dimmed state
3. No race conditions between operations

## Applying the Fix

### For New Installations
The fix is automatically applied to new installations. No action needed.

### For Existing Installations

**Option 1: Use the Migration Script (Recommended)**
```bash
bash scripts/migrate_brightness_fix.sh
ambxst reload
```

**Option 2: Manual Update**
1. Edit your config file:
   ```bash
   nano ~/.config/Ambxst/config/system.json
   ```

2. Find the brightness listener (around line with `"timeout": 150`)

3. Change this line:
   ```json
   "onTimeout": "ambxst brightness 10 -s",
   ```
   
   To:
   ```json
   "onTimeout": "ambxst brightness -s && ambxst brightness 10",
   ```

4. Save the file and reload Ambxst:
   ```bash
   ambxst reload
   ```

**Option 3: Reset to Defaults**
If you want to reset to default configuration:
```bash
rm ~/.config/Ambxst/config/system.json
ambxst reload
```
This will regenerate the config file with the fix applied.

## Testing the Fix
1. Set your brightness to a known level (e.g., 100%)
2. Wait 150 seconds for idle timeout (screen dims to 10%)
3. Move mouse to resume
4. Screen should return to your original brightness (100%)
5. Repeat steps 2-4 to verify consistency

## Files Changed
- `config/defaults/system.js` (line 14): Default system configuration
- `config/Config.qml` (line 1039): Config adapter default values
- `scripts/migrate_brightness_fix.sh`: Migration script for existing installations

## Technical Details
The fix separates the save and dim operations:
- **First command** (`ambxst brightness -s`): Saves current brightness to `/tmp/ambxst_brightness_saved.txt`
- **Second command** (`ambxst brightness 10`): Dims screen to 10%
- **On resume** (`ambxst brightness -r`): Restores saved brightness

The `&&` operator ensures the save completes successfully before dimming begins.
