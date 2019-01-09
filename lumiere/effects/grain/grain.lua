local lumiere = require "lumiere.lumiere"

local M = {}

local PREDICATE = nil

function M.init()
	PREDICATE = lumiere.predicate({ hash("grain") })
end

function M.final()
end

function M.apply(input, output)
	if output then lumiere.enable_render_target(output) end
	lumiere.set_identity_projection()
	lumiere.set_constant("time", lumiere.time())
	lumiere.clear(lumiere.BLACK)
	lumiere.enable_texture(0, input)
	lumiere.draw(PREDICATE)
	lumiere.disable_texture(0)
	lumiere.reset_constant("time")
	if output then lumiere.disable_render_target() end
end

return M