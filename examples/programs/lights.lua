local lumiere = require "lumiere.lumiere"
local render_helper = require "orthographic.render.helper"

local PRG = {}

local BLACK = vmath.vector4(0)
local AMBIENT_LIGHT = vmath.vector4(0.1, 0.1, 0.1, 1.0)

function PRG.init(self)
	render_helper.init(self)

	self.predicates = self.predicates or {}
	self.predicates.tile = lumiere.predicate({"tile"})
	self.predicates.gui = lumiere.predicate({"gui"})
	self.predicates.text = lumiere.predicate({"text"})
	self.predicates.particle = lumiere.predicate({"particle"})
	self.predicates.light = lumiere.predicate({"light"})
	
	-- one render target for "normal" graphics and one for the lights
	-- both have a color buffer but no depth or stencil buffer
	self.normal_rt = lumiere.create_render_target("normal", true, false, false)
	self.light_rt = lumiere.create_render_target("lights", true, false, false)
end

function PRG.final(self)
	lumiere.delete_render_target(self.normal_rt)
	lumiere.delete_render_target(self.light_rt)
end

function PRG.update(self, dt)
	render_helper.update(self)

	render.set_viewport(0, 0, render.get_window_width(), render.get_window_height())

	-- draw graphics
	lumiere.set_view_projection(render_helper.world_view(self), render_helper.world_projection(self))
	lumiere.enable_render_target(self.normal_rt)
	lumiere.clear(BLACK)
	lumiere.draw(self.predicates.tile, self.predicates.particle)
	lumiere.disable_render_target()

	-- draw lights
	lumiere.set_view_projection(render_helper.world_view(self), render_helper.world_projection(self))
	lumiere.enable_render_target(self.light_rt)
	lumiere.set_constant("time", vmath.vector4(math.random(90, 100) / 100))
	lumiere.clear(AMBIENT_LIGHT)
	lumiere.draw(self.predicates.light)
	lumiere.disable_render_target()

	-- combine graphics and lights
	lumiere.set_view_projection()
	lumiere.multiply(self.normal_rt, self.light_rt)

	-- draw gui
	lumiere.set_view_projection(render_helper.screen_view(self), render_helper.screen_projection(self))
	render.enable_state(render.STATE_STENCIL_TEST)
	render.draw(self.predicates.gui)
	render.draw(self.predicates.text)
	render.disable_state(render.STATE_STENCIL_TEST)
end

function PRG.on_message(self, message_id, message, sender)
	render_helper.on_message(self, message_id, message, sender)
end

return PRG