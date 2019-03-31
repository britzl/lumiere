local lumiere = require "lumiere.lumiere"

local M = {}

local AMBIENT_LIGHT = vmath.vector4(0.1, 0.1, 0.1, 1.0)

function M.create(ambient_light)
	local instance = {}
	instance.ambient_light = ambient_light or AMBIENT_LIGHT

	local distortion_render_target = nil
	local distortion_predicate = nil
	local apply_distortion_predicate = nil

	function instance.init()
		assert(not RT)
		distortion_predicate = lumiere.predicate({ hash("distortion") })
		apply_distortion_predicate = lumiere.predicate({ hash("apply_distortion") })
		distortion_render_target = lumiere.create_render_target("apply_distortion", { color = true })
	end

	function instance.final()
		lumiere.delete_render_target(distortion_render_target)
		distortion_render_target = nil
	end

	function instance.update()
		lumiere.enable_render_target(distortion_render_target)
		lumiere.clear(lumiere.BLACK)
		lumiere.draw(distortion_predicate)
		lumiere.disable_render_target()
	end

	function instance.apply(input, output)
		assert(input, "You must provide a render target to apply distortion to")

		if output then lumiere.enable_render_target(output) end

		lumiere.set_identity_projection()
		lumiere.clear(lumiere.BLACK)
		lumiere.enable_texture(0, input)
		lumiere.enable_texture(1, distortion_render_target)
		lumiere.set_constant("time", lumiere.time())
		lumiere.draw(apply_distortion_predicate)
		lumiere.reset_constants()
		lumiere.disable_texture(0)
		lumiere.disable_texture(1)

		if output then lumiere.disable_render_target() end
	end

	function instance.render_target()
		return distortion_render_target
	end

	return instance
end

local singleton = M.create(AMBIENT_LIGHT)

function M.init()
	singleton.init()
end

function M.final()
	singleton.final()
end

function M.update()
	singleton.update()
end

function M.apply(input, output)
	singleton.apply(input, output)
end

function M.render_target()
	return singleton.render_target()
end



return M
