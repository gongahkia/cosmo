local files = {}

function files.read_map(filename)
    local map = {}
    local lines = love.filesystem.lines(filename)
    for line in lines do
        local row = {}
        for char in line:gmatch(".") do
            table.insert(row, char)
        end
        table.insert(map, row)
    end
    return map
end

function files.write_map(map, filename)
    local lines = {}
    for y, row in ipairs(map) do
        lines[y] = table.concat(row)
    end
    love.filesystem.write(filename, table.concat(lines, "\n"))
end

function files.file_exists(filename)
    return love.filesystem.getInfo(filename) ~= nil
end

return files