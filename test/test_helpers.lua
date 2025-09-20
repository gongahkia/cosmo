local TestHelpers = {}

function TestHelpers.count_terrain_types(terrain_map)
    local counts = {}

    for y = 1, #terrain_map do
        for x = 1, #terrain_map[y] do
            local char = terrain_map[y][x]
            counts[char] = (counts[char] or 0) + 1
        end
    end

    return counts
end

function TestHelpers.get_terrain_diversity(terrain_map)
    local counts = TestHelpers.count_terrain_types(terrain_map)
    local total_types = 0

    for _ in pairs(counts) do
        total_types = total_types + 1
    end

    return total_types
end

function TestHelpers.validate_terrain_bounds(terrain_map, width, height)
    if #terrain_map ~= height then
        return false, string.format("Expected %d rows, got %d", height, #terrain_map)
    end

    for y = 1, height do
        if #terrain_map[y] ~= width then
            return false, string.format("Row %d: expected %d columns, got %d", y, width, #terrain_map[y])
        end
    end

    return true
end

function TestHelpers.validate_terrain_characters(terrain_map)
    local valid_chars = {
        ['G'] = true, ['W'] = true, ['R'] = true, ['S'] = true, ['D'] = true,
        ['F'] = true, ['T'] = true, ['M'] = true, ['L'] = true, ['B'] = true,
        ['P'] = true, ['C'] = true, ['A'] = true, ['H'] = true, ['V'] = true,
        ['O'] = true, ['E'] = true, ['U'] = true, ['Y'] = true, ['Q'] = true,
        ['N'] = true, ['Z'] = true, ['X'] = true, ['J'] = true, ['K'] = true,
        ['I'] = true, ['-'] = true
    }

    for y = 1, #terrain_map do
        for x = 1, #terrain_map[y] do
            local char = terrain_map[y][x]
            if not valid_chars[char] then
                return false, string.format("Invalid character '%s' at position (%d, %d)", char, x, y)
            end
        end
    end

    return true
end

function TestHelpers.check_terrain_connectivity(terrain_map, terrain_type)
    local height = #terrain_map
    local width = #terrain_map[1]
    local visited = {}
    local groups = 0

    for y = 1, height do
        visited[y] = {}
        for x = 1, width do
            visited[y][x] = false
        end
    end

    local function flood_fill(start_x, start_y)
        local stack = {{start_x, start_y}}

        while #stack > 0 do
            local pos = table.remove(stack)
            local x, y = pos[1], pos[2]

            if x >= 1 and x <= width and y >= 1 and y <= height and
               not visited[y][x] and terrain_map[y][x] == terrain_type then

                visited[y][x] = true

                table.insert(stack, {x+1, y})
                table.insert(stack, {x-1, y})
                table.insert(stack, {x, y+1})
                table.insert(stack, {x, y-1})
            end
        end
    end

    for y = 1, height do
        for x = 1, width do
            if terrain_map[y][x] == terrain_type and not visited[y][x] then
                groups = groups + 1
                flood_fill(x, y)
            end
        end
    end

    return groups
end

function TestHelpers.calculate_terrain_percentage(terrain_map, terrain_type)
    local total = 0
    local count = 0

    for y = 1, #terrain_map do
        for x = 1, #terrain_map[y] do
            total = total + 1
            if terrain_map[y][x] == terrain_type then
                count = count + 1
            end
        end
    end

    return (count / total) * 100
end

function TestHelpers.mock_love_math()
    if not love then
        love = {}
    end
    if not love.math then
        love.math = {}
    end

    math.randomseed(12345)

    love.math.noise = function(x, y)
        local seed = math.floor(x * 12.9898 + y * 78.233) * 43758.5453
        return (math.sin(seed) + 1) / 2
    end
end

return TestHelpers