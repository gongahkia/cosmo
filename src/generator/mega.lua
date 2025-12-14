-- Megastructure generator with recursive fractal architecture
-- Research: Quantum geometry and recursive spatial structures

local mega = {}

function mega.generate(width, height, params)
    params = params or {}
    local tech_level = params.tech_level or 7
    local bio_luminescence = params.bio_luminescence or 0.8
    local quantum_flux = params.quantum_flux or 0.3

    local map = {}
    for y = 1, height do
        map[y] = {}
        for x = 1, width do
            map[y][x] = '-'
        end
    end

    local function quantum_position(x, y)
        local qx = (math.floor(x) + math.floor(y/20)) % width
        local qy = (math.floor(y) + math.floor(x/20)) % height
        -- Ensure 1-indexed (Lua arrays start at 1)
        qx = qx == 0 and width or qx
        qy = qy == 0 and height or qy
        return qx, qy
    end

    local function generate_structure(x, y, size, depth)
        if depth > tech_level then return end
        if depth == 0 then
            for dx = -1, 1 do
                for dy = -1, 1 do
                    local nx, ny = quantum_position(x + dx, y + dy)
                    if nx >= 1 and nx <= width and ny >= 1 and ny <= height then
                        map[ny][nx] = 'Q'
                    end
                end
            end
        end

        local angle = math.pi * quantum_flux
        for i = 1, 4 do
            local new_size = size * 0.6
            local dir_x = math.cos(angle * i)
            local dir_y = math.sin(angle * i)
            local nx, ny = quantum_position(
                x + dir_x * size * 2,
                y + dir_y * size * 2
            )

            local steps = math.floor(size * 1.5)
            for s = 0, steps do
                local px = x + (dir_x * s * 2)
                local py = y + (dir_y * s * 2)
                local qx, qy = quantum_position(px, py)
                if qx >= 1 and qx <= width and qy >= 1 and qy <= height then
                    if love.math.noise(qx/10, qy/10) > 0.3 then
                        map[qy][qx] = 'P'
                    end
                end
            end

            generate_structure(nx, ny, new_size, depth + 1)
        end
    end

    local centers = {
        {x=width/4, y=height/4},
        {x=3*width/4, y=3*height/4},
        {x=width/2, y=height/2}
    }

    for _, center in ipairs(centers) do
        generate_structure(center.x, center.y, 20, 0)
    end

    for y = 1, height do
        for x = 1, width do
            local qx, qy = quantum_position(x, y)
            if love.math.noise(x/5 + 1000, y/5) > (1 - bio_luminescence) then
                map[y][x] = 'C'
            end
        end
    end

    return map
end

return mega
