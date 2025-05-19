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