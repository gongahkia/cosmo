-- required imports

local noise = require("helper.noise")
local voronoi = require("helper.voronoi")
local cells = require("helper.cells")
local color_utils = require("helper.color")
local file_utils = require("helper.files")

local generators = {
    apocalypse = require("generator.apocalypse"),
    archipelago = require("generator.archipelago"),
    badlands = require("generator.badlands"),
    canyon = require("generator.canyon"),
    cave = require("generator.cave"),
    coast = require("generator.coast"),
    coral = require("generator.coral"),
    desert = require("generator.desert"),
    farm = require("generator.farm"),
    forest = require("generator.forest"),
    glacier = require("generator.glacier"),
    island = require("generator.island"),
    mega = require("generator.mega"),
    mountain = require("generator.mountain"),
    river = require("generator.river"),
    swamp = require("generator.swamp"),
    temple = require("generator.temple"),
    tundra = require("generator.tundra"),
    urban = require("generator.urban"),
    volcano = require("generator.volcano")
}

-- execution code

-- Global state
currentSeed = nil
currentGenerator = nil
exportMessage = nil
exportMessageTimer = 0
currentWidth = 120
currentHeight = 80

-- Dimension presets
dimensionPresets = {
    {name = "Small", width = 60, height = 40},
    {name = "Medium", width = 120, height = 80},
    {name = "Large", width = 200, height = 150},
    {name = "Huge", width = 300, height = 200}
}
currentPreset = 2  -- Medium by default

function love.load()
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
    map = {}
    local success, message = pcall(function()
        local lines = love.filesystem.lines("map.txt")
        for line in lines do
            local row = {}
            for char in line:gmatch(".") do
                table.insert(row, char)
            end
            table.insert(map, row)
        end
    end)
    if not success or #map == 0 then
        print("No map.txt found, generating default coastline terrain...")
        -- Generate default terrain (coastline)
        local defaultWidth = 120
        local defaultHeight = 80
        local defaultSeed = os.time()
        love.math.setRandomSeed(defaultSeed)
        math.randomseed(defaultSeed)
        currentSeed = defaultSeed
        currentGenerator = "coast"
        map = generators.coast.generate(defaultWidth, defaultHeight)
        file_utils.write_map(map, "map.txt")
    end
    local mapWidth = #map[1]
    local mapHeight = #map
    local screenWidth, screenHeight = love.window.getDesktopDimensions()
    local maxWindowWidth = screenWidth * 0.9
    local maxWindowHeight = screenHeight * 0.9
    tileSize = math.min(
        maxWindowWidth / mapWidth,
        maxWindowHeight / mapHeight
    )
    tileSize = math.max(math.floor(tileSize), 4)
    love.window.setMode(
        mapWidth * tileSize,
        mapHeight * tileSize,
        {resizable = true}
    )
end

function love.draw()
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

    -- Display seed and generator info
    if currentSeed and currentGenerator then
        love.graphics.setColor(1, 1, 1, 0.9)
        love.graphics.rectangle("fill", 10, 10, 350, 70)
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.print("Generator: " .. currentGenerator, 20, 20)
        love.graphics.print("Seed: " .. currentSeed, 20, 35)
        love.graphics.print("Size: " .. dimensionPresets[currentPreset].name .. " (" .. currentWidth .. "x" .. currentHeight .. ")", 20, 50)
    end

    -- Display export message
    if exportMessage and exportMessageTimer > 0 then
        love.graphics.setColor(0.2, 0.8, 0.2, 0.9)
        love.graphics.rectangle("fill", 10, 90, 400, 30)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(exportMessage, 20, 98)
    end
end

function love.update(dt)
    if exportMessageTimer > 0 then
        exportMessageTimer = exportMessageTimer - dt
        if exportMessageTimer <= 0 then
            exportMessage = nil
        end
    end
end

function love.resize(w, h)
    tileSize = math.min(
        w / #map[1],
        h / #map
    )
    tileSize = math.max(math.floor(tileSize), 4)
end

function generateTerrain(generatorName, width, height, seed)
    seed = seed or os.time()
    love.math.setRandomSeed(seed)
    math.randomseed(seed)

    currentSeed = seed
    currentGenerator = generatorName

    map = generators[generatorName].generate(width, height)
    file_utils.write_map(map, "map.txt")
    love.load()
end

function takeScreenshot(filename)
    local screenshot = love.graphics.newScreenshot()
    local filedata = screenshot:encode("png")
    love.filesystem.write(filename, filedata)
    exportMessage = "Screenshot saved: " .. filename
    exportMessageTimer = 3
    print("Screenshot saved to: " .. love.filesystem.getSaveDirectory() .. "/" .. filename)
end

function love.keypressed(key)
    -- Dimension preset keys
    if key == "1" then
        currentPreset = 1
        currentWidth = dimensionPresets[1].width
        currentHeight = dimensionPresets[1].height
        exportMessage = "Size: " .. dimensionPresets[1].name
        exportMessageTimer = 2
    elseif key == "2" then
        currentPreset = 2
        currentWidth = dimensionPresets[2].width
        currentHeight = dimensionPresets[2].height
        exportMessage = "Size: " .. dimensionPresets[2].name
        exportMessageTimer = 2
    elseif key == "3" then
        currentPreset = 3
        currentWidth = dimensionPresets[3].width
        currentHeight = dimensionPresets[3].height
        exportMessage = "Size: " .. dimensionPresets[3].name
        exportMessageTimer = 2
    elseif key == "4" then
        currentPreset = 4
        currentWidth = dimensionPresets[4].width
        currentHeight = dimensionPresets[4].height
        exportMessage = "Size: " .. dimensionPresets[4].name
        exportMessageTimer = 2

    -- Terrain generation keys
    elseif key == "d" then
        generateTerrain("desert", currentWidth, currentHeight)
    elseif key == "v" then
        generateTerrain("volcano", currentWidth, currentHeight)
    elseif key == "r" then
        generateTerrain("river", currentWidth, currentHeight)
    elseif key == "s" then
        generateTerrain("swamp", currentWidth, currentHeight)
    elseif key == "u" then
        generateTerrain("urban", currentWidth, currentHeight)
    elseif key == "f" then
        generateTerrain("farm", currentWidth, currentHeight)
    elseif key == "g" then
        generateTerrain("glacier", currentWidth, currentHeight)
    elseif key == "t" then
        generateTerrain("temple", currentWidth, currentHeight)
    elseif key == "n" then
        generateTerrain("tundra", currentWidth, currentHeight)
    elseif key == "i" then
        generateTerrain("island", currentWidth, currentHeight)
    elseif key == "c" then
        generateTerrain("cave", currentWidth, currentHeight)
    elseif key == "a" then
        generateTerrain("apocalypse", currentWidth, currentHeight)
    elseif key == "m" then
        generateTerrain("mega", currentWidth, currentHeight)
    elseif key == "o" then
        generateTerrain("coral", currentWidth, currentHeight)
    elseif key == "b" then
        generateTerrain("coast", currentWidth, currentHeight)
    elseif key == "p" then
        generateTerrain("mountain", currentWidth, currentHeight)
    elseif key == "e" then
        generateTerrain("forest", currentWidth, currentHeight)
    elseif key == "y" then
        generateTerrain("canyon", currentWidth, currentHeight)
    elseif key == "h" then
        generateTerrain("archipelago", currentWidth, currentHeight)
    elseif key == "l" then
        generateTerrain("badlands", currentWidth, currentHeight)

    -- Export keys
    elseif key == "j" and map and currentSeed then
        local metadata = {
            generator = currentGenerator,
            seed = currentSeed,
            timestamp = os.date("%Y-%m-%d %H:%M:%S")
        }
        local filename = currentGenerator .. "_" .. currentSeed .. ".json"
        file_utils.export_to_json(map, metadata, filename)
        exportMessage = "Exported to " .. filename
        exportMessageTimer = 3
    elseif key == "w" and map then
        local filename = (currentGenerator or "terrain") .. "_" .. (currentSeed or "unknown") .. ".csv"
        file_utils.export_to_csv(map, filename)
        exportMessage = "Exported to " .. filename
        exportMessageTimer = 3

    -- Screenshot key
    elseif key == "x" and map then
        local filename = (currentGenerator or "terrain") .. "_screenshot.png"
        takeScreenshot(filename)
    end
end