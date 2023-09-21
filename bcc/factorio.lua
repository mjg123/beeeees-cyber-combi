local u = require("__beeeees_cyber_combi__/bcc/util")
local g = require("__beeeees_cyber_combi__/bcc/gui/general_layout")


local factorio = {}

factorio.get_player_global = function(id)
    global.players = global.players or {}
    if global.players[id] == nil then global.players[id] = {} end
    return global.players[id]
end

factorio.get_all_player_globals = function()
    global.players = global.players or {}
    return global.players
end

factorio.init = function(update_everything_fn)
    local gui_handlers = {
        bcc_toggle_gui = function(event)
            local pg = factorio.get_player_global(event.player_index)

            if pg.gui == nil then
                -- Need to create a UI for some reason
                local player = game.get_player(event.player_index)
                pg.gui = g.create_main_frame(player.gui.screen)
            end

            pg.gui.toggle_visibility()
        end,

        bcc_reset_gui = function(event)
            u.dbg.prn("RESETTING")

            local pg = factorio.get_player_global(event.player_index)
            if pg.gui then pg.gui.destroy() end
            pg.gui = nil
        end
    }

    script.on_event(defines.events.on_lua_shortcut, function(event)
        if not event.prototype_name then return end
        local f = gui_handlers[event.prototype_name]
        if f then f(event) end
    end)

    script.on_nth_tick(60, update_everything_fn)
end

return factorio
