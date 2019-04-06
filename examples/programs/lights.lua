local lumiere = require "lumiere.lumiere"
local render_helper = require "orthographic.render.helper"
local lights = require "lumiere.effects.lights.lights"
local graphics2d = require "lumiere.targets.graphics2d"

local PRG = {}

function PRG.init(self)
	print("lights")
	render_helper.init(self)
	lights.init()
	graphics2d.init()
end

function PRG.final(self)
	lights.final()
	graphics2d.final()
end

function PRG.update(self, dt)
	render_helper.update(self)

	lumiere.set_world_projection(render_helper.world_view(self), render_helper.world_projection(self))
	graphics2d.update()
	lights.update()
	lights.apply(graphics2d.render_target())
	lumiere.set_screen_projection(render_helper.screen_view(self), render_helper.screen_projection(self))
	lumiere.draw_gui()
end

function PRG.on_message(self, message_id, message, sender)
	render_helper.on_message(self, message_id, message, sender)
end

return PRG