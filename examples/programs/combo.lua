local lumiere = require "lumiere.lumiere"
local render_helper = require "orthographic.render.helper"
local grain = require "examples.effects.grain.grain"
local lights = require "examples.effects.lights.lights"
local graphics2d = require "examples.effects.graphics2d"
local lcd = require "examples.effects.lcd.lcd"
local chromatical = require "examples.effects.chromatical.chromatical"
local chromatic_aberration = require "examples.effects.chromatic_aberration.chromatic_aberration"
local scanlines = require "examples.effects.scanlines.scanlines"

local PRG = {}

local BLACK = vmath.vector4(0)
local AMBIENT_LIGHT = vmath.vector4(0.1, 0.1, 0.1, 1.0)

function PRG.init(self)
	render_helper.init(self)
	grain.init()
	lights.init()
	graphics2d.init()
	lcd.init()
	chromatical.init()
	chromatic_aberration.init()
	scanlines.init()

	self.applied_lights_rt = lumiere.create_render_target("applied_lights", true, false, false)
	self.applied_grain_rt = lumiere.create_render_target("applied_grain", true, false, false)
end

function PRG.final(self)
	grain.final()
	lights.final()
	graphics2d.final()
	lcd.final()
	chromatical.final()
	chromatic_aberration.final()
	scanlines.final()

	lumiere.delete_render_target(self.applied_lights_rt)
	lumiere.delete_render_target(self.applied_grain_rt)
end

function PRG.update(self, dt)
	render_helper.update(self)

	render.set_viewport(0, 0, render.get_window_width(), render.get_window_height())

	lumiere.set_view_projection(render_helper.world_view(self), render_helper.world_projection(self))
	graphics2d.update()
	lights.update()

	lights.apply(graphics2d.render_target(), self.applied_lights_rt)
	scanlines.apply(self.applied_lights_rt)
	--grain.apply(self.applied_lights_rt, self.applied_grain_rt)
	--lcd.apply(self.applied_grain_rt)

	lumiere.draw_gui(render_helper.screen_view(self), render_helper.screen_projection(self))
end

function PRG.on_message(self, message_id, message, sender)
	render_helper.on_message(self, message_id, message, sender)
end

return PRG