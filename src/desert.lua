function generate_dunes(width, height)
    local wind_dir = math.rad(30)  
    local sand_mobility = 0.7
    local dune_spacing = 10  
    local wind_vector = {x = math.cos(wind_dir), y = math.sin(wind_dir)}
    local heightmap = {}
    local terrain = {}
    for y = 1, height do
        heightmap[y] = {}
        terrain[y] = {}
        for x = 1, width do
            local nx = x/dune_spacing + wind_vector.x * y/dune_spacing
            local ny = y/dune_spacing + wind_vector.y * x/dune_spacing
            local elevation = love.math.noise(nx, ny) * 0.7 +
                            love.math.noise(nx*2, ny*2) * 0.3
            heightmap[y][x] = elevation
        end
    end
    for y = 1, height do
        for x = 1, width do
            local along_wind = x * wind_vector.x + y * wind_vector.y
            local across_wind = x * wind_vector.y - y * wind_vector.x
            local dune_shape = math.abs(across_wind/dune_spacing) ^ 2
            local dune_wave = math.sin(along_wind/dune_spacing * math.pi*2)
            local dune_height = math.max(0, (1 - dune_shape) * (dune_wave + 1)/2)
            heightmap[y][x] = heightmap[y][x] + dune_height * sand_mobility
        end
    end
    for y = 2, height-1 do
        for x = 2, width-1 do
            local dx = heightmap[y][x+1] - heightmap[y][x-1]
            local dy = heightmap[y+1][x] - heightmap[y-1][x]
            local slope = math.sqrt(dx^2 + dy^2)
            local height = heightmap[y][x]
            if slope > 0.3 then
                terrain[y][x] = 'O'  
            elseif height > 0.6 then
                terrain[y][x] = 'Y'  
            elseif height > 0.4 then
                terrain[y][x] = 'S'  
            elseif height > 0.3 then
                terrain[y][x] = 'X'  
            else
                terrain[y][x] = '-'  
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