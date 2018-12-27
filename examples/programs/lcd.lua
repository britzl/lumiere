local lumiere = require "lumiere.lumiere"
local render_helper = require "orthographic.render.helper"
local graphics2d = require "examples.effects.graphics2d"
local lcd = require "examples.effects.lcd.lcd"

local PRG = {}


function PRG.init(self)
	render_helper.init(self)
	lcd.init()
	graphics2d.init()
end

function PRG.final(self)
	lcd.final()
	graphics2d.final()
end


function PRG.update(self, dt)
	render_helper.update(self)

	render.set_viewport(0, 0, render.get_window_width(), render.get_window_height())

	lumiere.set_view_projection(render_helper.world_view(self), render_helper.world_projection(self))

	graphics2d.update()
	lcd.apply(graphics2d.render_target())
	lumiere.draw_gui(render_helper.screen_view(self), render_helper.screen_projection(self))
end

function PRG.on_message(self, message_id, message, sender)
	render_helper.on_message(self, message_id, message, sender)
end

return PRG