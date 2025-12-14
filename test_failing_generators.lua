-- Test script to check failing generators
-- Run with: lua test_failing_generators.lua

-- Mock love.math for testing outside Love2D
love = {
    math = {
        random = function(...)
            local args = {...}
            if #args == 0 then
                return math.random()
            elseif #args == 1 then
                return math.random(args[1])
            else
                return math.random(args[1], args[2])
            end
        end,
        noise = function(x, y)
            -- Simple 2D Perlin-like noise approximation
            local function fade(t) return t * t * t * (t * (t * 6 - 15) + 10) end
            local function lerp(t, a, b) return a + t * (b - a) end

            local xi = math.floor(x) % 256
            local yi = math.floor(y) % 256
            local xf = x - math.floor(x)
            local yf = y - math.floor(y)

            local u = fade(xf)
            local v = fade(yf)

            -- Simple hash function
            local function hash(i, j)
                return ((i * 374761393 + j * 668265263) % 4294967296) / 4294967296
            end

            local aa = hash(xi, yi)
            local ab = hash(xi, yi + 1)
            local ba = hash(xi + 1, yi)
            local bb = hash(xi + 1, yi + 1)

            local x1 = lerp(u, aa, ba)
            local x2 = lerp(u, ab, bb)

            return lerp(v, x1, x2)
        end,
        setRandomSeed = function(seed)
            math.randomseed(seed)
        end
    }
}

-- Add package path
package.path = package.path .. ";src/?.lua;src/helper/?.lua;src/generator/?.lua"

local failing_generators = {
    "urban",
    "river",
    "temple",
    "tundra",
    "mega",
    "farm",
    "apocalypse"
}

print("Testing failing generators...")
print(string.rep("=", 50))

for _, gen_name in ipairs(failing_generators) do
    print("\nTesting: " .. gen_name)

    local success, result = pcall(function()
        local gen = require(gen_name)
        love.math.setRandomSeed(12345)
        math.randomseed(12345)
        local map = gen.generate(20, 15)  -- Small test size

        -- Verify map structure
        assert(type(map) == "table", "Map is not a table")
        assert(#map == 15, "Map height is incorrect")
        assert(#map[1] == 20, "Map width is incorrect")

        -- Count unique characters
        local chars = {}
        for y = 1, #map do
            for x = 1, #map[y] do
                chars[map[y][x]] = true
            end
        end

        local char_count = 0
        for _ in pairs(chars) do
            char_count = char_count + 1
        end

        return "✓ SUCCESS - Generated " .. char_count .. " unique terrain types"
    end)

    if success then
        print("  " .. result)
    else
        print("  ✗ FAILED - " .. tostring(result))
    end
end

print("\n" .. string.rep("=", 50))
print("Test complete!")
