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
        ['U'] = {0.3, 0.2, 0.1}, -- underground
        ['Y'] = {0.9, 0.9, 0.4}, -- dry grass
        ['Q'] = {0.5, 0.0, 0.0}, -- lava 
        ['N'] = {0.6, 0.6, 0.9}, -- tundra 
        ['Z'] = {0.3, 0.7, 0.9}, -- glacier
        ['X'] = {0.7, 0.7, 0.7}, -- gravel
        ['J'] = {0.2, 0.2, 0.2}, -- asphalt
        ['K'] = {0.8, 0.5, 0.2}, -- clay 
        ['I'] = {0.7, 0.9, 1.0}, -- shallow ice 
        ['U'] = {0.3, 0.2, 0.1}, -- cave 
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
        print("Error loading map:", message)
        love.event.quit()
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
end

function love.resize(w, h)
    tileSize = math.min(
        w / #map[1],
        h / #map
    )
    tileSize = math.max(math.floor(tileSize), 4)
end

function love.keypressed(key)
    if key == "d" then
        map = generators.desert.generate(120, 80)
    elseif key == "v" then
        map = generators.volcano.generate(120, 80)
    elseif key == "r" then
        map = generators.river.generate(120, 80)
    elseif key == "s" then
        map = generators.swamp.generate(120, 80)
    elseif key == "u" then
        map = generators.urban.generate(120, 80)
    elseif key == "f" then
        map = generators.farm.generate(120, 80)
    elseif key == "g" then
        map = generators.glacier.generate(120, 80)
    elseif key == "t" then
        map = generators.temple.generate(120, 80)
    elseif key == "n" then
        map = generators.tundra.generate(120, 80)
    elseif key == "i" then
        map = generators.island.generate(120, 80)
    elseif key == "c" then
        map = generators.cave.generate(120, 80)
    elseif key == "a" then
        map = generators.apocalypse.generate(120, 80)
    elseif key == "m" then
        map = generators.mega.generate(120, 80)
    elseif key == "o" then
        map = generators.coral.generate(120, 80)
    elseif key == "b" then
        map = generators.coast.generate(120, 80)
    elseif key == "p" then
        map = generators.mountain.generate(120, 80)
    elseif key == "e" then
        map = generators.forest.generate(120, 80)
    elseif key == "y" then
        map = generators.canyon.generate(120, 80)
    elseif key == "h" then
        map = generators.archipelago.generate(120, 80)
    elseif key == "l" then
        map = generators.badlands.generate(120, 80)
    end
    if map then
        file_utils.save_map(map, "map.txt")
        love.load()
    end
end