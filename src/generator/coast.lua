-- Coastline generator using midpoint displacement algorithm
-- Research: Fractal terrain generation with diamond-square algorithm variant

local coast = {}

function coast.generate(width, height, params)
    params = params or {}
    local roughness = params.roughness or 0.7
    local iterations = params.iterations or 7
    local sea_level = params.sea_level or 0.35
    local seed = params.seed or os.time()

    math.randomseed(seed)
    local map_size = 2^iterations + 1
    local height_map = {}
    height_map[1] = 0.5
    height_map[map_size] = 0.5

    local function displace(start, finish, range, depth)
        if depth <= 0 then return end
        local mid = math.floor((start + finish) / 2)
        height_map[mid] = (height_map[start] + height_map[finish]) / 2
        height_map[mid] = height_map[mid] + (math.random() * 2 - 1) * range
        local new_range = range * 2^(-roughness)
        displace(start, mid, new_range, depth - 1)
        displace(mid, finish, new_range, depth - 1)
    end

    displace(1, map_size, 1.0, iterations)

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

            if elevation < sea_level - 0.1 then
                map_data[y][x] = 'B'
            elseif elevation < sea_level then
                map_data[y][x] = 'W'
            elseif elevation < sea_level + 0.15 then
                map_data[y][x] = 'O'
            else
                map_data[y][x] = 'G'
            end
        end
    end

    return map_data
end

return coast
