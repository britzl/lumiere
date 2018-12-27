local lumiere = require "lumiere.lumiere"

local M = {}

local RT = nil

function M.init()
	assert(not RT)
	RT = lumiere.create_render_target("graphics2d", true, false, false)
end

function M.final()
	lumiere.delete_render_target(RT)
	RT = nil
end

function M.update(view, projection)
	lumiere.enable_render_target(RT)
	lumiere.clear(lumiere.BLACK)
	lumiere.draw_graphics2d(view, projection)
	lumiere.disable_render_target()
end

function M.render_target()
	return RT
end

return M