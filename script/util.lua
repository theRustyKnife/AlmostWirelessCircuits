local util = {}


-- This module provides an extended more usable version of the vanilla util. It keeps the original functions more or less intact, renaming them to match the standard and eventually omitting or reimplementing the outdated ones.

-- SURFACE
util.surface = util.surface or {}

function util.surface.distance(pos1, pos2)
	return ((pos1.x - pos2.x)^2 + (pos1.y - pos2.y)^2)^0.5
end

function util.surface.move_position(position, direction, distance)
	local x, y, use_xy = util.surface.unpack_position(position)
	
	if     direction == defines.direction.north then y = y - distance
	elseif direction == defines.direction.south then y = y + distance
	elseif direction == defines.direction.east  then x = x + distance
	elseif direction == defines.direction.west  then x = x - distance
	end
	
	if use_xy then return {x   = x, y   = y}
	else           return {[1] = x, [2] = y}
	end
end

function util.surface.flip_direction(direction)
	return (direction + 4) % 10 -- simplified implementation based on the defines values - I hope they don't change...
end

function util.surface.create_dummy_from(entity, dummy_name, destructible, operable)
	local res = entity.surface.create_entity{
		name = dummy_name,
		position = entity.position,
		force = entity.force
	}
	res.destructible = destructible or false
	res.operable = operable or false
	
	return res
end

function util.surface.area_around(position, distance)
	local x, y, use_xy = util.surface.unpack_position(position)
	local x1, y1, x2, y2 = x - distance, y - distance, x + distance, y + distance
	
	if use_xy then return {{x = x1, y = y1}, {x = x2, y = y2}}
	else return {{x1, y1}, {x2, y2}}
	end
end

function util.surface.unpack_position(pos)
	local x, y = pos.x, pos.y
	local xy = true
	
	if not x or not y then -- support both position formats ({x=x, y=y} and {[1]=x, [2]=y})
		x, y = pos[1], pos[2]
		xy = false
	end
	
	return x, y, xy -- xy = whether the original format used x, y or 1, 2 as indicies
end


-- TABLE
util.table = util.table or {}

function util.table.deep_copy(tab) -- mostly borrowed from original util
	local lookup_table = {}
	
	local function _copy(tab)
		if type(tab) ~= "table" then return tab
		elseif tab.__self then return tab
		elseif lookup_table[tab] then return lookup_table[tab]
		end
		
		local new_table = {}
		lookup_table[tab] = new_table
		
		for i, v in pairs(tab) do new_table[_copy(i)] = _copy(v); end
		
		return setmetatable(new_table, getmetatable(tab))
	end
	
	return _copy(tab)
end

function util.table.equals(tab1, tab2) -- mostly borrowed from original util
	local function _equals_oneway(tab1, tab2)
		for i, v in pairs(tab1) do
			if type(v) == "table" and not v.__self and type(tab2[i]) == "table" and not tab2[i].__self then
				if not util.table.compare(v, tab2[i]) then return false; end
			else
				if not v == tab1[i] then return false; end
			end
		end
	end
	
	return _equals_oneway(tab1, tab2) and _equals_oneway(tab2, tab1)
end

function util.table.contains(tab, element)
	for _, v in pairs(tab) do if v == element then return true; end; end
	return false
end


-- EVENTS
util.events = util.events or {}

function util.events.set_on_built(f)
	script.on_event(defines.events.on_built_entity, f)
	script.on_event(defines.events.on_robot_built_entity, f)
end

function util.events.set_on_destroyed(f)
	script.on_event(defines.events.on_entity_died, f)
	script.on_event(defines.events.on_preplayer_mined_item, f)
	script.on_event(defines.events.on_robot_pre_mined, f)
end


-- DATA
util.data = util.data or {}

function util.data.make_entities(entities)
	for _, e in ipairs(entities) do
		-- entity
		local te = util.table.deep_copy(data.raw[e.base.type][e.base.name])
		for i, p in pairs(e.properties) do te[i] = p; end
		
		local ti, tr
		if not e.hidden then --TODO: make this more universal
			-- item
			ti = util.table.deep_copy(data.raw["item"][e.item_base or e.base.name])
			ti.name = te.name
			ti.place_result = te.name
			ti.order = te.order or "z[something-else]"
			ti.subgroup = e.subgroup or "circuit-network"
			
			-- recipe
			tr = util.table.deep_copy(data.raw["recipe"][e.recipe_base or e.base.name])
			tr.name = ti.name
			tr.result = ti.name
			
			-- tech
			table.insert(data.raw.technology[e.tech or "circuit-network"].effects, {type = "unlock-recipe", recipe = tr.name})
		end
		
		-- add to data
		data:extend{te, ti, tr}
	end
end


-- FORMAT
util.format = util.format or {}

function util.format.position(pos)
	local x, y = util.surface.unpack_position(pos)
	return string.format("[%g, %g]", x, y)
end

function util.format.time(ticks) -- mostly borrowed from original util
	local s = ticks / 60
	local m = math.floor(s / 60)
	local s = math.floor(s % 60)
	
	return string.format("%d:%02d", m, s)
end


package.loaded[".util"] = function() return util; end
--[[pcall(function()]] if script ~= nil then util.gui = require ".gui_util"; end;-- end) -- functions for handling gui, only load when exists
--[[pcall(function()]] util.localu = require ".local_util";-- end) -- specific functions for the current mod, only load when exists


return util
