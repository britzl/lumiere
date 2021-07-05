local lumiere = require "lumiere.lumiere"
local camera = require "orthographic.camera"
local graphics2d = require "lumiere.targets.graphics2d"
local posteffects = require "lumiere.effects.posteffects"

local grain = require "lumiere.effects.grain.grain"
local blur = require "lumiere.effects.blur.blur"
local lights = require "lumiere.effects.lights.lights"
local lcd = require "lumiere.effects.lcd.lcd"
local chromatical = require "lumiere.effects.chromatical.chromatical"
local chromatic_aberration = require "lumiere.effects.chromatic_aberration.chromatic_aberration"
local scanlines = require "lumiere.effects.scanlines.scanlines"
local colorgrade = require "lumiere.effects.colorgrade.colorgrade"
local distortion = require "lumiere.effects.distortion.distortion"

local PRG = {}

function PRG.init(self)
	print("combo")
	graphics2d.init()

	self.posteffect = posteffects.create(distortion, lights, scanlines)
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
	posteffects.update(self.posteffect)
	posteffects.apply(self.posteffect, graphics2d.render_target())
	lumiere.set_screen_projection()
	lumiere.draw_gui()
end

function PRG.on_message(self, message_id, message, sender)
end

return PRG