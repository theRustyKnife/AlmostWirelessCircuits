local config = require ".config"
local util = require ".util"


local migration = {}


function migration.init()
	util.gui.init()
	
	global.poles = global.poles or {}
	global.player_prefs = global.player_prefs or {}
	global.gui = global.gui or {}
end

function migration.migrate(data)
	for _, force in pairs(game.forces) do
		if force.technologies["circuit-network"].researched then
			force.recipes["almost-an-antenna"].enabled = true
		end
	end
	
	if data and data.mod_changes and data.mod_changes["almost-wireless-circuits"] and data.mod_changes["almost-wireless-circuits"].old_version == "0.1.0" then
		local old_poles
		global.poles = {}
		
		for i, pole in pairs(old_poles) do
			util.localu.add_pole(pole, util.surface.create_dummy_from(entity, config.DUMMY_NAME))
		end
	end
end


return migration
