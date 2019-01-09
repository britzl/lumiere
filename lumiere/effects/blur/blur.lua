local lumiere = require "lumiere.lumiere"

local M = {}

local DISTANCE = 2

function M.create(distance)
	local instance = {}
	instance.distance = distance or DISTANCE

	local distance_vector = vmath.vector4(instance.distance, 0, 0, 0)
	local predicate = nil

	function instance.init()
		predicate = lumiere.predicate({ hash("blur") })
	end

	function M.final()
	end

	function M.apply(input, output)
		distance_vector.x = instance.distance
		if output then lumiere.enable_render_target(output) end
		lumiere.set_identity_view_projection()
		lumiere.clear(lumiere.BLACK)
		lumiere.set_constant("resolution", lumiere.resolution())
		lumiere.set_constant("distance", distance_vector)
		lumiere.enable_texture(0, input)
		lumiere.draw(predicate)
		lumiere.disable_texture(0)
		lumiere.reset_constants()
		if output then lumiere.disable_render_target() end
	end

	return instance
end

local singleton = M.create(DISTANCE)

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
