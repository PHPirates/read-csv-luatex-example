-- Script based on https://gist.github.com/calebreister/8dd7ab503c91dea4dd2c499b9d004231

-- Convert a csv file to a Lua table
-- file: the name of the file to read
-- delimiter: the delimiter (default ',')
function dataToTable(file, delimiter)
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

    --Clean up
    file:close()
    return data
end

function tableToTeX(array, inject, inject_on)
    --[[
    array: the 2D array of data
    inject: string between tabular lines
    inject_on: list of lines to inject string at the end
            - Bound is [2, rows - 1], nil adds inject string to all lines
            - Out of bound line numbers are ignored
            - The list is sorted automatically
    For some reason, LuaLaTeX does not like it when I output newlines with
    \hlines. The output of this function is a continuous string.
    ]]

    --Initial conditions
    local result = ""
    local line = 1 --keeps track of add_to index, not used if inject_on is nil
    if inject_on ~= nil then
        table.sort(inject_on)
    end

    --Insert data
    for y=1, #array do
        if inject ~= nil and y ~= 1 then
            if inject_on == nil or inject_on[line] == y then
                result = result .. inject .. ' '
                line = line + 1
            end
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

--Extends the string type by allowing index selection via at(index) method.
--Can be called as s:at(index)
function string.at(self,index)
    return self:sub(index,index)
end
