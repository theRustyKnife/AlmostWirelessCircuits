local config = require "config"

script.on_init(function()
	global.poles = global.poles or {}
end)

script.on_configuration_changed(function(data)
	for _, force in pairs(game.forces) do
		if force.technologies["circuit-network"].researched then
			force.recipes[config.POLE_NAME].enabled = true
		end
	end
end)

local function on_built(event)
	local entity = event.created_entity
	if entity.name == config.POLE_NAME then
		table.insert(global.poles, entity)
		
		for _, neighbour in pairs(entity.neighbours.copper) do
			if neighbour.name == config.POLE_NAME then -- only connect our poles automatically
				entity.connect_neighbour{target_entity = neighbour, wire = defines.wire_type.red}
				entity.connect_neighbour{target_entity = neighbour, wire = defines.wire_type.green}
			end
		end
		entity.disconnect_neighbour() -- disconnect copper all wires
	end
end

local function on_tick(event)
	if event.tick % config.REFRESH_RATE == 0 then
		for i, pole in pairs(global.poles) do
			if pole.valid then pole.disconnect_neighbour()
			else table.remove(global.poles, i); end
		end
	end
end

script.on_event(defines.events.on_built_entity, on_built)
script.on_event(defines.events.on_robot_built_entity, on_built)

script.on_event(defines.events.on_tick, on_tick)