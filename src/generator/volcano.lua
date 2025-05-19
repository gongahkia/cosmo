function generate_volcanic_archipelago(width, height)
    local base_scale = 50
    local magma_channels = 4
    local lava_flow = 0.1
    local elevation = {}
    local heat = {}
    local moisture = {}
    for octave = 0, magma_channels - 1 do
        local frequency = 2 ^ octave
        local amplitude = 0.5 ^ octave
        for y = 1, height do
            elevation[y] = elevation[y] or {}
            heat[y] = heat[y] or {}
            moisture[y] = moisture[y] or {}
            for x = 1, width do
                local nx = x / base_scale * frequency
                local ny = y / base_scale * frequency
                elevation[y][x] = (elevation[y][x] or 0) + amplitude * love.math.noise(nx, ny, octave)
                heat[y][x] = (heat[y][x] or 0) + amplitude * love.math.noise(nx + 1000, ny, octave + 10)
                moisture[y][x] = (moisture[y][x] or 0) + amplitude * love.math.noise(nx, ny + 1000, octave + 20)
            end
        end
    end
    local center_x, center_y = width/2, height/2
    local max_radius = math.min(center_x, center_y) * 0.9
    for y = 1, height do
        for x = 1, width do
            local dx = x - center_x
            local dy = y - center_y
            local dist = math.sqrt(dx*dx + dy*dy)
            local falloff = math.max(0, 1 - dist/max_radius)
            elevation[y][x] = elevation[y][x] * falloff
            heat[y][x] = heat[y][x] * falloff
        end
    end
    local caldera_radius = max_radius * 0.3
    for y = 1, height do
        for x = 1, width do
            local dx = x - center_x
            local dy = y - center_y
            local dist = math.sqrt(dx*dx + dy*dy) / caldera_radius
            if dist < 1 then
                local sigmoid = 1 / (1 + math.exp(10 * (dist - 0.5)))
                elevation[y][x] = elevation[y][x] * sigmoid
                heat[y][x] = heat[y][x] + (1 - sigmoid) * lava_flow
            end
        end
    end
    local map = {}
    for y = 1, height do
        map[y] = ""
        for x = 1, width do
            local e = elevation[y][x]
            local h = heat[y][x]
            local m = moisture[y][x]
            local char = '-'
            if e < 0.1 then
                char = 'B' 
            elseif e < 0.2 then
                char = 'L' 
            elseif e < 0.3 then
                char = 'S' 
            elseif e < 0.5 then
                if m > 0.6 then char = 'V'
                else char = 'G' end 
            elseif e < 0.7 then
                char = 'R' 
            else
                if h > 0.6 then char = 'Q' 
                else char = 'M' end 
            end
            map[y] = map[y] .. char
        end
    end
    local success, message = pcall(function()
        local content = table.concat(map, "\n")
        love.filesystem.write("map.txt", content)
    end)
    return success, message
end