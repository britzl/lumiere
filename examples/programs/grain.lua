local lumiere = require "lumiere.lumiere"
local render_helper = require "orthographic.render.helper"
local graphics2d = require "examples.programs.utils.graphics2d"
local grain = require "lumiere.effects.grain.grain"

local PRG = {}

function PRG.init(self)
	print("grain")
	grain.init()
	graphics2d.init()
	render_helper.init(self)
end

function PRG.final(self)
	grain.final()
	graphics2d.final()
end

function PRG.update(self, dt)
	render_helper.update(self)

	lumiere.set_world_projection(render_helper.world_view(self), render_helper.world_projection(self))
	graphics2d.update()
	grain.apply(graphics2d.render_target())
	lumiere.set_screen_projection(render_helper.screen_view(self), render_helper.screen_projection(self))
	lumiere.draw_gui()
end

function PRG.on_message(self, message_id, message, sender)
	render_helper.on_message(self, message_id, message, sender)
end

return PRG