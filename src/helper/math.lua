-- Shared math utility functions for terrain generation
local math_utils = {}

-- Clamp a value between min and max
function math_utils.clamp(x, min, max)
    return math.max(min, math.min(max, x))
end

-- Linear interpolation between a and b by factor t (0 to 1)
function math_utils.lerp(a, b, t)
    return a + (b - a) * t
end

-- Smooth interpolation (cubic Hermite) between 0 and 1
function math_utils.smoothstep(t)
    t = math_utils.clamp(t, 0, 1)
    return t * t * (3 - 2 * t)
end

-- Remap value from one range to another
function math_utils.remap(value, oldMin, oldMax, newMin, newMax)
    local t = (value - oldMin) / (oldMax - oldMin)
    return math_utils.lerp(newMin, newMax, t)
end

-- Normalize value to 0-1 range
function math_utils.normalize(value, min, max)
    return (value - min) / (max - min)
end

-- Round to nearest integer
function math_utils.round(x)
    return math.floor(x + 0.5)
end

-- Sign function (-1, 0, or 1)
function math_utils.sign(x)
    if x > 0 then return 1 end
    if x < 0 then return -1 end
    return 0
end

-- Distance between two points
function math_utils.distance(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math.sqrt(dx * dx + dy * dy)
end

-- Manhattan distance
function math_utils.manhattan_distance(x1, y1, x2, y2)
    return math.abs(x2 - x1) + math.abs(y2 - y1)
end

return math_utils
