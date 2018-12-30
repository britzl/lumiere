local lumiere = require "lumiere.lumiere"

local M = {}

local PREDICATE = nil

M.DISTANCE = vmath.vector4(2.0, 0, 0, 0)

function M.init()
	PREDICATE = lumiere.predicate({ hash("blur") })
end

function M.final()
end

function M.apply(input, output)
	if output then lumiere.enable_render_target(output) end
	lumiere.set_identity_view_projection()
	lumiere.clear(lumiere.BLACK)
	lumiere.set_constant("resolution", lumiere.resolution())
	lumiere.set_constant("distance", M.DISTANCE)
	lumiere.enable_texture(0, input)
	lumiere.draw(PREDICATE)
	lumiere.disable_texture(0)
	lumiere.reset_constants()
	if output then lumiere.disable_render_target() end
end

return M