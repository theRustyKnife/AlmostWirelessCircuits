local config = require "script.config"
local util = require "script.util"


util.data.make_entities{
	{
		base = {type = "electric-pole", name = "big-electric-pole"},
		properties = {
			name = "almost-an-antenna",
			max_health = 1500,
			maximum_wire_distance = 500,
			supply_area_distance = 0,
		},
	},
	{
		base = {type = "container", name = "steel-chest"},
		hidden = true,
		properties = {
			name = config.DUMMY_NAME,
			flags = {"placeable-off-grid", "placeable-neutral", "player-creation"},
			selectable_in_game = false,
			item_slot_count = 0,
			collision_mask = {},
			collision_box = {{0, 0}, {0, 0}},
			icon = "__almost-wireless-circuits__/graphics/trans.png",
			minable = {mining_time = 1, result = config.DUMMY_NAME},
			picture =
			{
				filename = "__almost-wireless-circuits__/graphics/trans.png",
				priority = "extra-high",
				width = 0,
				height = 0,
			},
		},
	},
}

data.raw["electric-pole"]["almost-an-antenna"].minable.result = "almost-an-antenna"

data:extend{
	{
		type = "item",
		name = config.DUMMY_NAME,
		icon = "__almost-wireless-circuits__/graphics/trans.png",
		flags = {"goes-to-main-inventory"},
		place_result = config.DUMMY_NAME,
		stack_size = 1
	},
}
