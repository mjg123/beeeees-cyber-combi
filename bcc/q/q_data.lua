local u = require("__beeeees_cyber_combi__/bcc/util")

-- Where q.queries finds its answers


-- qq: what can be memoized or cached in here?

local q_data = {}
q_data.data = {
    trains = {
        data = {},
        columns = {
            { key = "status",     display = "Status" },
            { key = "manifest",   display = "Manifest" },
            { key = "p_stn_name", display = "Providing Station" },
            { key = "r_stn_name", display = "Requesting Station" },
            { key = "layout",     display = "Layout" },
        }
    },
    stations = {
        data = {},
        columns = {
            { key = "name",       display = "Name" },
            { key = "provides",   display = "Providing" },
            { key = "requests",   display = "Requesting" },
            { key = "t_incoming", display = "Deliveries" },
            { key = "u_requests", display = "Unsatisfied" }
        }
    },
}

--
-- TRAINS
--

-- We could also have callbacks on train activity, but we don't.
-- They would look like this:
--
-- u.cs.on_cs_event("on_train_status_changed", function(e)
--     game.print("=================")
-- end)
--
-- However, this isn't available for stations
-- Given that we have to poll for station info anyway, we can
-- poll for train info at the same time. This saves the
-- headache of figuring out how to deal with two datasets that
-- update at different rates.
--

-- cybersyn/constants.lua#43-51
local train_status_description = {
    [0] = "at depot",
    [1] = "heading to load",
    [2] = "loading",
    [3] = "heading to unload",
    [4] = "unloading",
    [5] = "returning to depot",
    [6] = "bypassing depot",
    [7] = "heading to refuel",
    [8] = "refueling"
}

local train_status_description = function(trn)
    local desc = train_status_description[trn.status]
    return desc or ("no desc_fn for " .. trn.status)
end


local train_layout_string = function(trn)
    local layout = ""
    for _, carriage in ipairs(trn.entity.carriages) do
        layout = layout .. "[item=" .. carriage.name .. "]"
    end
    return layout
end

local make_train_row = function(t, ss)
    return {
        status = train_status_description(t),
        manifest = t.manifest,
        p_stn_id = t.p_station_id,
        r_stn_id = t.r_station_id,
        p_stn_name = t.p_station_id and ss[t.p_station_id].name,
        r_stn_name = t.r_station_id and ss[t.r_station_id].name,
        layout = train_layout_string(t),
    }
end


local make_q_trains_data = function(ss, ts)
    local q_trains = {}

    for cs_train_id, cs_train in pairs(ts) do
        if cs_train then
            q_trains[cs_train_id] = make_train_row(cs_train, ss)
        end
    end

    return q_trains
end

--
-- STATIONS
--

local threshold = function(cs_stn, signal_name)
    return (cs_stn.item_thresholds and cs_stn.item_thresholds[signal_name]) or cs_stn.r_threshold or 2000
end

local cs_stn_to_factorio_format = function(s)
    return { signal = { signal = s.signal, type = s.type }, count = s.count }
end

local get_station_requests_provides = function(cs_stn)
    -- got by looking for negatives on the combinator_input
    -- returns array of signals which are negative enough to pass their request_threshold
    -- we have this because it allows us to track demand which is currently en-route to us
    -- which is removed from the station's tick_signals

    local all_requests = cs_stn.is_r and {} or "/" -- NOTE: cs does not always set these
    local all_provides = cs_stn.is_p and {} or "/" -- if there is no product at the station

    local station_inputs = cs_stn.entity_comb1.get_merged_signals(defines.circuit_connector_id.combinator_input)
    if station_inputs == nil then return {} end

    for _, sig in pairs(station_inputs) do
        if sig.signal.type ~= "virtual" then
            if cs_stn.is_p and sig.count > 0 then
                table.insert(all_provides, sig)
            end
            if cs_stn.is_r and sig.count + threshold(cs_stn, sig.signal.name) <= 0 then
                table.insert(all_requests, sig)
            end
        end
    end

    return all_requests, all_provides
end

local get_incoming_trains = function(cs_stn_id, ts)
    local incoming = {}
    for _, t in pairs(ts) do
        if t.r_station_id and t.r_station_id == cs_stn_id then
            table.insert(incoming, t.manifest)
        end
    end
    return incoming
end

local get_unsatisfied_requests = function(cs_stn)
    local unsats = {}

    if cs_stn.tick_signals then
        for _, tsig in pairs(cs_stn.tick_signals) do
            if tsig.count < 0 then
                table.insert(unsats, tsig)
            end
        end
    end

    return unsats
end

local make_q_stations_data = function(ss, ts)
    local q_stations = {}

    for cs_stn_id, cs_stn in pairs(ss) do
        local requests, provides = get_station_requests_provides(cs_stn)
        local t_incoming = get_incoming_trains(cs_stn_id, ts)
        local u_requests = get_unsatisfied_requests(cs_stn)

        q_stations[cs_stn_id] = {
            id = cs_stn_id,
            name = cs_stn.entity_stop.backer_name,
            requests = requests,
            provides = provides,
            t_incoming = t_incoming,
            u_requests = u_requests,
        }
    end

    return q_stations
end

q_data.poll_cs = function()
    -- Trains and Stations data rely on each other for processing, so fetch
    -- them both from cs first then munge together.
    local cs_stations = remote.call("cybersyn", "read_global", "stations")
    local cs_trains = remote.call("cybersyn", "read_global", "trains")

    local q_stations = make_q_stations_data(cs_stations, cs_trains)
    local q_trains = make_q_trains_data(cs_stations, cs_trains)

    q_data.data.trains.data = q_trains
    q_data.data.stations.data = q_stations
end

return q_data
