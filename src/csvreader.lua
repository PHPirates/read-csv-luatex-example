-- Script based on https://gist.github.com/calebreister/8dd7ab503c91dea4dd2c499b9d004231
-- Follows https://github.com/luarocks/lua-style-guide

-- Convert a csv file to a Lua table.

-- @return table: Two-dimensional table with cell values.
function data_to_table(file, delimiter)
    delimiter = delimiter or ','

    -- Always ensures that the file is in its beginning position
    file = io.open(file)
    local data = {}
    local row = 1

    -- Loop through the lines in the file
    for current in file:lines() do
        -- Initialize table for this row
        data[row] = {}

        -- Used for adding individual columns of data
        local col = 1
        data[row][col] = ""

        -- Split on delimiter
        for str in current:gmatch('([^'..delimiter..']+)') do
            data[row][col] = str
            col = col + 1
        end
        row = row + 1
    end

    -- Clean up
    file:close()
    return data
end

-- Read a csv to a valid LaTeX table.
-- @param file string: The name of the file to read.
-- @param delimiter string: The delimiter (default ',').
-- @return string: Valid LaTeX table.
function read_csv(file, delimiter)
    local array = data_to_table(file, delimiter)
    local result = ""
    local line_separator = "\\hline"

    -- Insert data
    for y=1, #array do
        if y ~= 1 then
            result = result .. line_separator .. ' '
        end
        for x=1, #array[y] do
            result = result .. array[y][x]
            if x < #array[y] then
                result = result .. " & "
            end
        end
        if y < #array then
            result = result .. " \\\\ "
        end
    end

    return result
end

