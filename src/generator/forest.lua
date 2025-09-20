local noise = require("helper.noise")
local cells = require("helper.cells")

local forest = {}

function forest.generate(width, height)
    local terrain = {}

    math.randomseed(os.time() + math.random(1000))

    for y = 1, height do
        terrain[y] = {}
    end

    local density_map = {}
    for y = 1, height do
        density_map[y] = {}
        for x = 1, width do
            local base_density = noise.octave_noise(x/25, y/25, 3, 0.6)
            local detail = noise.octave_noise(x/8, y/8, 2, 0.4) * 0.3
            density_map[y][x] = base_density + detail
        end
    end

    local clearings = {}
    for i = 1, math.random(2, 5) do
        clearings[i] = {
            x = math.random(1, width),
            y = math.random(1, height),
            radius = math.random(8, 18)
        }
    end

    local river_y = math.random(height * 0.3, height * 0.7)
    local river_width = 3

    for y = 1, height do
        for x = 1, width do
            local is_river = math.abs(y - river_y) <= river_width and
                           math.abs(y - river_y - math.sin(x/10) * 2) <= river_width

            if is_river then
                if math.abs(y - river_y) <= 1 then
                    terrain[y][x] = 'W'
                else
                    terrain[y][x] = 'S'
                end
            else
                local in_clearing = false
                for _, clearing in ipairs(clearings) do
                    local dx = x - clearing.x
                    local dy = y - clearing.y
                    if dx*dx + dy*dy <= clearing.radius * clearing.radius then
                        in_clearing = true
                        break
                    end
                end

                if in_clearing then
                    terrain[y][x] = 'G'
                else
                    local density = density_map[y][x]
                    if density > 0.6 then
                        terrain[y][x] = 'E'
                    elseif density > 0.4 then
                        terrain[y][x] = 'F'
                    elseif density > 0.2 then
                        terrain[y][x] = 'T'
                    else
                        terrain[y][x] = 'G'
                    end
                end
            end
        end
    end

    return terrain
end

return forest