local noise = require("helper.noise")

local mountain = {}

function mountain.generate(width, height)
    local terrain = {}

    math.randomseed(os.time() * math.random(1, 9999))

    for y = 1, height do
        terrain[y] = {}
    end

    local peak_count = math.random(3, 7)
    local peaks = {}

    for i = 1, peak_count do
        peaks[i] = {
            x = math.random(width * 0.2, width * 0.8),
            y = math.random(height * 0.2, height * 0.8),
            height = math.random(0.6, 1.0),
            radius = math.random(15, 35)
        }
    end

    for y = 1, height do
        for x = 1, width do
            local elevation = 0
            local base_noise = noise.octave_noise(x/30, y/30, 4, 0.5) * 0.3

            for _, peak in ipairs(peaks) do
                local dx = x - peak.x
                local dy = y - peak.y
                local distance = math.sqrt(dx*dx + dy*dy)
                local influence = math.max(0, 1 - distance / peak.radius)
                elevation = elevation + peak.height * influence * influence
            end

            elevation = elevation + base_noise

            local ridge_noise = math.abs(noise.octave_noise(x/20, y/20, 3, 0.6)) * 0.4
            elevation = elevation + ridge_noise

            if elevation > 0.8 then
                terrain[y][x] = 'A'
            elseif elevation > 0.65 then
                terrain[y][x] = 'M'
            elseif elevation > 0.5 then
                terrain[y][x] = 'R'
            elseif elevation > 0.35 then
                terrain[y][x] = 'X'
            elseif elevation > 0.25 then
                terrain[y][x] = 'T'
            elseif elevation > 0.15 then
                terrain[y][x] = 'F'
            else
                terrain[y][x] = 'G'
            end
        end
    end

    return terrain
end

return mountain