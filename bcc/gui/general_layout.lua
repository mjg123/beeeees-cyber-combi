local u = require("__beeeees_cyber_combi__/bcc/util")
local q = require("__beeeees_cyber_combi__/bcc/q/query")
local dt = require("__beeeees_cyber_combi__/bcc/gui/data_table")

local g = {}

local foldable_frame = function(parent, name)
    local f = parent.add {
        type = "frame", name = "bcc_" .. name, style = "bcc_foldable_frame",
        direction = "horizontal",
    }
    return { add = f.add }
end

local h_flow = function(parent, name)
    return parent.add {
        type = "flow", name = "bcc_" .. name, style = "bcc_h_flow",
        direction = "horizontal",
    }
end

local frame = function(parent, name)
    return parent.add {
        type = "frame", name = "bcc_" .. name, style = "bcc_content_frame"
    }
end

local d_table = function(parent, name, cols)
    local invisi_frame = parent.add {
        type = "frame", style = "bcc_invisi_frame"
    }

    local add_table_to_frame = function(c)
        return invisi_frame.add {
            type = "table", name = "bcc_" .. name,
            column_count = c,
            draw_horizontal_line_after_headers = true
        }
    end

    local table = add_table_to_frame(cols)

    return {
        update = function(new_data)
            if #new_data.columns ~= table.column_count then
                table.destroy()
                table = add_table_to_frame(#new_data.columns)
            end
            dt.update_results_table(table, new_data)
        end
    }
end

local query_and_results_panel = function(parent)
    local q_zone = frame(parent, "q_zone")
    local d_zone = frame(parent, "d_zone")

    q_zone.add { type = "label", caption = "Q|ZONE" }
    d_zone.add { type = "label", caption = "D|ZONE" }

    local data_table = d_table(d_zone, "data_table", 1)

    local query = { table = q.tables.stations }

    return {
        update = function()
            local new_data = q.query(query)
            data_table.update(new_data)
        end

    }
end

--

g.create_main_frame = function(parent)
    u.dbg.prn("Creating new GUI")
    local main_frame = parent.add {
        type = "frame", name = "bcc_main_frame",
        direction = "vertical",
        caption = { "bcc.main_caption" },
        visible = false
    }

    main_frame.auto_center = true

    local top_foldable = foldable_frame(main_frame, "top_foldable")
    local top_frame = frame(top_foldable, "top_zone")
    top_frame.add { type = "label", caption = "T|ZONE" }

    local bottom_foldable = foldable_frame(main_frame, "bottom_foldable")


    -- I think the next thing is to try having multiple qarps in a tabbed pane
    local qarp = query_and_results_panel(bottom_foldable)



    ---
    -- like this?

    local tabber = main_frame.add { type = "tabbed-pane" }

    local tab1 = tabber.add { type = "tab", caption = "Tab 1" }
    local tab2 = tabber.add { type = "tab", caption = "Tab 2" }
    local tab3 = tabber.add { type = "tab", caption = "Tab 3" }
    local tab4 = tabber.add { type = "tab", caption = "Tab 4" }

    local label1 = tabber.add { type = "label", caption = "Label 1" }
    local label2 = tabber.add { type = "label", caption = "Label 2" }
    local label3 = tabber.add { type = "label", caption = "Label 3" }
    local label4 = tabber.add { type = "label", caption = "Label 4" }

    tabber.add_tab(tab1, label1)
    tabber.add_tab(tab2, label2)
    tabber.add_tab(tab3, label3)
    tabber.add_tab(tab4, label4)

    ---



    return {
        destroy = main_frame.destroy,

        toggle_visibility = function()
            main_frame.visible = not main_frame.visible
        end,

        update = function()
            if not main_frame.visible then return end
            qarp.update()
        end
    }
end

return g
