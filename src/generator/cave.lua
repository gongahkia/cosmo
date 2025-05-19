function generate_cave_network(width, height, params)
    params = params or {}
    local initial_density = params.initial_density or 0.4
    local erosion_passes = params.erosion_passes or 5
    local mineral_veins = params.mineral_veins or 5
    local grid = {}
    for y = 1, height do
        grid[y] = {}
        for x = 1, width do
            grid[y][x] = love.math.random() < initial_density and 'U' or '-'
        end
    end
    local function count_neighbors(x, y)
        local count = 0
        for dy = -1, 1 do
            for dx = -1, 1 do
                local nx = math.clamp(x + dx, 1, width)
                local ny = math.clamp(y + dy, 1, height)
                if grid[ny][nx] == 'U' then count = count + 1 end
            end
        end
        return count
    end
    for _ = 1, erosion_passes do
        local new_grid = {}
        for y = 1, height do
            new_grid[y] = {}
            for x = 1, width do
                local neighbors = count_neighbors(x, y)
                new_grid[y][x] = (neighbors >= 4) and 'U' or '-'
            end
        end
        grid = new_grid
    end
    local function find_caverns()
        local caverns = {}
        local visited = {}
        for y = 1, height do
            for x = 1, width do
                if grid[y][x] == '-' and not visited[y..x] then
                    local queue = {{x=x, y=y}}
                    local cavern = {}
                    visited[y..x] = true
                    while #queue > 0 do
                        local pos = table.remove(queue, 1)
                        table.insert(cavern, pos)
                        for dy = -1, 1 do
                            for dx = -1, 1 do
                                local nx = pos.x + dx
                                local ny = pos.y + dy
                                if nx >= 1 and nx <= width and ny >= 1 and ny <= height then
                                    if grid[ny][nx] == '-' and not visited[ny..nx] then
                                        visited[ny..nx] = true
                                        table.insert(queue, {x=nx, y=ny})
                                    end
                                end
                            end
                        end
                    end
                    table.insert(caverns, cavern)
                end
            end
        end
        return caverns
    end
    local caverns = find_caverns()
    table.sort(caverns, function(a,b) return #a > #b end)
    for i = 1, #caverns-1 do
        local start = caverns[i][love.math.random(#caverns[i])]
        local target = caverns[i+1][love.math.random(#caverns[i+1])]
        local x, y = start.x, start.y
        while x ~= target.x or y ~= target.y do
            x = x + (target.x > x and 1 or target.x < x and -1 or 0)
            y = y + (target.y > y and 1 or target.y < y and -1 or 0)
            grid[y][x] = '-'
        end
    end
    for _ = 1, mineral_veins do
        local vein_x = love.math.random(10, width-10)
        local vein_y = love.math.random(10, height-10)
        for dy = -3, 3 do
            for dx = -3, 3 do
                if love.math.random() < 0.4 then
                    local x = vein_x + dx
                    local y = vein_y + dy
                    if x >= 1 and x <= width and y >= 1 and y <= height then
                        grid[y][x] = 'T'
                    end
                end
            end
        end
    end
    local map = {}
    for y = 1, height do
        map[y] = table.concat(grid[y])
    end
    local success, message = pcall(function()
        love.filesystem.write("map.txt", table.concat(map, "\n"))
    end)
    return success, message
end