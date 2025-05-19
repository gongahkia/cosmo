function generate_sky_realm(width, height, params)
    params = params or {}
    local anti_gravity = params.anti_gravity or 0.9
    local crystal_density = params.crystal_density or 0.15
    local cloud_layer = params.cloud_layer or 0.6
    local spectral_map = {}
    for y = 1, height do
        spectral_map[y] = {}
        for x = 1, width do
            local nx = x / 50
            local ny = y / 50
            local fft = love.math.noise(nx, ny) * 0.5 +
                       love.math.noise(nx * 3, ny * 3) * 0.3 +
                       love.math.noise(nx * 9, ny * 9) * 0.2
            spectral_map[y][x] = fft
        end
    end
    local islands = {}
    local num_islands = math.floor(width * height / 1000)
    for _ = 1, num_islands do
        local island = {
            x = love.math.random(width),
            y = love.math.random(height),
            radius = love.math.random(8, 25) * anti_gravity,
            height = love.math.random()
        }
        table.insert(islands, island)
    end
    local terrain = {}
    local debris_map = {}
    for y = 1, height do
        terrain[y] = {}
        debris_map[y] = {}
        for x = 1, width do
            local max_influence = 0
            for _, island in ipairs(islands) do
                local dx = x - island.x
                local dy = y - island.y
                local distance = math.sqrt(dx^2 + dy^2) / island.radius
                local influence = math.max(0, 1 - distance^2)
                max_influence = math.max(max_influence, influence * island.height)
            end
            local base_value = spectral_map[y][x]
            local combined = base_value * 0.7 + max_influence * 0.3
            if combined > 0.5 then
                terrain[y][x] = 'R'  
                for dy = 1, math.floor((1 - anti_gravity) * 10) do
                    if y + dy <= height then
                        debris_map[y + dy] = debris_map[y + dy] or {}
                        debris_map[y + dy][x] = love.math.random() < 0.3 and 'X' or 'R'
                    end
                end
            elseif combined > 0.4 then
                terrain[y][x] = 'G'  
            else
                terrain[y][x] = '-'  
            end
        end
    end
    for y = 1, height do
        for x = 1, width do
            if terrain[y][x] == 'R' and love.math.random() < crystal_density then
                terrain[y][x] = 'Q'  
            end
            if debris_map[y] and debris_map[y][x] then
                terrain[y][x] = debris_map[y][x]
            end
        end
    end
    for y = 1, height do
        for x = 1, width do
            if love.math.noise(x/30, y/30) > cloud_layer and terrain[y][x] == '-' then
                terrain[y][x] = 'M'  
            end
        end
    end
    local map = {}
    for y = 1, height do
        map[y] = table.concat(terrain[y])
    end
    local success, message = pcall(function()
        love.filesystem.write("map.txt", table.concat(map, "\n"))
    end)
    return success, message
end