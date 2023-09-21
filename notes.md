# Beeeees Cyber Combi notes

global.economy seems to look like this:


```
    all_r_stations -> {
        signal-A:copper-plate -> [1354]
        signal-A:iron-plate -> [1425]     -- (station IDs)
    },
    
    
    all_p_stations -> [
        
        -- this is a station ID providing iron
        [1] -> 1889,

        -- this is a network/item pair, pointing to a list of station IDs
        "signal-A:copper-plate" -> [1830]


        -- There can be multiple of each kind    
    
         ],
    all_names -> {

    }
```

We can get all the data about what is p/r at any moment by looking up the station IDs in global.stations. However, this doesn't seem to show demand for which a train has been dispatched.

QUESTION: Can we work out the total by also counting in-progress deliveries filtered to be heading to that station?

... probably. But we can also directly read the combinator inputs to the station







Keys of a Cybersyn Station

  "entity_stop",  -- .backer_name etc
  "entity_comb1", -- the "Station" combinator, .get_merged_signals(defines.circuit_connector_id.combinator_input)
  "deliveries_total", -- neat
  "last_delivery_tick", -- ??
  "trains_limit", -- per station config?
  "priority", -- per circuit config
  "r_threshold", -- per "station" combi, or 2000
  "locked_slots", -- number
  "network_mask", -- number
  "deliveries", -- ??
  "accepted_layouts", -- ??
  "item_p_counts", -- ??
  "display_state", -- ??
  "layout_pattern", -- ??
  "allows_all_trains", -- checkbox config
  "is_stack", -- checkbox
  "enable_inactive", -- checkbox
  "is_p", -- slider
  "is_r", -- slider
  "network_name", -- signal-name
  "tick_signals", -- ??
  "entity_comb2" -- the "station control" combinator or nil

