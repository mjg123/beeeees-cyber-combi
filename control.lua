local u = require("bcc.util")



local reinit = function()
    global.players = global.players or {}
end

script.on_init(reinit)





local f = require("bcc.factorio")
local qd = require("bcc.q.q_data")

local update = function(e)
    u.dbg.prn("------------ run --- " .. e.tick)

    qd.poll_cs()

    for _, pg in pairs(f.get_all_player_globals()) do
        if pg.gui then
            u.dbg.prn(pg, "WAT")
            pg.gui.update()
        end
    end

    -- TODO: poke all the combis here too
end



f.init(update)


-- TODO: work out how to expose these values via a combinator
