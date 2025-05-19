function generate_reef(width, height, params)
    params = params or {}
    local water_temp = params.water_temp or 28
    local acidity = params.acidity or 8.1
    local current_strength = params.current_strength or 0.4
    local map = {}
    for y = 1, height do
        map[y] = {}
        for x = 1, width do
            if y < height * 0.2 then
                map[y][x] = 'B'  
            elseif y < height * 0.7 then
                map[y][x] = 'W'  
            else
                map[y][x] = 'S'  
            end
        end
    end
    local coral_rules = {
        staghorn = {
            axiom = "F",
            rules = {
                ["F"] = "FF+[+F-F-F]-[-F+F+F]",
                ["+"] = "+",
                ["-"] = "-",
                ["["] = "[",
                ["]"] = "]"
            },
            angle = 25
        },
        brain = {
            axiom = "F",
            rules = {
                ["F"] = "F+F-F-F+F",
                ["+"] = "+",
                ["-"] = "-"
            },
            angle = 90
        }
    }
    local function grow_coral(start_x, y, coral_type)
        local iterations = math.floor(water_temp - 25)
        local current_depth = y
        local pos_stack = {}
        local current_pos = {x = start_x, y = y, angle = 90}
        local path = coral_rules[coral_type].axiom
        for _ = 1, iterations do
            local new_path = ""
            for c in path:gmatch(".") do
                new_path = new_path .. (coral_rules[coral_type].rules[c] or c)
            end
            path = new_path
        end
        for c in path:gmatch(".") do
            if c == "F" then
                local nx = current_pos.x + math.cos(math.rad(current_pos.angle))
                local ny = current_pos.y - 1  -- Grow upward
                if nx >= 1 and nx <= width and ny >= 1 and map[ny][nx] == 'W' then
                    map[ny][nx] = 'C'  -- Coral
                    current_pos.x = nx
                    current_pos.y = ny
                end
            elseif c == "+" then
                current_pos.angle = current_pos.angle + coral_rules[coral_type].angle
            elseif c == "-" then
                current_pos.angle = current_pos.angle - coral_rules[coral_type].angle
            elseif c == "[" then
                table.insert(pos_stack, {x = current_pos.x, y = current_pos.y, angle = current_pos.angle})
            elseif c == "]" then
                current_pos = table.remove(pos_stack)
            end
        end
    end
    for x = 1, width, 10 do
        local y_floor = height * 0.7
        if acidity > 8.0 then
            grow_coral(x, y_floor - 1, love.math.random() > 0.5 and "staghorn" or "brain")
        end
    end
    local fish_schools = {}
    for _ = 1, math.floor(width/20) do
        table.insert(fish_schools, {
            x = love.math.random(width),
            y = love.math.random(height * 0.5),
            dx = math.cos(current_strength * math.pi),
            dy = math.sin(current_strength * math.pi)
        })
    end
    for _ = 1, 50 do  
        for _, fish in ipairs(fish_schools) do
            local separation = {x = 0, y = 0}
            local alignment = {x = 0, y = 0}
            local cohesion = {x = 0, y = 0}
            local neighbors = 0
            for _, other in ipairs(fish_schools) do
                if fish ~= other then
                    local dist = math.sqrt((fish.x - other.x)^2 + (fish.y - other.y)^2)
                    if dist < 5 then
                        separation.x = separation.x + (fish.x - other.x)
                        separation.y = separation.y + (fish.y - other.y)
                        alignment.x = alignment.x + other.dx
                        alignment.y = alignment.y + other.dy
                        cohesion.x = cohesion.x + other.x
                        cohesion.y = cohesion.y + other.y
                        neighbors = neighbors + 1
                    end
                end
            end
            if neighbors > 0 then
                separation.x = separation.x / neighbors
                separation.y = separation.y / neighbors
                alignment.x = alignment.x / neighbors
                alignment.y = alignment.y / neighbors
                cohesion.x = (cohesion.x / neighbors - fish.x) / 100
                cohesion.y = (cohesion.y / neighbors - fish.y) / 100
                fish.dx = fish.dx + separation.x * 0.1 + alignment.x * 0.01 + cohesion.x * 0.01
                fish.dy = fish.dy + separation.y * 0.1 + alignment.y * 0.01 + cohesion.y * 0.01
            end
            fish.dx = fish.dx + current_strength * 0.1
            fish.dy = fish.dy + love.math.random(-0.1, 0.1)
            fish.x = math.clamp(fish.x + fish.dx, 1, width)
            fish.y = math.clamp(fish.y + fish.dy, 1, height * 0.6)
            if map[math.floor(fish.y)][math.floor(fish.x)] == 'W' then
                map[math.floor(fish.y)][math.floor(fish.x)] = 'F'
            end
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