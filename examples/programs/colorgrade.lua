local lumiere = require "lumiere.lumiere"
local camera = require "orthographic.camera"
local graphics2d = require "lumiere.targets.graphics2d"

local colorgrade = require "lumiere.effects.colorgrade.colorgrade"
local posteffects = require "lumiere.effects.posteffects"

local PRG = {}

function PRG.init(self)
	print("colorgrade")
	graphics2d.init()

	self.posteffect = posteffects.create(colorgrade.create("/examples/assets/custom/colorgrade_lut16.png"))
	posteffects.init(self.posteffect)
end

function PRG.final(self)
	graphics2d.final()
	posteffects.final(self.posteffect)
end

function PRG.update(self, dt)
	lumiere.set_viewport(camera.get_viewport())
	lumiere.set_world_projection(camera.get_view(), camera.get_projection())
	graphics2d.update()
	posteffects.apply(self.posteffect, graphics2d.render_target())
	lumiere.set_screen_projection()
	lumiere.draw_gui()
end

function PRG.on_message(self, message_id, message, sender)
end

return PRG