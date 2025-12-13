-- Desert terrain generator using aeolian (wind-driven) dune formation models
-- Research: Ribeiro Parteli, E. J. (2022). A model for Aeolian-driven land surface processes

local desert = {}

function desert.generate(width, height, params)
    params = params or {}
    local wind_dir = math.rad(params.wind_direction or 30)
    local sand_mobility = params.sand_mobility or 0.7
    local dune_spacing = params.dune_spacing or 10

    local wind_vector = {x = math.cos(wind_dir), y = math.sin(wind_dir)}
    local heightmap = {}
    local terrain = {}

    -- Initialize terrain and heightmap
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

    -- Apply wind-driven dune shaping
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

    -- Convert heightmap to terrain characters
    for y = 2, height-1 do
        for x = 2, width-1 do
            local dx = heightmap[y][x+1] - heightmap[y][x-1]
            local dy = heightmap[y+1][x] - heightmap[y-1][x]
            local slope = math.sqrt(dx^2 + dy^2)
            local height_value = heightmap[y][x]

            if slope > 0.3 then
                terrain[y][x] = 'O'  -- steep dune faces (orange sand)
            elseif height_value > 0.6 then
                terrain[y][x] = 'Y'  -- high dunes (dry grass color)
            elseif height_value > 0.4 then
                terrain[y][x] = 'S'  -- medium dunes (sand)
            elseif height_value > 0.3 then
                terrain[y][x] = 'X'  -- low areas (gravel)
            else
                terrain[y][x] = '-'  -- empty/flat areas
            end
        end
    end

    -- Fill edges
    for y = 1, height do
        terrain[y][1] = terrain[y][2] or 'S'
        terrain[y][width] = terrain[y][width-1] or 'S'
    end
    for x = 1, width do
        terrain[1][x] = terrain[2][x] or 'S'
        terrain[height][x] = terrain[height-1][x] or 'S'
    end

    return terrain
end

return desert
