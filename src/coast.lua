function generate_coastline()
    local config = {
        roughness = 0.7,
        iterations = 7,
        sea_level = 0.35,
        seed = os.time()
    }
    math.randomseed(config.seed)
    local map_size = 2^config.iterations + 1
    local height_map = {}
    height_map[1] = 0.5
    height_map[map_size] = 0.5
    local function displace(start, finish, range, depth)
        if depth <= 0 then return end
        local mid = math.floor((start + finish) / 2)
        height_map[mid] = (height_map[start] + height_map[finish]) / 2
        height_map[mid] = height_map[mid] + (math.random() * 2 - 1) * range
        local new_range = range * 2^(-config.roughness)
        displace(start, mid, new_range, depth - 1)
        displace(mid, finish, new_range, depth - 1)
    end
    displace(1, map_size, 1.0, config.iterations)
    local min_h, max_h = math.huge, -math.huge
    for _, h in pairs(height_map) do
        min_h = math.min(min_h, h)
        max_h = math.max(max_h, h)
    end
    for i = 1, map_size do
        height_map[i] = (height_map[i] - min_h) / (max_h - min_h)
    end
    local map_data = {}
    for y = 1, map_size do
        map_data[y] = {}
        for x = 1, map_size do
            local dx = (x - map_size/2) / (map_size/2)
            local dy = (y - map_size/2) / (map_size/2)
            local radial = math.sqrt(dx^2 + dy^2) * 1.2
            local elevation = height_map[x] - radial
            if elevation < config.sea_level - 0.1 then
                map_data[y][x] = 'B'  
            elseif elevation < config.sea_level then
                map_data[y][x] = 'W'
            elseif elevation < config.sea_level + 0.15 then
                map_data[y][x] = 'O'  
            else
                map_data[y][x] = 'G'  
            end
        end
    end
    local output = ""
    for y = 1, map_size do
        output = output .. table.concat(map_data[y]) .. "\n"
    end
    love.filesystem.write("map.txt", output)
    return map_data
end