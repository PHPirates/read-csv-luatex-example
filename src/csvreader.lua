-- Script based on https://gist.github.com/calebreister/8dd7ab503c91dea4dd2c499b9d004231
-- Follows https://github.com/luarocks/lua-style-guide

-- Convert a csv file to a Lua table.
-- @return table: Two-dimensional table with cell values.
function data_to_table(file, delimiter)
    delimiter = delimiter or ","

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
        local i = 0
        while true do
            j = i + 1
            i = string.find(current, delimiter, i + 1)
            if i ~= nil then
                data[row][col] = string.sub(current, j, i - 1)
                col = col + 1
            else
                data[row][col] = string.sub(current, j, string.len(current))
                break
            end
        end
        row = row + 1
    end

    -- Clean up
    file:close()
    return data
end

-- Read a csv to a valid LaTeX table.
-- Assumes that all rows have equal length.
-- @param file string: The name of the file to read.
-- @param delimiter string: The delimiter (default ',').
-- @return string: Valid LaTeX table.
function read_csv(file, delimiter)
    local array = data_to_table(file, delimiter)

    -- Find maximum number of colums in any row, so we can fill up the rest of the rows
    local number_of_columns = #array[1]
    for _, row in ipairs(array) do
        number_of_columns = math.max(number_of_columns, #row)
    end

    -- Figure out how many columns we have and give that to the tabular environment
    local columns = {}
    for i=1,number_of_columns do
        columns[i] = "c"
    end

    -- Construct a list of strings, as newlines will be replaced by tex.sprint
    local result = {}

    function append(value)
        table.insert(result, value)
    end

    append("\\begin{tabular}{|" .. table.concat(columns, "|") .. "|} \\hline")

    local row = ""
    -- Insert data
    for y=1, #array do
        if y ~= 1 then
           append(row .. "\\hline")
            row = ""
        end
        -- Use number of columns from the first row, to automatically throw away extra columns
        for x=1,number_of_columns do
            if array[y][x] ~= nil then
                row = row .. array[y][x]
            end
            if x < number_of_columns then
                row = row .. " & "
            end
        end
        if y < #array then
            row = row .. " \\\\ "
        end
    end

    append(row)
    append(" \\\\ \\hline")
    append("\\end{tabular}")
    return result
end

for _, row in ipairs(read_csv('data.csv')) do
    print(row)
end