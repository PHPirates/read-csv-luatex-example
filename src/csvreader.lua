-- Script based on https://gist.github.com/calebreister/8dd7ab503c91dea4dd2c499b9d004231

-- Convert a csv file to a Lua table
-- file: the name of the file to read
-- delim: the delimiter (default ',')
function dataToTable(file, delim)
    --Set initial values
    if delim == nil then --allow delim to be optional
        delim = ','
    end

    file = io.open(file) --Always ensures that the file is in its beginning position
    local data = {}
    local row = 1

    --Loop through data
    for current in file:lines() do --file:lines() returns a string
        data[row] = {} --Initialize array within array (make 2d)
        local col = 1 --Used for adding individual columns of data
        data[row][col] = ""
        for ch in current:gmatch('.') do --ch is a character in the string
            if ch == delim then
                col = col + 1
                data[row][col] = "" --initialize string in new column
            else
                data[row][col] = data[row][col] .. ch
            end
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
