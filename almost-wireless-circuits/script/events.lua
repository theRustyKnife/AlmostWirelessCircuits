local util = require ".util"
local config = require ".config"


local function on_built(event)
	local entity = event.created_entity
	
	if entity.type == "electric-pole" then
		local dummy = entity.surface.find_entities_filtered{area = util.surface.area_around(entity.position, 0.1), name = config.DUMMY_NAME, limit = 1}[1]
		
		local player_prefs = {autoconnect = true, circuit_only = false}
		if event.player_index then player_prefs = global.player_prefs[event.player_index] or player_prefs end
		
		if dummy then -- there's a dummy - placed from BP - don't autoconnect but add
			util.localu.add_pole(entity, dummy, false)
			
		elseif util.table.contains(config.CIRCUIT_ONLY_POLES, entity.name) then -- circuit-only pole - add it
			local wires = {defines.wire_type.red, defines.wire_type.green}
			
			util.localu.add_pole(
				entity,
				util.surface.create_dummy_from(entity, config.DUMMY_NAME),
				player_prefs.autoconnect,
				wires
			)
		
		elseif player_prefs.circuit_only then -- player set this pole to circuit-only
			local wires = {defines.wire_type.red, defines.wire_type.green}
			
			util.localu.add_pole(
				entity,
				util.surface.create_dummy_from(entity, config.DUMMY_NAME),
				player_prefs.autoconnect,
				wires
			)
			
		elseif event.player_index and player_prefs.autoconnect == false then
			entity.disconnect_neighbour()
		end
		
	elseif entity.type == "entity-ghost" and entity.ghost_name == config.DUMMY_NAME then
		local _, entity = entity.revive()
		entity.destructible = false
		entity.operable = false
	end
end

local function on_tick(event)
	if event.tick % config.REFRESH_RATE == 0 then
		for i, pole in pairs(global.poles) do
			pole.pole.disconnect_neighbour()
		end
	end
end

local function on_destroyed(event)
	local entity = event.entity
	
	if entity.type == "electric-pole" then util.localu.try_rm_pole(entity)
	elseif entity.type == "entity-ghost" and entity.ghost_type == "electric-pole" then
		local dummy = surface.find_entity(config.DUMMY_NAME, entity.position)
		if dummy then dummy.destroy() end
	end
end

local function on_marked_for_deconstruction(event)
	local entity = event.entity
	if entity.type == "electric-pole" then
		util.localu.try_rm_pole(entity)
	end
end

local function on_circuit_only_changed(cb, player_index)
	global.player_prefs[player_index].circuit_only = cb.gui.state
end

local function on_autoconnect_changed(cb, player_index)
	global.player_prefs[player_index].autoconnect = cb.gui.state
end

local function on_player_cursor_stack_changed(event)
	local player = game.players[event.player_index]
	local c_stack = player.cursor_stack
	
	if util.localu.is_pole(c_stack) then
		if not global.gui[event.player_index] then
			global.player_prefs[event.player_index] = global.player_prefs[event.player_index] or {circuit_only = false, autoconnect = true}
			
			local parent_frame = player.gui.left.add{type = "frame", name = "awc-frame", caption = {"awc-title"}, direction = "vertical"}
			
			local t_circuit_only = util.gui.make_check_box(parent_frame, "awc-circuit-only-cb", {"awc-circuit-only-toggle"}, global.player_prefs[event.player_index].circuit_only)
			t_circuit_only.handlers.on_checked_changed = on_circuit_only_changed
			
			local t_autoconnect = util.gui.make_check_box(parent_frame, "awc-autoconnect-cb", {"awc-autoconnect-toggle"}, global.player_prefs[event.player_index].autoconnect)
			t_autoconnect.handlers.on_checked_changed = on_autoconnect_changed
			
			global.gui[event.player_index] = parent_frame
		end
	elseif global.gui[event.player_index] then
		if global.gui[event.player_index].valid then global.gui[event.player_index].destroy(); end
		global.gui[event.player_index] = nil
	end
end


util.events.set_on_built(on_built)
script.on_event(defines.events.on_tick, on_tick)
util.events.set_on_destroyed(on_destroyed)

script.on_event(defines.events.on_marked_for_deconstruction, on_marked_for_deconstruction)

script.on_event(defines.events.on_player_cursor_stack_changed, on_player_cursor_stack_changed)
