local lumiere = require "lumiere.lumiere"
local render_helper = require "orthographic.render.helper"

local PRG = {}

local BLACK = vmath.vector4(0)


function PRG.init(self)
	render_helper.init(self)

	self.predicates_tile = lumiere.predicate({"tile"})
	self.predicates_particle = lumiere.predicate({"particle"})
	self.predicates_grain = lumiere.predicate({ hash("grain") })

	self.normal_rt = lumiere.create_render_target("normal", true, false, false)
end

function PRG.final(self)
	lumiere.delete_render_target(self.normal_rt)
end

function PRG.update(self, dt)
	render_helper.update(self)

	render.set_viewport(0, 0, render.get_window_width(), render.get_window_height())

	-- draw graphics to a render target
	lumiere.set_view_projection(render_helper.world_view(self), render_helper.world_projection(self))
	lumiere.enable_render_target(self.normal_rt)
	lumiere.clear(BLACK)
	lumiere.draw(self.predicates_tile, self.predicates_particle)
	lumiere.disable_render_target()

	-- draw graphics to screen and apply grain
	lumiere.set_view_projection()
	lumiere.set_constant("time", lumiere.time())
	lumiere.clear(BLACK)
	lumiere.enable_texture(0, self.normal_rt)
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