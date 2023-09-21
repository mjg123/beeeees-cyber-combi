local u = require("__beeeees_cyber_combi__/bcc/util")
local qd = require("bcc.q.q_data")

-- singleton

local query = {}

query.tables = { stations = "stations", trains = "trains" }

query.query = function(q)
    if (q.table == query.tables.stations) then return qd.data.stations end
    if (q.table == query.tables.trains) then return qd.data.trains end
    return {}
end

return query
