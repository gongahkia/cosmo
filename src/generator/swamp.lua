function generate_swamp(width, height, params)
    params = params or {}
    local humidity = params.humidity or 0.8
    local biodiversity = params.biodiversity or 3
    local flood_cycle = params.flood_cycle or 0.2
    local voronoi_sites = {}
    for _ = 1, math.floor(width*height/400) do
        table.insert(voronoi_sites, {
            x = love.math.random(width),
            y = love.math.random(height),
            type = love.math.random() < 0.3 and 'mound' or 'pool'
        })
    end
    local water_map = {}
    for y = 1, height do
        water_map[y] = {}
        for x = 1, width do
            water_map[y][x] = love.math.noise(x/20, y/20) * 0.5 +
                             love.math.noise(x/5, y/5) * 0.3
        end
    end
    local function generate_mangrove(start_x, start_y, depth)
        if depth > 3 + biodiversity then return end
        local angle = math.rad(25 + love.math.random(-15, 15))
        local length = 3 + love.math.random(2)
        local branches = {}
        for i = 1, length do
            local ny = start_y - i
            if ny > 0 and ny <= height then
                branches[#branches+1] = {x = start_x, y = ny}
            end
        end
        if depth > 1 then
            branches[#branches+1] = generate_mangrove(
                start_x + math.cos(angle),
                start_y - length,
                depth + 1
            )
            branches[#branches+1] = generate_mangrove(
                start_x - math.cos(angle),
                start_y - length,
                depth + 1
            )
        end
        return branches
    end
    local map = {}
    for y = 1, height do
        map[y] = {}
        for x = 1, width do
            local nearest = {dist = math.huge}
            for _, site in ipairs(voronoi_sites) do
                local dx = x - site.x
                local dy = y - site.y
                local dist = dx*dx + dy*dy
                if dist < nearest.dist then
                    nearest = {dist = dist, site = site}
                end
            end
            local water_level = water_map[y][x] * humidity
            local is_flooded = love.math.noise(x/10 + 1000, y/10) < flood_cycle
            local char = '-'
            if water_level > 0.7 then
                char = 'B'  
            elseif water_level > 0.6 then
                char = 'W'
            elseif is_flooded then
                char = 'V'  
            else
                if nearest.site.type == 'mound' then
                    char = 'H'  
                else
                    char = 'V'  
                end
            end
            if char == 'V' and love.math.random() < 0.02 * biodiversity then
                local mangrove = generate_mangrove(x, y, 1)
                if mangrove then
                    for _, pos in ipairs(mangrove) do
                        if pos.y > 0 and pos.y <= height and pos.x > 0 and pos.x <= width then
                            map[pos.y][pos.x] = love.math.random() < 0.7 and 'F' or 'T'
                        end
                    end
                end
            end
            
            map[y][x] = map[y][x] or char
        end
    end
    local lines = {}
    for y = 1, height do
        lines[y] = table.concat(map[y])
    end
    local success, message = pcall(function()
        love.filesystem.write("map.txt", table.concat(lines, "\n"))
    end)
    return success, message
end