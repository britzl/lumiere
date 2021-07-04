local lumiere = require "lumiere.lumiere"
local render_helper = require "orthographic.render.helper"
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
	render_helper.init(self)
	graphics2d.init()

	self.posteffect = posteffects.create(distortion, lights, scanlines)
	posteffects.init(self.posteffect)
end

function PRG.final(self)
	graphics2d.final()
	posteffects.final(self.posteffect)
end

function PRG.update(self, dt)
	render_helper.update(self)

	lumiere.set_world_projection(render_helper.world_view(self), render_helper.world_projection(self))
	graphics2d.update()
	posteffects.update(self.posteffect)
	posteffects.apply(self.posteffect, graphics2d.render_target())
	lumiere.set_screen_projection(render_helper.screen_view(self), render_helper.screen_projection(self))
	lumiere.draw_gui()
end

function PRG.on_message(self, message_id, message, sender)
	render_helper.on_message(self, message_id, message, sender)
end

return PRG