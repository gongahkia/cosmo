-- Farmland generator using genetic algorithm for field optimization
-- Research: Genetic algorithms for spatial optimization

local farm = {}

function farm.generate(width, height, params)
    params = params or {}
    local soil_quality = params.soil_quality or 0.7
    local water_access = params.water_access or 0.4
    local crop_types = params.crop_types or 3

    local voronoi_seeds = {}
    local num_fields = math.floor(width * height / 100)

    for _ = 1, num_fields do
        table.insert(voronoi_seeds, {
            x = love.math.random(width),
            y = love.math.random(height),
            crop = love.math.random(crop_types),
            fitness = 0
        })
    end

    local generations = 50
    local population_size = 10
    local mutation_rate = 0.1

    local function calculate_fitness(seeds)
        local total = 0
        for _, seed in ipairs(seeds) do
            local water_dist = math.min(seed.x/width, 1 - seed.x/width, seed.y/height)
            local soil = love.math.noise(seed.x/50, seed.y/50) * soil_quality
            total = total + (water_dist * water_access + soil) * (1.2 - 0.4 * seed.crop/crop_types)
        end
        return total
    end

    for _ = 1, generations do
        local population = {}
        for i = 1, population_size do
            local new_seeds = {}
            for _, seed in ipairs(voronoi_seeds) do
                local new_crop = love.math.random() < mutation_rate and love.math.random(crop_types) or seed.crop
                table.insert(new_seeds, {
                    x = seed.x,
                    y = seed.y,
                    crop = new_crop,
                    fitness = 0
                })
            end
            new_seeds.fitness = calculate_fitness(new_seeds)
            table.insert(population, new_seeds)
        end
        table.sort(population, function(a,b) return a.fitness > b.fitness end)
        voronoi_seeds = population[1]
    end

    local map = {}
    for y = 1, height do
        map[y] = {}
        for x = 1, width do
            local closest = {dist = math.huge}
            for _, seed in ipairs(voronoi_seeds) do
                local dx = x - seed.x
                local dy = y - seed.y
                local dist = dx*dx + dy*dy
                if dist < closest.dist then
                    closest = {dist = dist, crop = seed.crop}
                end
            end
            map[y][x] = closest.crop == 1 and 'C' or closest.crop == 2 and 'H' or 'Y'
        end
    end

    local water_map = {}
    for y = 1, height do
        water_map[y] = {}
        for x = 1, width do
            water_map[y][x] = love.math.noise(x/30, y/30) * water_access
        end
    end

    for y = 2, height-1 do
        for x = 2, width-1 do
            if water_map[y][x] > 0.6 then
                map[y][x] = 'W'
                for dy = -1, 1 do
                    for dx = -1, 1 do
                        if map[y+dy][x+dx] ~= 'W' and love.math.random() < 0.3 then
                            map[y+dy][x+dx] = 'L'
                        end
                    end
                end
            end
        end
    end

    return map
end

return farm
