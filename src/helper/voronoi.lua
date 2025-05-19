local voronoi = {}

function voronoi.generate_voronoi_seeds(width, height, count)
    local seeds = {}
    for _ = 1, count do
        table.insert(seeds, {
            x = love.math.random(width),
            y = love.math.random(height),
            value = love.math.random()
        })
    end
    return seeds
end

function voronoi.get_voronoi_cell(x, y, seeds)
    local closest = {dist = math.huge}
    for _, seed in ipairs(seeds) do
        local dx = x - seed.x
        local dy = y - seed.y
        local dist = dx*dx + dy*dy
        if dist < closest.dist then
            closest = {dist = dist, seed = seed}
        end
    end
    return closest.seed
end

return voronoi