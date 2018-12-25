local lumiere = require "lumiere.lumiere"
local render_helper = require "orthographic.render.helper"

local PRG = {}

local BLACK = vmath.vector4(0)


function PRG.init(self)
	render_helper.init(self)

	self.predicates = self.predicates or {}
	self.predicates.tile = lumiere.predicate({"tile"})
	self.predicates.gui = lumiere.predicate({"gui"})
	self.predicates.text = lumiere.predicate({"text"})
	self.predicates.particle = lumiere.predicate({"particle"})
	self.predicates.grain = lumiere.predicate({ hash("grain") })

	self.normal_rt = lumiere.create_render_target("normal", true, false, false)

	self.time = vmath.vector4()
end

function PRG.final(self)
	lumiere.delete_render_target(self.normal_rt)
end

function PRG.update(self, dt)
	self.time.x = self.time.x + dt
	render_helper.update(self)

	render.set_viewport(0, 0, render.get_window_width(), render.get_window_height())

	-- draw graphics
	lumiere.set_view_projection(render_helper.world_view(self), render_helper.world_projection(self))
	lumiere.enable_render_target(self.normal_rt)
	lumiere.clear(BLACK)
	lumiere.draw(self.predicates.tile, self.predicates.particle)
	lumiere.disable_render_target()

	-- combine graphics and grain
	lumiere.set_view_projection()
	lumiere.set_constant("time", self.time)
	lumiere.enable_texture(0, self.normal_rt)
	lumiere.draw(self.predicates.grain)
	lumiere.disable_texture(0)

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