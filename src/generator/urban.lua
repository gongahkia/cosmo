-- Urban city generator with era-specific architecture
-- Research: Urban planning patterns and procedural city generation

local urban = {}

function urban.generate(width, height, params)
    params = params or {}
    local population = params.population or 2000
    local water_access = params.water_access or true
    local era = params.era or "1920s"

    local density = era == "1920s" and 2.0 or 3.5
    local city_size = math.ceil(math.sqrt(population / density))
    city_size = math.min(city_size, math.min(width, height) - 10)

    local map = {}
    for y = 1, height do
        map[y] = {}
        for x = 1, width do
            map[y][x] = '-'
        end
    end

    local main_interval = era == "1920s" and 8 or 5
    for x = 1, width, main_interval do
        for y = 1, height do
            if x % main_interval == 0 then
                map[y][x] = 'J'
            end
        end
    end

    for y = 1, height, main_interval do
        for x = 1, width do
            if y % main_interval == 0 then
                map[y][x] = 'J'
            end
        end
    end

    local function create_zone(start_x, start_y, w, h, zone_type)
        local building_chars = {
            residential = {'U', 'D', 'H'},
            commercial = {'C', 'P', 'R'},
            industrial = {'P', 'X', 'J'},
            park = {'H', 'F', 'Y'}
        }
        for dy = 1, h do
            for dx = 1, w do
                local x = start_x + dx
                local y = start_y + dy
                if x <= width and y <= height and map[y][x] == '-' then
                    if zone_type == "park" then
                        map[y][x] = love.math.random() < 0.7 and 'H' or 'F'
                    else
                        local choices = building_chars[zone_type]
                        map[y][x] = choices[love.math.random(#choices)]
                    end
                end
            end
        end
    end

    local block_size = era == "1920s" and 6 or 4
    for y = 1, height, block_size + 2 do
        for x = 1, width, block_size + 2 do
            if love.math.random() < 0.3 then
                local rotation = love.math.random(0, 3) * math.pi/2
                for dy = 0, block_size do
                    for dx = 0, block_size do
                        local rx = math.floor(x + math.cos(rotation)*dx - math.sin(rotation)*dy)
                        local ry = math.floor(y + math.sin(rotation)*dx + math.cos(rotation)*dy)
                        if rx >= 1 and rx <= width and ry >= 1 and ry <= height then
                            map[ry][rx] = 'J'
                        end
                    end
                end
            end

            local zone_type = "residential"
            if love.math.random() < 0.4 then
                zone_type = "commercial"
            elseif love.math.random() < 0.1 then
                zone_type = "industrial"
            elseif love.math.random() < 0.2 then
                zone_type = "park"
            end
            create_zone(x + 1, y + 1, block_size, block_size, zone_type)
        end
    end

    if water_access then
        for x = 1, width do
            map[height][x] = love.math.random() < 0.7 and 'W' or 'B'
            if era == "1920s" and x % 10 == 0 then
                map[height-1][x] = 'J'
            end
        end
    end

    return map
end

return urban
