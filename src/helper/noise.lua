local noise = {}

function noise.octave_noise(x, y, octaves, persistence)
    local total = 0
    local frequency = 1
    local amplitude = 1
    local maxValue = 0
    for _ = 1, octaves do
        total = total + love.math.noise(x * frequency, y * frequency) * amplitude
        maxValue = maxValue + amplitude
        amplitude = amplitude * persistence
        frequency = frequency * 2
    end
    return total / maxValue
end

function noise.radial_noise(centerX, centerY, x, y, scale)
    local dx = x - centerX
    local dy = y - centerY
    local distance = math.sqrt(dx^2 + dy^2)
    return love.math.noise(distance * scale)
end

return noise