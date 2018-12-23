local lumiere = require "lumiere.lumiere"
local render_helper = require "orthographic.render.helper"

local PRG = {}

local BLACK = vmath.vector4(0)
local AMBIENT_LIGHT = vmath.vector4(0.1, 0.1, 0.1, 1.0)

function PRG.init(self)
	render_helper.init(self)

	if not self.predicates then
		self.predicates = {}
		self.predicates.tile = render.predicate({"tile"})
		self.predicates.gui = render.predicate({"gui"})
		self.predicates.text = render.predicate({"text"})
		self.predicates.particle = render.predicate({"particle"})
		self.predicates.light = render.predicate({"light"})
	end
	
	-- one render target for "normal" graphics and one for the lights
	-- both have a color buffer but no depth or stencil buffer
	self.normal_rt = lumiere.create_render_target("normal", true, false, false)
	self.light_rt = lumiere.create_render_target("lights", true, false, false)
end

function PRG.final(self)
	self.normal_rt.delete()
	self.light_rt.delete()
end

function PRG.update(self, dt)
	render_helper.update(self)

	self.normal_rt.update()
	self.light_rt.update()

	render.set_viewport(0, 0, render.get_window_width(), render.get_window_height())

	-- draw graphics
	lumiere.set_view_projection(render_helper.world_view(self), render_helper.world_projection(self))
	self.normal_rt.clear(BLACK)
	self.normal_rt.draw({ self.predicates.tile, self.predicates.particle })

	-- draw lights
	lumiere.set_view_projection(render_helper.world_view(self), render_helper.world_projection(self))
	self.light_rt.set_constant("time", vmath.vector4(math.random(90, 100) / 100))
	self.light_rt.clear(AMBIENT_LIGHT)
	self.light_rt.draw({ self.predicates.light })

	-- combine graphics and lights
	lumiere.set_view_projection()
	lumiere.clear(BLACK, nil, nil)
	lumiere.multiply({ self.normal_rt, self.light_rt })

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