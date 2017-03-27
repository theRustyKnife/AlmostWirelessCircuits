local USE_AUTO_HANDLERS = true


require ".util"


local gui_util = {}


-- maintanance functions
function gui_util.init() -- needs to be called in on_init
	global.gui_util = global.gui_util or {}
	global.gui_util.check_boxes = global.gui_util.check_boxes or {}
end


-- gui events
function gui_util.on_checked_changed(event)
	for _, cb in pairs(global.gui_util.check_boxes) do
		if cb.gui == event.element then
			if cb.handlers.on_checked_changed and type(cb.handlers.on_checked_changed) == "function" then
				cb.handlers.on_checked_changed(cb, event.player_index)
			end
		end
	end
end


-- gui stuff
function gui_util.make_check_box(parent, name, caption, state)
	local cb = {}
	
	cb.gui = parent.add{
		type = "checkbox",
		name = name,
		caption = caption,
		state = state,
	}
	
	cb.handlers = {}
	
	table.insert(global.gui_util.check_boxes, cb)
	
	return cb
end


-- register the gui events
if USE_AUTO_HANDLERS then
	script.on_event(defines.events.on_gui_checked_state_changed, gui_util.on_checked_changed)
end


return gui_util
