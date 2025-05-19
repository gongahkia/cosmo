function generate_frost_patterns(width, height, params)
    params = params or {}
    local permafrost_depth = params.permafrost_depth or 0.9
    local wind_dir = math.rad(params.wind_direction or 270)
    local snow_cover = params.snow_cover or 0.6
    local Du = 0.16 
    local Dv = 0.08 
    local F = 0.04    
    local K = 0.06    
    local U, V = {}, {}
    for y = 1, height do
        U[y] = {}
        V[y] = {}
        for x = 1, width do
            U[y][x] = 1.0
            V[y][x] = love.math.random() < 0.2 and 0.5 or 0.0
        end
    end
    for _ = 1, 200 do  
        local newU, newV = {}, {}
        for y = 1, height do
            newU[y] = {}
            newV[y] = {}
            for x = 1, width do
                local lu = 0.0
                local lv = 0.0
                for dy = -1, 1 do
                    for dx = -1, 1 do
                        local nx = math.clamp(x + dx, 1, width)
                        local ny = math.clamp(y + dy, 1, height)
                        lu = lu + U[ny][nx] * (dx == 0 and dy == 0 and -1 or 0.2)
                        lv = lv + V[ny][nx] * (dx == 0 and dy == 0 and -1 or 0.2)
                    end
                end
                local reaction = U[y][x] * V[y][x] * V[y][x]
                newU[y][x] = U[y][x] + Du * lu - reaction + F * (1 - U[y][x])
                newV[y][x] = V[y][x] + Dv * lv + reaction - (F + K) * V[y][x]
            end
        end
        U, V = newU, newV
    end
    local map = {}
    for y = 1, height do
        map[y] = {}
        for x = 1, width do
            local pattern = V[y][x] * permafrost_depth
            if pattern > 0.3 then
                map[y][x] = 'X'  
            else
                map[y][x] = 'N'  
            end
        end
    end
    for y = 2, height-1 do
        for x = 2, width-1 do
            if map[y][x] == 'X' then
                local count = 0
                for dy = -1, 1 do
                    for dx = -1, 1 do
                        if map[y+dy][x+dx] == 'X' then count = count + 1 end
                    end
                end
                if count <= 4 then  
                    map[y][x] = 'Z'  
                end
            end
        end
    end
    local wind_x = math.cos(wind_dir)
    local wind_y = math.sin(wind_dir)
    for y = 1, height do
        for x = 1, width do
            if map[y][x] == 'N' then
                local nx = x + wind_x * 5
                local ny = y + wind_y * 5
                local snow = love.math.noise(nx/20, ny/20)
                if snow > snow_cover then
                    map[y][x] = 'A'  
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