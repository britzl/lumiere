local lumiere = require "lumiere.lumiere"

local M = {}

local AMBIENT_LIGHT = vmath.vector4(0.1, 0.1, 0.1, 1.0)

local LIGHTS_PREDICATE = nil
local RT = nil

function M.init()
	assert(not RT)
	LIGHTS_PREDICATE = lumiere.predicate({ hash("light") })
	APPLY_LIGHTS_PREDICATE = lumiere.predicate({ hash("apply_lights") })
	RT = lumiere.create_render_target("apply_lights", true, false, false)
end

function M.final()
	lumiere.delete_render_target(RT)
	RT = nil
end

function M.update()
	lumiere.enable_render_target(RT)
	lumiere.set_constant("intensity", vmath.vector4(math.random(90, 100) / 100))
	lumiere.clear(AMBIENT_LIGHT)
	lumiere.draw(LIGHTS_PREDICATE)
	lumiere.disable_render_target()
	lumiere.reset_constant("intensity")
end

function M.apply(input, output)
	assert(input, "You must provide a render target to apply lights to")

	if output then lumiere.enable_render_target(output) end

	lumiere.set_identity_view_projection()
	lumiere.clear(lumiere.BLACK)
	lumiere.enable_texture(0, RT)
	lumiere.enable_texture(1, input)
	lumiere.draw(APPLY_LIGHTS_PREDICATE)
	lumiere.disable_texture(0)
	lumiere.disable_texture(1)

	if output then lumiere.disable_render_target() end
end

function M.render_target()
	return RT
end



return M