local u = require("__beeeees_cyber_combi__/bcc/util")

local data_table = {}

-- this is the main table that you interact with in the gui
-- it builds queries to hand off to q.

-- Different types of cells get drawn differently

local add_data_cell = u.lua.multimethod(function(_, data)
    -- Answers "what type of cell is this?"
    -- returns the name of the function to dispatch to for display

    -- basic types
    if data == nil then return "_nil" end
    if type(data) ~= "table" then return type(data) end

    if data.error then return "error" end

    -- signals [TODO: pick one of these signal formats]
    if data.signal and data.count ~= 0 then return "f_signal" end
    if data.name and data.type and data.count ~= 0 then return "cs_signal" end

    if data.heading then return "heading" end

    return "table"
end)

add_data_cell.string = function(parent, data)
    parent.add { type = "label", caption = data, style = "bcc_string_cell" }
end
add_data_cell.number = add_data_cell.string

add_data_cell.f_signal = function(parent, signal)
    parent.add {
        type = "sprite-button",
        sprite = (signal.signal.type .. "/" .. signal.signal.name),
        number = signal.count }
end

add_data_cell.cs_signal = function(parent, signal)
    parent.add {
        type = "sprite-button",
        sprite = (signal.type .. "/" .. signal.name),
        number = signal.count }
end

add_data_cell._nil = function(parent)
    parent.add {
        type = "label",
        caption = "-",
        style = "bcc_nil_cell",
    }
end

add_data_cell.table = function(parent, data)
    local flow = parent.add { type = "flow", direction = "horizontal" } -- style = ...etc...

    if next(data) == nil then
        -- empty
        add_data_cell._nil(flow)
    end

    for _, d in ipairs(data) do
        add_data_cell(flow, d)
    end
end

add_data_cell.error = function(parent, error)
    parent.add {
        type = "label",
        caption = "ERROR: " .. error.error
    }
end

add_data_cell.heading = function(parent, heading)
    parent.add {
        type = "label",
        style = "bcc_table_heading",
        caption = heading.heading.display
    }
end

--

data_table.update_results_table = function(tab, results)
    -- empty the current contents
    tab.clear()

    -- column headings
    for _, label in ipairs(results.columns) do
        add_data_cell(tab, { heading = label })
    end

    -- data
    for _, row in pairs(results.data) do
        for _, heading in ipairs(results.columns) do
            add_data_cell(tab, row[heading.key])
        end
    end
end

return data_table
