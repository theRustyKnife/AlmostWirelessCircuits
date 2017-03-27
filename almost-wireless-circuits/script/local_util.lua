local util = require ".util"
local config = require ".config"


local local_util = {}


function local_util.add_pole(entity, dummy, autoconnect, wires)
	dummy = dummy or util.surface.create_dummy_from(entity, config.DUMMY_NAME)
	
	table.insert(global.poles, {pole = entity, dummy = dummy})
	if autoconnect then
		for _, neighbour in pairs(entity.neighbours.copper) do
			if local_util.find_in_global(neighbour) then -- only autoconnect circuit-only poles
				for __, wire in pairs(wires) do
					entity.connect_neighbour{target_entity = neighbour, wire = wire}
				end
			end
		end
	end
	entity.disconnect_neighbour() -- disconnect copper wires
end

function local_util.try_rm_pole(pole)
	local i, v = local_util.find_in_global(pole)
	if i then
		if v.dummy.valid then v.dummy.destroy() end
		table.remove(global.poles, i)
	end
end

function local_util.find_in_global(pole)
	for i, v in pairs(global.poles) do
		if v.pole == pole then return i, v; end
	end
	return nil, nil
end

function local_util.is_pole(stack)
	return stack.valid_for_read and stack.prototype and stack.prototype.place_result and stack.prototype.place_result.type == "electric-pole"
end


return local_util
