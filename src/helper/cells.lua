local cells = {}
local math_utils = require("helper.math")

function cells.run_cellular_automaton(grid, iterations, birth, survive)
    local width = #grid[1]
    local height = #grid
    for _ = 1, iterations do
        local newGrid = {}
        for y = 1, height do
            newGrid[y] = {}
            for x = 1, width do
                local count = cells.count_neighbors(grid, x, y)
                newGrid[y][x] = (grid[y][x] == 1 and survive[count]) or birth[count]
            end
        end
        grid = newGrid
    end
    return grid
end

function cells.count_neighbors(grid, x, y)
    local count = 0
    for dy = -1, 1 do
        for dx = -1, 1 do
            local nx = math_utils.clamp(x + dx, 1, #grid[1])
            local ny = math_utils.clamp(y + dy, 1, #grid)
            if not (dx == 0 and dy == 0) then
                count = count + grid[ny][nx]
            end
        end
    end
    return count
end

return cells