local lumiere = require "lumiere.lumiere"

local PRG = {}

function PRG.init(self)
	print("basic")
	self.distortion_pred = lumiere.predicate({ "distortion" })
end

function PRG.update(self, dt)
	lumiere.clear(lumiere.clear_color())
	lumiere.use_world_projection()
	lumiere.draw_graphics2d(self.distortion_pred)
	lumiere.use_screen_projection()
	lumiere.draw_gui()
end

return PRG