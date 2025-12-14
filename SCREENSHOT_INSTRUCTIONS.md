# Screenshot Generation Instructions

This guide explains how to generate the missing terrain screenshots (16-20) for the README.

## Missing Screenshots

The following terrain types need screenshots:
- **16.png** - Mountain Range (key: `p`)
- **17.png** - Dense Forest (key: `e`)
- **18.png** - Canyon System (key: `y`)
- **19.png** - Archipelago (key: `h`)
- **20.png** - Badlands (key: `l`)

## Method 1: Automated Generation (Recommended)

Run the automated screenshot generator:

```bash
cd /Users/gongahkia/Desktop/coding/projects/cosmo
love generate_screenshots.lua
```

This will automatically:
1. Generate all 5 missing terrains with preset seeds
2. Save screenshots to `asset/reference/` as 16.png through 20.png
3. Exit when complete

**Note**: This requires Love2d to be installed. Install from https://love2d.org/

## Method 2: Manual Generation

If the automated script doesn't work, generate screenshots manually:

### Step 1: Launch the application
```bash
cd /Users/gongahkia/Desktop/coding/projects/cosmo
love src
```

### Step 2: Generate each terrain and take screenshots

For each terrain, press the corresponding key, then take a screenshot:

1. **Mountain Range**: Press `p`, screenshot as `16.png`
2. **Dense Forest**: Press `e`, screenshot as `17.png`
3. **Canyon System**: Press `y`, screenshot as `18.png`
4. **Archipelago**: Press `h`, screenshot as `19.png`
5. **Badlands**: Press `l`, screenshot as `20.png`

### Step 3: Save screenshots

Save screenshots to `asset/reference/` with the corresponding filenames.

#### macOS Screenshot:
- `Cmd + Shift + 4` then click and drag to capture the window
- Or `Cmd + Shift + 4` then press `Space` to capture entire window

#### Linux Screenshot:
- Use `gnome-screenshot` or `scrot`
- Or `Alt + Print Screen` to capture active window

#### Windows Screenshot:
- `Windows + Shift + S` to use Snip & Sketch
- Or `Alt + Print Screen` to capture active window

## Method 3: Add Screenshot Key to Main Application

You can also add a screenshot hotkey to the main application by adding this to `src/main.lua`:

Add this function before `love.keypressed`:
```lua
function takeScreenshot(filename)
    local screenshot = love.graphics.newScreenshot()
    local filedata = screenshot:encode("png")
    love.filesystem.write(filename, filedata)
    exportMessage = "Screenshot saved: " .. filename
    exportMessageTimer = 3
end
```

Add this to the `love.keypressed` function (around line 262):
```lua
    elseif key == "x" then
        -- Take screenshot
        local filename = "screenshot_" .. os.time() .. ".png"
        takeScreenshot(filename)
```

Then press `x` after generating any terrain to save a screenshot.

## Verification

After generating screenshots, verify all images exist:

```bash
ls -la asset/reference/ | grep -E "1[6-9]|20"
```

You should see:
- 16.png (Mountain Range)
- 17.png (Dense Forest)
- 18.png (Canyon System)
- 19.png (Archipelago)
- 20.png (Badlands)
