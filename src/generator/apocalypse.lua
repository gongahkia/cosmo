-- Post-apocalyptic wasteland generator
-- Research: Urban decay simulation and radiation diffusion

local math_utils = require("helper.math")

local apocalypse = {}

function apocalypse.generate(width, height, params)
    params = params or {}
    local destruction_year = params.destruction_year or 2145
    local radiation_level = params.radiation_level or 4
    local loot_density = params.loot_density or 0.2

    local map = {}
    local main_road_interval = 10

    for y = 1, height do
        map[y] = {}
        for x = 1, width do
            if x % main_road_interval == 0 or y % main_road_interval == 0 then
                map[y][x] = 'J'
            else
                map[y][x] = love.math.random() < 0.7 and 'C' or 'U'
            end
        end
    end

    local bomb_radius = 3
    local bomb_spacing = 15
    local bomb_points = {}

    for y = 1, height, bomb_spacing do
        for x = 1, width, bomb_spacing do
            if love.math.random() < 0.7 then
                table.insert(bomb_points, {
                    x = x + love.math.random(-5, 5),
                    y = y + love.math.random(-5, 5)
                })
            end
        end
    end

    for _, bomb in ipairs(bomb_points) do
        for dy = -bomb_radius*2, bomb_radius*2 do
            for dx = -bomb_radius*2, bomb_radius*2 do
                local dist = math.sqrt(dx^2 + dy^2)
                local nx = math_utils.clamp(bomb.x + dx, 1, width)
                local ny = math_utils.clamp(bomb.y + dy, 1, height)
                if dist < bomb_radius then
                    map[ny][nx] = 'Q'
                elseif dist < bomb_radius*2 then
                    map[ny][nx] = 'X'
                end
            end
        end
    end

    local radiation_map = {}
    for _ = 1, radiation_level do
        local wx = love.math.random(width)
        local wy = love.math.random(height)
        for _ = 1, 100 do
            wx = wx + love.math.random(-1, 1)
            wy = wy + love.math.random(-1, 1)
            if wx >= 1 and wx <= width and wy >= 1 and wy <= height then
                for dy = -2, 2 do
                    for dx = -2, 2 do
                        local nx = math_utils.clamp(wx + dx, 1, width)
                        local ny = math_utils.clamp(wy + dy, 1, height)
                        radiation_map[ny] = radiation_map[ny] or {}
                        radiation_map[ny][nx] = true
                    end
                end
            end
        end
    end

    for y = 1, height do
        for x = 1, width do
            if radiation_map[y] and radiation_map[y][x] then
                map[y][x] = 'P'
            elseif map[y][x] == 'X' and love.math.random() < loot_density then
                map[y][x] = 'K'
            end
        end
    end

    for y = 1, height do
        for x = 1, width do
            if map[y][x] == '-' and love.math.random() < 0.1 then
                map[y][x] = love.math.random() < 0.3 and 'Y' or 'F'
            end
        end
    end

    return map
end

return apocalypse
