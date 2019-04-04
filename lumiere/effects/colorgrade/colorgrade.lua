local lumiere = require "lumiere.lumiere"

local M = {}

M.LUT_WIDTH = 256
M.LUT_HEIGHT = 16

local ready = false

function M.ready()
	ready = true
end

local script = nil

function M.script()
	script = msg.url()
end

function M.create(lut_filename)
	if lut_filename then
		timer.delay(0, false, function()
			msg.post(script, "update_lut", { file = lut_filename })
		end)
	end

	local instance = {}

	local predicate = nil

	local lut_target = nil
	

	function instance.init()
		predicate = lumiere.predicate({ hash("colorgrade") })
	end

	function instance.final()
		lumiere.delete_render_target(lut_target)
	end

	function instance.apply(input, output)
		if not ready then
			return
		end
		if not lut_target then
			lut_target = lumiere.create_render_target("colorgrade_lut", { color = true, width = M.LUT_WIDTH, height = M.LUT_HEIGHT })
			lut_target.update()
			lumiere.enable_render_target(lut_target)
			lumiere.use_screen_projection()
			lumiere.draw(lumiere.predicate({"colorgrade_lut"}))
			lumiere.disable_render_target(lut_target)
		end
		if output then lumiere.enable_render_target(output) end
		lumiere.set_identity_projection()
		lumiere.clear(lumiere.BLACK)
		lumiere.enable_texture(0, input)
		lumiere.enable_texture(1, lut_target)
		lumiere.draw(predicate)
		lumiere.disable_texture(0)
		lumiere.disable_texture(1)
		if output then lumiere.disable_render_target() end
	end

	return instance
end

local singleton = M.create()

function M.init()
	singleton.init()
end

function M.final()
	singleton.final()
end

function M.apply(input, output)
	singleton.apply(input, output)
end

return M