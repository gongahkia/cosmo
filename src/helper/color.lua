local color = {}

function color.lerp_color(c1, c2, t)
    return {
        c1[1] + (c2[1]-c1[1])*t,
        c1[2] + (c2[2]-c1[2])*t,
        c1[3] + (c2[3]-c1[3])*t
    }
end

function color.create_gradient(colors, steps)
    local gradient = {}
    for i = 1, #colors-1 do
        for t = 0, 1, 1/steps do
            table.insert(gradient, color_utils.lerp_color(colors[i], colors[i+1], t))
        end
    end
    return gradient
end

function color.set_color(color)
    love.graphics.setColor(color[1], color[2], color[3], color[4] or 1)
end

return color