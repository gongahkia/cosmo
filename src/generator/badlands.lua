local noise = require("helper.noise")

local badlands = {}

function badlands.generate(width, height, params)
    params = params or {}
    local mesa_count = params.mesa_count or math.random(4, 8)
    local erosion_intensity = params.erosion_intensity or 0.3
    local stratification = params.stratification or 0.05

    local terrain = {}

    math.randomseed(os.time() * math.random(1, 9999))

    for y = 1, height do
        terrain[y] = {}
    end

    local mesas = {}

    for i = 1, mesa_count do
        mesas[i] = {
            x = math.random(width * 0.1, width * 0.9),
            y = math.random(height * 0.1, height * 0.9),
            width = math.random(15, 30),
            height = math.random(10, 20),
            elevation = math.random(0.6, 0.9)
        }
    end

    for y = 1, height do
        for x = 1, width do
            local base_elevation = noise.octave_noise(x/50, y/50, 2, 0.4) * 0.3 + 0.2

            local strat_pattern = math.sin(base_elevation * 20) * stratification
            base_elevation = base_elevation + strat_pattern

            local erosion_noise = noise.octave_noise(x/15, y/15, 4, 0.6) * erosion_intensity
            base_elevation = base_elevation + erosion_noise

            for _, mesa in ipairs(mesas) do
                local dx = math.abs(x - mesa.x)
                local dy = math.abs(y - mesa.y)

                if dx <= mesa.width/2 and dy <= mesa.height/2 then
                    local edge_dist_x = math.min(dx, mesa.width/2 - dx)
                    local edge_dist_y = math.min(dy, mesa.height/2 - dy)
                    local edge_dist = math.min(edge_dist_x, edge_dist_y)

                    local mesa_noise = noise.octave_noise(x/10, y/10, 2, 0.5) * 0.1
                    local mesa_elevation = mesa.elevation + mesa_noise

                    if edge_dist > 2 then
                        base_elevation = math.max(base_elevation, mesa_elevation)
                    else
                        local cliff_factor = edge_dist / 2
                        base_elevation = math.max(base_elevation,
                            base_elevation + (mesa_elevation - base_elevation) * cliff_factor)
                    end
                end
            end

            local arroyo_noise = math.abs(noise.octave_noise(x/8, y/25, 1, 1))
            if arroyo_noise < 0.1 then
                base_elevation = base_elevation * 0.3
            end

            if base_elevation > 0.7 then
                terrain[y][x] = 'R'
            elseif base_elevation > 0.5 then
                terrain[y][x] = 'K'
            elseif base_elevation > 0.35 then
                terrain[y][x] = 'O'
            elseif base_elevation > 0.25 then
                terrain[y][x] = 'X'
            elseif base_elevation > 0.15 then
                terrain[y][x] = 'D'
            elseif base_elevation > 0.05 then
                terrain[y][x] = 'S'
            else
                terrain[y][x] = 'W'
            end
        end
    end

    return terrain
end

return badlands