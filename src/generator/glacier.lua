-- Glacier valley generator with erosion and moraine deposition
-- Research: Glacial geomorphology and ice flow dynamics

local glacier = {}

function glacier.generate(width, height, params)
    params = params or {}
    local ice_thickness = params.ice_thickness or 30
    local abrasion_rate = params.abrasion_rate or 0.05
    local terminus = params.terminus or {x = width, y = math.floor(height/2)}

    local heightmap = {}
    local glacier_map = {}
    local sediment = {}

    for y = 1, height do
        heightmap[y] = {}
        glacier_map[y] = {}
        sediment[y] = {}
        for x = 1, width do
            local elevation = 0
            local freq = 1
            local amp = 1
            for _ = 1, 4 do
                elevation = elevation + love.math.noise(x*freq/50, y*freq/50) * amp
                freq = freq * 2
                amp = amp * 0.5
            end
            heightmap[y][x] = elevation * 2
            glacier_map[y][x] = 0
            sediment[y][x] = 0
        end
    end

    local origin = {x = 1, y = 1}
    for y = 1, height do
        for x = 1, math.floor(width*0.2) do
            if heightmap[y][x] > heightmap[origin.y][origin.x] then
                origin = {x = x, y = y}
            end
        end
    end

    local ice_remaining = ice_thickness
    local current_pos = origin
    local path = {}
    local steps = 0

    while ice_remaining > 0 and steps < 1000 do
        table.insert(path, current_pos)
        glacier_map[current_pos.y][current_pos.x] = glacier_map[current_pos.y][current_pos.x] + 0.1

        local neighbors = {}
        local best_score = -math.huge

        for dy = -1, 1 do
            for dx = -1, 1 do
                if dy ~= 0 or dx ~= 0 then
                    local nx = current_pos.x + dx
                    local ny = current_pos.y + dy
                    if nx >= 1 and nx <= width and ny >= 1 and ny <= height then
                        local slope = (heightmap[current_pos.y][current_pos.x] -
                                      heightmap[ny][nx]) / math.sqrt(dx^2 + dy^2)
                        local ice_influence = glacier_map[ny][nx] * 0.3
                        local score = slope + ice_influence
                        if score > best_score then
                            best_score = score
                            neighbors = {{x = nx, y = ny}}
                        elseif score == best_score then
                            table.insert(neighbors, {x = nx, y = ny})
                        end
                    end
                end
            end
        end

        if #neighbors == 0 then break end
        current_pos = neighbors[math.random(#neighbors)]
        ice_remaining = ice_remaining - 0.1
        steps = steps + 1

        if math.abs(current_pos.x - terminus.x) < 3 and
           math.abs(current_pos.y - terminus.y) < 3 then
            break
        end
    end

    for _, pos in ipairs(path) do
        local valley_width = ice_thickness / 2
        for dy = -valley_width, valley_width do
            for dx = -valley_width, valley_width do
                local dist = math.sqrt(dx^2 + dy^2)
                local nx = pos.x + dx
                local ny = pos.y + dy
                if nx >= 1 and nx <= width and ny >= 1 and ny <= height then
                    local erosion = abrasion_rate *
                                  math.max(0, 1 - (dist/(valley_width*0.8))^2)
                    heightmap[ny][nx] = heightmap[ny][nx] - erosion
                    sediment[ny][nx] = sediment[ny][nx] + erosion * 0.5
                end
            end
        end
    end

    local moraine_radius = ice_thickness * 0.7
    for dy = -moraine_radius, moraine_radius do
        for dx = -moraine_radius, moraine_radius do
            local nx = terminus.x + dx
            local ny = terminus.y + dy
            if nx >= 1 and nx <= width and ny >= 1 and ny <= height then
                local dist = math.sqrt(dx^2 + dy^2)
                local falloff = 1 - math.min(1, dist/moraine_radius)
                heightmap[ny][nx] = heightmap[ny][nx] + sediment[ny][nx] * falloff
            end
        end
    end

    local map = {}
    for y = 1, height do
        map[y] = {}
        for x = 1, width do
            local elevation = heightmap[y][x]
            local sed = sediment[y][x]
            local ice = glacier_map[y][x]

            if ice > 0.2 then
                map[y][x] = 'Z'
            elseif elevation > 1.5 then
                map[y][x] = 'A'
            elseif elevation > 1.2 then
                map[y][x] = 'M'
            elseif elevation > 0.8 then
                map[y][x] = 'R'
            elseif elevation > 0.6 then
                if sed > 0.3 then
                    map[y][x] = 'K'
                else
                    map[y][x] = 'X'
                end
            elseif elevation > 0.4 then
                map[y][x] = 'D'
            elseif elevation > 0.3 then
                map[y][x] = 'H'
            else
                map[y][x] = 'N'
            end
        end
    end

    return map
end

return glacier
