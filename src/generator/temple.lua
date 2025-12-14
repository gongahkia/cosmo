-- Temple complex generator using Wave Function Collapse
-- Research: WFC algorithm for procedural architecture generation

local temple = {}

function temple.generate(width, height, params)
    params = params or {}
    local complex_size = params.complex_size or 6
    local age = params.age or 1000

    local tiles = {
        ['J'] = {name='wall', rules={north={'J','A'}, south={'J','S'}, east={'J','S'}, west={'J','S'}}},
        ['S'] = {name='floor', rules={north={'J','S','C'}, south={'J','S','C'}, east={'J','S','C'}, west={'J','S','C'}}},
        ['C'] = {name='carving', rules={north={'S'}, south={'S'}, east={'S'}, west={'S'}}},
        ['A'] = {name='altar', rules={north={'S'}, south={'J'}, east={'J'}, west={'J'}}},
        ['F'] = {name='foliage', rules={north={'F','S'}, south={'F','S'}, east={'F','S'}, west={'F','S'}}}
    }

    local grid = {}
    for y = 1, height do
        grid[y] = {}
        for x = 1, width do
            grid[y][x] = {
                possible = {'J','S','C','A','F'},
                entropy = 5,
                collapsed = false
            }
        end
    end

    local center = math.floor(complex_size/2)
    for y = center, height-center do
        for x = center, width-center do
            grid[y][x] = {
                possible = {'S'},
                entropy = 1,
                collapsed = false
            }
        end
    end

    local function collapse()
        local min_entropy = math.huge
        local candidates = {}
        for y = 1, height do
            for x = 1, width do
                if not grid[y][x].collapsed and grid[y][x].entropy < min_entropy then
                    min_entropy = grid[y][x].entropy
                    candidates = {{x=x,y=y}}
                elseif not grid[y][x].collapsed and grid[y][x].entropy == min_entropy then
                    table.insert(candidates, {x=x,y=y})
                end
            end
        end
        if #candidates > 0 then
            local cell = candidates[love.math.random(#candidates)]
            grid[cell.y][cell.x].possible = {grid[cell.y][cell.x].possible[love.math.random(#grid[cell.y][cell.x].possible)]}
            grid[cell.y][cell.x].entropy = 1
            grid[cell.y][cell.x].collapsed = true
            return cell
        end
        return nil
    end

    local function propagate(cell)
        local stack = {cell}
        while #stack > 0 do
            local current = table.remove(stack, 1)
            local current_tile = grid[current.y][current.x].possible[1]

            -- Skip if no valid tile (WFC contradiction)
            if not current_tile or not tiles[current_tile] then
                goto continue
            end

            for _, dir in ipairs({'north','south','east','west'}) do
                local nx, ny = current.x, current.y
                if dir == 'north' then ny = ny - 1
                elseif dir == 'south' then ny = ny + 1
                elseif dir == 'east' then nx = nx + 1
                else nx = nx - 1 end

                if nx >= 1 and nx <= width and ny >= 1 and ny <= height then
                    local neighbor = grid[ny][nx]
                    if not neighbor.collapsed then
                        local valid = {}
                        for _, possible in ipairs(neighbor.possible) do
                            if tiles[current_tile].rules[dir] then
                                for _, allowed in ipairs(tiles[current_tile].rules[dir]) do
                                    if possible == allowed then
                                        table.insert(valid, possible)
                                    end
                                end
                            end
                        end
                        if #valid > 0 and #valid ~= #neighbor.possible then
                            neighbor.possible = valid
                            neighbor.entropy = #valid
                            table.insert(stack, {x=nx, y=ny})
                        elseif #valid == 0 then
                            -- WFC contradiction - reset to default
                            neighbor.possible = {'S'}
                            neighbor.entropy = 1
                        end
                    end
                end
            end

            ::continue::
        end
    end

    while true do
        local cell = collapse()
        if not cell then break end
        propagate(cell)
    end

    local map = {}
    for y = 1, height do
        map[y] = {}
        for x = 1, width do
            local tile = grid[y][x].possible[1]
            if tile == 'J' and love.math.noise(x/10, y/10) > (age/2000) then
                tile = 'X'
            elseif tile == 'S' and love.math.noise(x/8, y/8) > (age/1500) then
                tile = 'F'
            end
            map[y][x] = tile
        end
    end

    return map
end

return temple
