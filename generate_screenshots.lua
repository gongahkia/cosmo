-- Automated screenshot generator for missing terrain types
-- Run with: cd /path/to/cosmo && love generate_screenshots.lua

-- Add src to package path
package.path = package.path .. ";src/?.lua;src/helper/?.lua;src/generator/?.lua"

-- Import required modules
local noise = require("noise")
local voronoi = require("voronoi")
local cells = require("cells")
local color_utils = require("color")
local file_utils = require("files")

-- Import generators
local generators = {
    mountain = require("mountain"),
    forest = require("forest"),
    canyon = require("canyon"),
    archipelago = require("archipelago"),
    badlands = require("badlands")
}

-- Terrain definitions
local terrainQueue = {
    {name = "mountain", filename = "16.png", description = "Mountain Range", seed = 12345},
    {name = "forest", filename = "17.png", description = "Dense Forest", seed = 23456},
    {name = "canyon", filename = "18.png", description = "Canyon System", seed = 34567},
    {name = "archipelago", filename = "19.png", description = "Archipelago", seed = 45678},
    {name = "badlands", filename = "20.png", description = "Badlands", seed = 56789}
}

-- Terrain colors
local terrainColors = {
    ['G'] = {0.4, 0.8, 0.4}, -- grass
    ['W'] = {0.3, 0.3, 1.0}, -- water
    ['R'] = {0.5, 0.5, 0.5}, -- rock
    ['S'] = {0.9, 0.8, 0.6}, -- sand
    ['D'] = {0.2, 0.1, 0.0}, -- dirt
    ['F'] = {0.1, 0.5, 0.1}, -- forest
    ['T'] = {0.6, 0.4, 0.2}, -- tree trunks
    ['M'] = {0.8, 0.8, 0.8}, -- mountain snow
    ['L'] = {0.2, 0.4, 0.8}, -- lake
    ['B'] = {0.0, 0.0, 0.2}, -- deep water
    ['P'] = {0.7, 0.4, 0.7}, -- corrupted land
    ['C'] = {0.7, 0.7, 0.2}, -- farmland
    ['A'] = {1.0, 1.0, 1.0}, -- snow
    ['H'] = {0.5, 0.7, 0.3}, -- heath
    ['V'] = {0.1, 0.7, 0.5}, -- swamp
    ['O'] = {0.9, 0.6, 0.2}, -- orange sand
    ['E'] = {0.4, 0.2, 0.6}, -- dark forest
    ['U'] = {0.3, 0.2, 0.1}, -- underground/cave
    ['Y'] = {0.9, 0.9, 0.4}, -- dry grass
    ['Q'] = {0.5, 0.0, 0.0}, -- lava
    ['N'] = {0.6, 0.6, 0.9}, -- tundra
    ['Z'] = {0.3, 0.7, 0.9}, -- glacier
    ['X'] = {0.7, 0.7, 0.7}, -- gravel
    ['J'] = {0.2, 0.2, 0.2}, -- asphalt
    ['K'] = {0.8, 0.5, 0.2}, -- clay
    ['I'] = {0.7, 0.9, 1.0}, -- shallow ice
    ['-'] = {0.0, 0.0, 0.0, 0.0}, -- empty
}

-- Global state
local currentIndex = 1
local map = nil
local tileSize = 1
local screenshotTimer = 0
local isReady = false

function love.load()
    -- Set window size
    love.window.setMode(800, 600, {resizable = false})

    print("=== Screenshot Generator ===")
    print("Generating 5 missing terrain screenshots...")
    print("")

    generateNextTerrain()
end

function generateNextTerrain()
    if currentIndex > #terrainQueue then
        print("\n=== All screenshots generated! ===")
        print("Screenshots saved to asset/reference/")
        love.timer.sleep(2)
        love.event.quit()
        return
    end

    local terrain = terrainQueue[currentIndex]

    print(string.format("[%d/%d] Generating %s (seed: %d)...",
        currentIndex, #terrainQueue, terrain.description, terrain.seed))

    -- Set seed
    love.math.setRandomSeed(terrain.seed)
    math.randomseed(terrain.seed)

    -- Generate terrain (medium size like the other screenshots)
    local width = 120
    local height = 80
    map = generators[terrain.name].generate(width, height)

    -- Calculate tile size
    local windowWidth, windowHeight = love.graphics.getDimensions()
    tileSize = math.min(windowWidth / width, windowHeight / height)
    tileSize = math.max(math.floor(tileSize), 4)

    -- Mark as ready and set timer for screenshot
    isReady = true
    screenshotTimer = 0.2 -- Wait 200ms before screenshot
end

function love.draw()
    if not map then return end

    -- Clear screen
    love.graphics.clear(0, 0, 0)

    -- Draw terrain
    for y, row in ipairs(map) do
        for x, char in ipairs(row) do
            local color = terrainColors[char] or {1, 0, 1}
            love.graphics.setColor(color)
            love.graphics.rectangle(
                "fill",
                (x-1) * tileSize,
                (y-1) * tileSize,
                tileSize,
                tileSize
            )
        end
    end
end

function love.update(dt)
    if isReady then
        screenshotTimer = screenshotTimer - dt

        if screenshotTimer <= 0 then
            takeScreenshot()
            isReady = false
            currentIndex = currentIndex + 1

            -- Small delay before next terrain
            love.timer.sleep(0.5)
            generateNextTerrain()
        end
    end
end

function takeScreenshot()
    local terrain = terrainQueue[currentIndex]
    local filepath = "asset/reference/" .. terrain.filename

    -- Capture screenshot
    local screenshot = love.graphics.newScreenshot()

    -- Save to file
    local filedata = screenshot:encode("png")
    love.filesystem.write(filepath, filedata)

    print(string.format("   ✓ Saved: %s", filepath))
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end
