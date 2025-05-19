function love.load()
    terrainColors = {
        ['G'] = {0.4, 0.8, 0.4}, -- grass
        ['W'] = {0.3, 0.3, 1.0}, -- water
        ['R'] = {0.5, 0.5, 0.5}, -- rock
        ['S'] = {0.9, 0.8, 0.6}, -- sand
        ['D'] = {0.2, 0.1, 0.0}  -- dirt
        -- FUA
        -- to add more terrain types here
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