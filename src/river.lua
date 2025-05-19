function create_basin(width, height, params)
    params = params or {}
    local river_count = params.river_count or 5
    local sediment_load = params.sediment_load or 0.4
    local delta_size = params.delta_size or 0.3
    local heightmap = {}
    for y = 1, height do
        heightmap[y] = {}
        for x = 1, width do
            local elevation = love.math.noise(x/100, y/100) * 0.6 +
                            love.math.noise(x/30, y/30) * 0.3 +
                            love.math.noise(x/10, y/10) * 0.1
            heightmap[y][x] = elevation
        end
    end
    local accumulation = {}
    for y = 1, height do
        accumulation[y] = {}
        for x = 1, width do
            accumulation[y][x] = 1
        end
    end
    for y = 1, height do
        for x = 1, width do
            local current_x, current_y = x, y
            for _ = 1, 100 do  
                local lowest = {elevation = heightmap[current_y][current_x]}
                local next_x, next_y = current_x, current_y
                for dy = -1, 1 do
                    for dx = -1, 1 do
                        if dx ~= 0 or dy ~= 0 then
                            local nx = math.clamp(current_x + dx, 1, width)
                            local ny = math.clamp(current_y + dy, 1, height)
                            if heightmap[ny][nx] < lowest.elevation then
                                lowest = {x = nx, y = ny, elevation = heightmap[ny][nx]}
                            end
                        end
                    end
                end
                if lowest.x and lowest.y then
                    accumulation[lowest.y][lowest.x] = accumulation[lowest.y][lowest.x] + 1
                    current_x, current_y = lowest.x, lowest.y
                else
                    break
                end
            end
        end
    end
    local rivers = {}
    for _ = 1, river_count do
        local source = {x = 1, y = 1}
        for y = 1, height do
            for x = 1, width do
                if accumulation[y][x] > accumulation[source.y][source.x] then
                    source = {x = x, y = y}
                end
            end
        end
        local current = {x = source.x, y = source.y}
        local river_path = {}
        local meander_phase = love.math.random() * math.pi * 2
        while true do
            table.insert(river_path, {x = current.x, y = current.y})
            local meander_offset = math.sin(meander_phase) * 2
            meander_phase = meander_phase + 0.3
            local best = {elevation = math.huge}
            for dx = -1, 1 do
                for dy = 1, -1, -1 do  
                    local nx = math.clamp(current.x + dx + meander_offset, 1, width)
                    local ny = math.clamp(current.y + dy, 1, height)
                    if heightmap[ny][nx] < best.elevation then
                        best = {x = nx, y = ny, elevation = heightmap[ny][nx]}
                    end
                end
            end
            if best.x == current.x and best.y == current.y then break end
            current = {x = best.x, y = best.y}
            if current.x == 1 or current.x == width or 
               current.y == 1 or current.y == height then
                break
            end
        end
        for _, pos in ipairs(river_path) do
            rivers[pos.y] = rivers[pos.y] or {}
            rivers[pos.y][pos.x] = true
        end
    end
    local map = {}
    for y = 1, height do
        map[y] = {}
        for x = 1, width do
            if rivers[y] and rivers[y][x] then
                map[y][x] = 'W'
                for dy = -1, 1 do
                    for dx = -1, 1 do
                        local nx = math.clamp(x + dx, 1, width)
                        local ny = math.clamp(y + dy, 1, height)
                        heightmap[ny][nx] = heightmap[ny][nx] - sediment_load * 0.1
                    end
                end
            else
                local elevation = heightmap[y][x]
                if elevation < 0.3 then
                    map[y][x] = 'B'  
                elseif elevation < 0.4 then
                    map[y][x] = 'W'  
                elseif elevation < 0.5 then
                    map[y][x] = 'S'  
                elseif elevation < 0.7 then
                    map[y][x] = 'D'  
                else
                    map[y][x] = 'R'  
                end
            end
        end
    end
    for _, path in ipairs(rivers) do
        local mouth = path[#path]
        local delta_radius = math.floor(width * delta_size)
        for dy = -delta_radius, delta_radius do
            for dx = -delta_radius, delta_radius do
                local dist = math.sqrt(dx^2 + dy^2)
                if dist <= delta_radius then
                    local x = mouth.x + dx
                    local y = mouth.y + dy
                    if x >= 1 and x <= width and y >= 1 and y <= height then
                        local falloff = 1 - (dist / delta_radius)
                        if love.math.random() < falloff then
                            map[y][x] = 'S'
                        end
                    end
                end
            end
        end
    end
    local lines = {}
    for y = 1, height do
        lines[y] = table.concat(map[y])
    end
    local success, message = pcall(function()
        love.filesystem.write("map.txt", table.concat(lines, "\n"))
    end)
    return success, message
end