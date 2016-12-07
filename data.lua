local config = require "config"


-- define entities here
local entities = {
	{
		name = config.POLE_NAME,
		health = 1500,
		wire_distance = config.MAX_DISTANCE,
		supply_distance = 0,
	}
}


-- here we create our entities with all the necessary stuff
for _, e in ipairs(entities) do
	-- entity
	local te = util.table.deepcopy(data.raw["electric-pole"]["big-electric-pole"])
	te.name = e.name
	te.minable.result = e.name
	te.max_health = e.health
	te.maximum_wire_distance = e.wire_distance
	te.supply_area_distance = e.supply_distance
	
	-- item
	local ti = util.table.deepcopy(data.raw["item"]["big-electric-pole"])
	ti.name = e.name
	ti.place_result = e.name
	ti.order = "b[combinators]-cb[almost-an-antenna]"
	ti.subgroup = "circuit-network"
	
	-- recipe
	local tr = util.table.deepcopy(data.raw["recipe"]["constant-combinator"])
	tr.name = e.name
	tr.result = e.name
	
	-- tech
	table.insert(data.raw.technology["circuit-network"].effects, {type = "unlock-recipe", recipe = e.name})
	
	-- add to data
	data:extend{te, ti, tr}
end