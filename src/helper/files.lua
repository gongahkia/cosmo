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

function files.export_to_json(map, metadata, filename)
    local json_data = {
        metadata = metadata or {},
        width = #map[1],
        height = #map,
        terrain = {}
    }

    for y, row in ipairs(map) do
        json_data.terrain[y] = table.concat(row)
    end

    local json_string = "{\n"
    json_string = json_string .. '  "metadata": {\n'
    json_string = json_string .. '    "generator": "' .. (metadata.generator or "unknown") .. '",\n'
    json_string = json_string .. '    "seed": ' .. (metadata.seed or 0) .. ',\n'
    json_string = json_string .. '    "timestamp": "' .. (metadata.timestamp or os.date("%Y-%m-%d %H:%M:%S")) .. '",\n'
    json_string = json_string .. '    "width": ' .. json_data.width .. ',\n'
    json_string = json_string .. '    "height": ' .. json_data.height .. '\n'
    json_string = json_string .. '  },\n'
    json_string = json_string .. '  "terrain": [\n'

    for i, row_str in ipairs(json_data.terrain) do
        local comma = (i < #json_data.terrain) and "," or ""
        json_string = json_string .. '    "' .. row_str .. '"' .. comma .. '\n'
    end

    json_string = json_string .. '  ]\n'
    json_string = json_string .. '}\n'

    love.filesystem.write(filename, json_string)
    return true
end

function files.export_to_csv(map, filename)
    local csv_lines = {}
    for y, row in ipairs(map) do
        local csv_row = {}
        for x, char in ipairs(row) do
            table.insert(csv_row, char)
        end
        table.insert(csv_lines, table.concat(csv_row, ","))
    end
    love.filesystem.write(filename, table.concat(csv_lines, "\n"))
    return true
end

return files