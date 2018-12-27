local lumiere = require "lumiere.lumiere"

local M = {}

local PREDICATE = nil

function M.init()
	PREDICATE = lumiere.predicate({ hash("chromatical") })
end

function M.final()
end

function M.apply(input, output)
	if output then lumiere.enable_render_target(output) end
	lumiere.set_view_projection()
	lumiere.set_constant("time", lumiere.time())
	lumiere.set_constant("window_size", lumiere.window_size())
	lumiere.clear(lumiere.BLACK)
	lumiere.enable_texture(0, input)
	lumiere.draw(PREDICATE)
	lumiere.disable_texture(0)
	lumiere.reset_constant("time")
	lumiere.reset_constant("window_size")
	if output then lumiere.disable_render_target() end
end

return M