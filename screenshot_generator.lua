-- Screenshot generator for missing terrain types
-- This script runs with Love2d to automatically generate and save screenshots

local generators = {
    {key = "p", name = "mountain", filename = "16.png", description = "Mountain Range"},
    {key = "e", name = "forest", filename = "17.png", description = "Dense Forest"},
    {key = "y", name = "canyon", filename = "18.png", description = "Canyon System"},
    {key = "h", name = "archipelago", filename = "19.png", description = "Archipelago"},
    {key = "l", name = "badlands", filename = "20.png", description = "Badlands"}
}

local currentIndex = 1
local screenshotDelay = 0
local hasGenerated = false

function love.load()
    -- Load the main application
    package.path = package.path .. ";src/?.lua"

    -- Import generators
    local generator_modules = {
        mountain = require("generator.mountain"),
        forest = require("generator.forest"),
        canyon = require("generator.canyon"),
        archipelago = require("generator.archipelago"),
        badlands = require("generator.badlands")
    }

    -- Import utilities
    local file_utils = require("helper.files")

    -- Terrain colors
    terrainColors = {
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

    -- Set window size
    local width = 800
    local height = 600
    love.window.setMode(width, height, {resizable = false})

    print("Screenshot Generator Started")
    print("Generating terrain " .. currentIndex .. "/" .. #generators .. ": " .. generators[currentIndex].description)

    -- Generate first terrain
    generateNextTerrain(generator_modules, file_utils)
end

function generateNextTerrain(generator_modules, file_utils)
    if currentIndex > #generators then
        print("All screenshots generated!")
        love.event.quit()
        return
    end

    local gen = generators[currentIndex]
    local seed = os.time() + currentIndex -- Different seed for each terrain

    love.math.setRandomSeed(seed)
    math.randomseed(seed)

    -- Generate terrain with medium dimensions
    local width = 120
    local height = 80

    map = generator_modules[gen.name].generate(width, height)

    -- Calculate tile size to fit window
    local windowWidth, windowHeight = love.graphics.getDimensions()
    tileSize = math.min(
        windowWidth / width,
        windowHeight / height
    )
    tileSize = math.max(math.floor(tileSize), 4)

    hasGenerated = true
    screenshotDelay = 0.1 -- Wait a bit before taking screenshot

    print("Generated " .. gen.description .. " with seed " .. seed)
end

function love.draw()
    if not map then return end

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
    if hasGenerated and screenshotDelay > 0 then
        screenshotDelay = screenshotDelay - dt
        if screenshotDelay <= 0 then
            takeScreenshot()
            hasGenerated = false
            currentIndex = currentIndex + 1

            if currentIndex <= #generators then
                print("Generating terrain " .. currentIndex .. "/" .. #generators .. ": " .. generators[currentIndex].description)
                love.timer.sleep(0.5)

                -- Reload generators for next terrain
                local generator_modules = {
                    mountain = require("generator.mountain"),
                    forest = require("generator.forest"),
                    canyon = require("generator.canyon"),
                    archipelago = require("generator.archipelago"),
                    badlands = require("generator.badlands")
                }
                local file_utils = require("helper.files")
                generateNextTerrain(generator_modules, file_utils)
            else
                love.event.quit()
            end
        end
    end
end

function takeScreenshot()
    local gen = generators[currentIndex]
    local screenshot = love.graphics.newScreenshot()
    local filename = "asset/reference/" .. gen.filename

    -- Save screenshot
    local imageData = screenshot
    imageData:encode("png", filename)

    print("Screenshot saved: " .. filename)
end
