local lumiere = require "lumiere.lumiere"
local render_helper = require "orthographic.render.helper"

local PRG = {}

local BLACK = vmath.vector4(0)
local AMBIENT_LIGHT = vmath.vector4(0.1, 0.1, 0.1, 1.0)

function PRG.init(self)
	render_helper.init(self)

	self.tile_pred = render.predicate({"tile"})
	self.gui_pred = render.predicate({"gui"})
	self.text_pred = render.predicate({"text"})
	self.particle_pred = render.predicate({"particle"})
	self.light_pred = render.predicate({"light"})
	self.apply_light_pred = render.predicate({"apply_light"})
	
	self.normal_rt = lumiere.create_render_target("normal", true, false, false)
	self.light_rt = lumiere.create_render_target("lights", true, false, false)
	self.applied_light_rt = lumiere.create_render_target("applied_lights", true, false, false)
	
	self.time = vmath.vector4()
	self.grain_predicate = render.predicate({ hash("grain") })
end

function PRG.final(self)
	self.normal_rt.delete()
	self.light_rt.delete()
	self.applied_light_rt.delete()
end

function PRG.update(self, dt)
	self.time.x = self.time.x + dt
	render_helper.update(self)

	self.normal_rt.update()
	self.light_rt.update()
	self.applied_light_rt.update()

	render.set_viewport(0, 0, render.get_window_width(), render.get_window_height())

	-- draw graphics
	lumiere.set_view_projection(render_helper.world_view(self), render_helper.world_projection(self))
	self.normal_rt.clear(BLACK)
	self.normal_rt.draw({ self.tile_pred, self.particle_pred })

	-- draw lights
	lumiere.set_view_projection(render_helper.world_view(self), render_helper.world_projection(self))
	self.light_rt.set_constant("time", vmath.vector4(math.random(90, 100) / 100))
	self.light_rt.clear(AMBIENT_LIGHT)
	self.light_rt.draw({ self.light_pred })

	-- combine graphics and lights
	lumiere.set_view_projection()
	self.applied_light_rt.clear(BLACK)
	self.applied_light_rt.multiply({ self.normal_rt, self.light_rt })

	-- draw combined graphics and lights to screen and apply grain filter
	lumiere.set_view_projection()
	lumiere.clear(BLACK, nil, nil)
	lumiere.set_constant("time", self.time)
	lumiere.draw({ self.applied_light_rt }, self.grain_predicate)
	lumiere.reset_constants()

	-- draw gui
	lumiere.set_view_projection(render_helper.screen_view(self), render_helper.screen_projection(self))
	render.enable_state(render.STATE_STENCIL_TEST)
	render.draw(self.gui_pred)
	render.draw(self.text_pred)
	render.disable_state(render.STATE_STENCIL_TEST)
end

function PRG.on_message(self, message_id, message, sender)
	render_helper.on_message(self, message_id, message, sender)
end

return PRG