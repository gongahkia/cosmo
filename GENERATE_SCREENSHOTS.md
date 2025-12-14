# Generate Missing Screenshots

You need to create 5 screenshots for the additional terrain types. I've added a screenshot hotkey (`x`) to make this easy!

## Quick Instructions

1. **Launch the application:**
   ```bash
   cd /Users/gongahkia/Desktop/coding/projects/cosmo
   love src
   ```

2. **For each terrain below, press the key, then press `x` to save a screenshot:**

   | Terrain | Key | Expected Filename |
   |---------|-----|-------------------|
   | Mountain Range | `p` | mountain_screenshot.png |
   | Dense Forest | `e` | forest_screenshot.png |
   | Canyon System | `y` | canyon_screenshot.png |
   | Archipelago | `h` | archipelago_screenshot.png |
   | Badlands | `l` | badlands_screenshot.png |

3. **After pressing `x`, check the console output.** It will show you where the screenshot was saved, typically in Love2d's save directory.

4. **Find your screenshots:**

   The screenshots are saved to Love2d's save directory. On macOS, this is typically:
   ```
   ~/Library/Application Support/LOVE/cosmo/
   ```

   To find the exact location, check the console output after pressing `x`.

5. **Rename and move the screenshots:**

   Once you have all 5 screenshots, rename them and move them to the reference folder:

   ```bash
   # Navigate to Love2d's save directory (check console for exact path)
   cd ~/Library/Application\ Support/LOVE/cosmo/

   # List the screenshots
   ls -la *.png

   # Copy and rename them to the reference folder
   cp mountain_screenshot.png /Users/gongahkia/Desktop/coding/projects/cosmo/asset/reference/16.png
   cp forest_screenshot.png /Users/gongahkia/Desktop/coding/projects/cosmo/asset/reference/17.png
   cp canyon_screenshot.png /Users/gongahkia/Desktop/coding/projects/cosmo/asset/reference/18.png
   cp archipelago_screenshot.png /Users/gongahkia/Desktop/coding/projects/cosmo/asset/reference/19.png
   cp badlands_screenshot.png /Users/gongahkia/Desktop/coding/projects/cosmo/asset/reference/20.png
   ```

## Alternative: Manual Screenshots

If the `x` key doesn't work, you can use your OS screenshot tool:

1. Press the terrain key (`p`, `e`, `y`, `h`, or `l`)
2. Use macOS screenshot: `Cmd + Shift + 4`, then press `Space` to capture the window
3. Save the file with the appropriate name (16.png, 17.png, etc.)
4. Move it to `/Users/gongahkia/Desktop/coding/projects/cosmo/asset/reference/`

## Verify

After generating all screenshots, verify they exist:

```bash
ls -la /Users/gongahkia/Desktop/coding/projects/cosmo/asset/reference/{16,17,18,19,20}.png
```

You should see all 5 files listed.

## Notes

- The screenshot hotkey (`x`) was just added to `src/main.lua`
- Screenshots are saved in PNG format
- The README.md already references these images, so they just need to exist in the right location
- Use medium size (press `2` before generating terrain) for consistency with other screenshots
