local lumiere = require "lumiere.lumiere"

local M = {}

local render_target = nil

function M.init()
	assert(not render_target, "You cannot call init() twice")
	render_target = lumiere.create_render_target("graphics2d", { color = true })
end

function M.final()
	assert(render_target, "You cannot call final() twice")
	lumiere.delete_render_target(render_target)
	render_target = nil
end

function M.update()
	lumiere.use_world_projection()
	lumiere.enable_render_target(render_target)
	lumiere.clear(lumiere.BLACK)
	lumiere.draw_graphics2d()
	lumiere.disable_render_target()
end

function M.render_target()
	return render_target
end

return M