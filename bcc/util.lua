local util = { str = {}, dbg = {}, cs = {}, lua = {} }


-- str

util.str.starts_with = function(str, start)
    return str:sub(1, #start) == start
end


-- dbg

util.dbg.single_print = function(m)
    local trc = debug.traceback()
    local trc_lines = {}
    for s in trc:gmatch("[^\r\n]+") do
        table.insert(trc_lines, s)
    end
    local caller = trc_lines[4]:gsub(".+_/", "")
    log(caller)

    log("\n" .. m)
    log("-end-")
end

util.dbg.deep_print = function(x)
    util.dbg.single_print(serpent.block(x, { sortkeys = true, compact = true, comment = false }))
end
util.dbg.prn = function(x, m)
    if m then
        util.dbg.deep_print({ msg = m, x = x })
    else
        util.dbg.deep_print(x)
    end
end

-- cs

util.cs.on_cs_event = function(cs_event, f)
    script.on_event(remote.call("cybersyn", "get_" .. cs_event), f)
end


-- lua

util.lua.keyset = function(tab)
    local keyset = {}
    local n = 0
    for k, v in pairs(tab) do
        n = n + 1
        keyset[n] = k
    end
    return keyset
end

local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
util.lua.deepcopy = deepcopy

util.lua.select_keys = function(tab, keys)
    local obj = {}
    for _, key in ipairs(keys) do
        obj[key] = tab[key]
    end
    return obj
end

util.lua.dissoc = function(tab, keys)
    local obj = deepcopy(tab)

    for _, k in ipairs(keys) do
        obj[k] = nil
    end

    return obj
end

util.lua.multimethod = function(dispatch_fn, default_fn)
    -- dispatch_fn will be called first will all arguments
    -- the return value will be looked up in `methods` and should
    -- be a function which is then called with all arguments
    local methods = {}
    setmetatable(methods, {
        __call = function(methods, ...)
            local dispatch = dispatch_fn(...)
            if dispatch and methods[dispatch] then
                return methods[dispatch](...)
            elseif default_fn then
                return default_fn(...)
            else
                error("No multimethod delegate found")
            end
        end
    })
    return methods
end

--

return util
