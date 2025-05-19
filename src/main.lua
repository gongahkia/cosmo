local graph = require "graph"

-- Define terrain colors
local terrainColors = {
    ['G'] = {0.4, 0.8, 0.4}, -- grass
    ['W'] = {0.3, 0.3, 1.0}, -- water
    ['R'] = {0.5, 0.5, 0.5}, -- rock
    ['S'] = {0.9, 0.8, 0.6}, -- sand
    ['D'] = {0.2, 0.1, 0.0}  -- dirt
    -- Add more terrain types here as needed
}

-- Load map from file
local map = {}
for line in io.lines("map.txt") do
    local row = {}
    for char in line:gmatch(".") do
        table.insert(row, char)
    end
    table.insert(map, row)
end

-- Error handling
if #map == 0 then
    error("Map file is empty or missing!")
end

-- Calculate map and window size
local mapWidth = #map[1]
local mapHeight = #map

-- Set max window size (e.g., 900x900)
local maxWindowWidth, maxWindowHeight = 900, 900
local tileSize = math.min(
    maxWindowWidth / mapWidth,
    maxWindowHeight / mapHeight
)
tileSize = math.max(math.floor(tileSize), 4)

-- Create window
local win = graph.Window("Terrain Visualization", mapWidth * tileSize, mapHeight * tileSize)

-- Draw terrain
for y, row in ipairs(map) do
    for x, char in ipairs(row) do
        local color = terrainColors[char] or {1, 0, 1}
        win:rectangle(
            (x-1) * tileSize,
            (y-1) * tileSize,
            tileSize,
            tileSize,
            {fill = color, stroke = {0,0,0}}
        )
    end
end

win:show()
graph.run()
