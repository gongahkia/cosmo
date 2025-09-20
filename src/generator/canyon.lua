local noise = require("helper.noise")

local canyon = {}

function canyon.generate(width, height)
    local terrain = {}

    for y = 1, height do
        terrain[y] = {}
    end

    local main_channel_y = height / 2
    local tributaries = {}
    for i = 1, math.random(2, 4) do
        tributaries[i] = {
            start_x = math.random(1, width),
            start_y = math.random(1, height),
            direction = math.random() * math.pi * 2
        }
    end

    local elevation_map = {}
    for y = 1, height do
        elevation_map[y] = {}
        for x = 1, width do
            local base_elevation = noise.octave_noise(x/40, y/40, 3, 0.5) * 0.5 + 0.5

            local distance_to_center = math.abs(y - main_channel_y) / (height/2)
            local channel_depth = math.max(0, 1 - distance_to_center * 2) * 0.7

            local channel_curve = math.sin(x/15) * 5
            local curved_distance = math.abs(y - (main_channel_y + channel_curve))
            local main_erosion = math.max(0, 1 - curved_distance / 20) * 0.8

            elevation_map[y][x] = base_elevation - main_erosion

            for _, trib in ipairs(tributaries) do
                local trib_x = trib.start_x + math.cos(trib.direction) * (x - trib.start_x) * 0.3
                local trib_y = trib.start_y + math.sin(trib.direction) * (x - trib.start_x) * 0.3
                local trib_dist = math.sqrt((x - trib_x)^2 + (y - trib_y)^2)
                local trib_erosion = math.max(0, 1 - trib_dist / 8) * 0.4
                elevation_map[y][x] = elevation_map[y][x] - trib_erosion
            end
        end
    end

    for y = 1, height do
        for x = 1, width do
            local elevation = elevation_map[y][x]
            local slope = 0

            if x > 1 and x < width and y > 1 and y < height then
                local dx = elevation_map[y][x+1] - elevation_map[y][x-1]
                local dy = elevation_map[y+1][x] - elevation_map[y-1][x]
                slope = math.sqrt(dx*dx + dy*dy)
            end

            if elevation < 0.1 then
                terrain[y][x] = 'W'
            elseif elevation < 0.2 then
                terrain[y][x] = 'S'
            elseif slope > 0.3 then
                terrain[y][x] = 'R'
            elseif elevation > 0.7 then
                terrain[y][x] = 'M'
            elseif elevation > 0.5 then
                terrain[y][x] = 'X'
            elseif elevation > 0.3 then
                terrain[y][x] = 'O'
            else
                terrain[y][x] = 'D'
            end
        end
    end

    return terrain
end

return canyon