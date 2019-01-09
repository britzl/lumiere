local lumiere = require "lumiere.lumiere"

local M = {}

local STRENGTH = 32

function M.create(strength)
	local instance = {}
	instance.strength = strength or STRENGTH

	local predicate = nil
	local strength_v4 = vmath.vector4(instance.strength, 0, 0, 0)

	function instance.init()
		predicate = lumiere.predicate({ hash("grain") })
	end

	function instance.final()
	end

	function instance.apply(input, output)
		strength_v4.x = instance.strength
		if output then lumiere.enable_render_target(output) end
		lumiere.set_identity_projection()
		lumiere.set_constant("time", lumiere.time())
		lumiere.set_constant("strength", strength_v4)
		lumiere.clear(lumiere.BLACK)
		lumiere.enable_texture(0, input)
		lumiere.draw(predicate)
		lumiere.disable_texture(0)
		lumiere.reset_constant("time")
		lumiere.reset_constant("strength")
		if output then lumiere.disable_render_target() end
	end

	return instance
end

local singleton = M.create(STRENGTH)

function M.init()
	singleton.init()
end

function M.final()
	singleton.final()
end

function M.apply(input, output)
	singleton.apply(input, output)
end

return M