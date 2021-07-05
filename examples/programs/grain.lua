local lumiere = require "lumiere.lumiere"
local camera = require "orthographic.camera"
local graphics2d = require "lumiere.targets.graphics2d"
local grain = require "lumiere.effects.grain.grain"

local PRG = {}

function PRG.init(self)
	print("grain")
	grain.init()
	graphics2d.init()
end

function PRG.final(self)
	grain.final()
	graphics2d.final()
end

function PRG.update(self, dt)
	lumiere.set_viewport(camera.get_viewport())
	lumiere.set_world_projection(camera.get_view(), camera.get_projection())
		graphics2d.update()
	grain.apply(graphics2d.render_target())
	lumiere.set_screen_projection()
	lumiere.draw_gui()
end

function PRG.on_message(self, message_id, message, sender)
end

return PRG