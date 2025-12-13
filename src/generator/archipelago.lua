local noise = require("helper.noise")

local archipelago = {}

function archipelago.generate(width, height, params)
    params = params or {}
    local num_islands = params.num_islands or math.random(5, 12)
    local min_island_size = params.min_island_size or 8
    local max_island_size = params.max_island_size or 25

    local terrain = {}

    for y = 1, height do
        terrain[y] = {}
        for x = 1, width do
            terrain[y][x] = 'B'
        end
    end

    local islands = {}

    for i = 1, num_islands do
        islands[i] = {
            x = math.random(width * 0.1, width * 0.9),
            y = math.random(height * 0.1, height * 0.9),
            size = math.random(min_island_size, max_island_size),
            height_scale = math.random(0.4, 0.8)
        }
    end

    for y = 1, height do
        for x = 1, width do
            local max_elevation = 0
            local closest_island_dist = math.huge

            for _, island in ipairs(islands) do
                local dx = x - island.x
                local dy = y - island.y
                local distance = math.sqrt(dx*dx + dy*dy)
                closest_island_dist = math.min(closest_island_dist, distance)

                if distance <= island.size then
                    local normalized_dist = distance / island.size
                    local island_elevation = (1 - normalized_dist) * island.height_scale

                    local noise_detail = noise.octave_noise(x/8, y/8, 3, 0.5) * 0.2
                    island_elevation = island_elevation + noise_detail

                    max_elevation = math.max(max_elevation, island_elevation)
                end
            end

            local shallow_water_radius = 5
            local is_shallow = closest_island_dist <= shallow_water_radius and max_elevation <= 0

            if max_elevation > 0.6 then
                terrain[y][x] = 'M'
            elseif max_elevation > 0.4 then
                terrain[y][x] = 'R'
            elseif max_elevation > 0.2 then
                terrain[y][x] = 'F'
            elseif max_elevation > 0.1 then
                terrain[y][x] = 'O'
            elseif max_elevation > 0.05 then
                terrain[y][x] = 'S'
            elseif is_shallow then
                terrain[y][x] = 'W'
            else
                terrain[y][x] = 'B'
            end
        end
    end

    local num_atolls = math.random(1, 3)
    for i = 1, num_atolls do
        local center_x = math.random(width * 0.2, width * 0.8)
        local center_y = math.random(height * 0.2, height * 0.8)
        local outer_radius = math.random(12, 20)
        local inner_radius = outer_radius * 0.6

        for y = 1, height do
            for x = 1, width do
                local dx = x - center_x
                local dy = y - center_y
                local distance = math.sqrt(dx*dx + dy*dy)

                if distance <= outer_radius and distance >= inner_radius then
                    if math.random() < 0.7 then
                        terrain[y][x] = 'O'
                    end
                elseif distance < inner_radius then
                    terrain[y][x] = 'W'
                end
            end
        end
    end

    return terrain
end

return archipelago