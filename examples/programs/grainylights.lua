local lumiere = require "lumiere.lumiere"
local render_helper = require "orthographic.render.helper"

local PRG = {}

local BLACK = vmath.vector4(0)
local AMBIENT_LIGHT = vmath.vector4(0.1, 0.1, 0.1, 1.0)

function PRG.init(self)
	render_helper.init(self)

	self.predicates_tile = lumiere.predicate({"tile"})
	self.predicates_particle = lumiere.predicate({"particle"})
	self.predicates_light = lumiere.predicate({"light"})
	self.predicates_grain = lumiere.predicate({"grain"})

	self.normal_rt = lumiere.create_render_target("normal", true, false, false)
	self.lights_rt = lumiere.create_render_target("lights", true, false, false)
	self.applied_lights_rt = lumiere.create_render_target("applied_lights", true, false, false)
end

function PRG.final(self)
	lumiere.delete_render_target(self.normal_rt)
	lumiere.delete_render_target(self.lights_rt)
	lumiere.delete_render_target(self.applied_lights_rt)
end

function PRG.update(self, dt)
	render_helper.update(self)

	render.set_viewport(0, 0, render.get_window_width(), render.get_window_height())

	-- draw graphics
	lumiere.set_view_projection(render_helper.world_view(self), render_helper.world_projection(self))
	lumiere.enable_render_target(self.normal_rt)
	lumiere.clear(BLACK)
	lumiere.draw(self.predicates_tile, self.predicates_particle)
	lumiere.disable_render_target()
	
	-- draw lights
	lumiere.set_view_projection(render_helper.world_view(self), render_helper.world_projection(self))
	lumiere.enable_render_target(self.lights_rt)
	lumiere.set_constant("intensity", vmath.vector4(math.random(90, 100) / 100))
	lumiere.clear(AMBIENT_LIGHT)
	lumiere.draw(self.predicates_light)
	lumiere.disable_render_target()
	lumiere.reset_constant("intensity")
	
	-- combine graphics and lights
	lumiere.set_view_projection()
	lumiere.enable_render_target(self.applied_lights_rt)
	lumiere.clear(BLACK)
	lumiere.multiply(self.normal_rt, self.lights_rt)
	lumiere.disable_render_target()
	
	-- draw combined graphics and lights to screen and apply grain filter
	lumiere.set_view_projection()
	lumiere.clear(BLACK)
	lumiere.set_constant("time", lumiere.time())
	lumiere.enable_texture(0, self.applied_lights_rt)
	lumiere.draw(self.predicates_grain)
	lumiere.disable_texture(0)
	lumiere.reset_constant("time")

	-- draw gui
	lumiere.draw_gui(render_helper.screen_view(self), render_helper.screen_projection(self))
end

function PRG.on_message(self, message_id, message, sender)
	render_helper.on_message(self, message_id, message, sender)
end

return PRG