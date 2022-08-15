local lumiere = require "lumiere.lumiere"

local M = {}

local IDENTITY = vmath.matrix4()
local APPLY_PREDICATE = nil
local LUT_PREDICATE = nil
local LUT_RT = nil
local LUT_WIDTH = 256
local LUT_HEIGHT = 16

function M.init()
	APPLY_PREDICATE = render.predicate({ hash("colorgrade") })
	LUT_PREDICATE = render.predicate({ hash("colorgrade_lut") })
end

function M.final()
	if LUT_RT then
		render.delete_render_target(LUT_RT)
		LUT_RT = nil
	end
end

function M.update()
	if not LUT_RT then
		local color_params = { format = render.FORMAT_RGBA,
			width = LUT_WIDTH,
			height = LUT_HEIGHT,
			min_filter = render.FILTER_LINEAR,
			mag_filter = render.FILTER_LINEAR,
			u_wrap = render.WRAP_CLAMP_TO_EDGE,
			v_wrap = render.WRAP_CLAMP_TO_EDGE }

		LUT_RT = render.render_target({[render.BUFFER_COLOR_BIT] = color_params })	

		render.set_render_target(LUT_RT)
		render.set_view(IDENTITY)
		render.set_projection(vmath.matrix4_orthographic(0, render.get_window_width(), 0, render.get_window_height(), -1, 1))
		render.clear({[render.BUFFER_COLOR_BIT] = lumiere.clear_color()})
		render.draw(LUT_PREDICATE)
		render.set_render_target(render.RENDER_TARGET_DEFAULT)
	end
end

function M.apply(input)
	render.set_view(IDENTITY)
	render.set_projection(IDENTITY)
	render.clear({[render.BUFFER_COLOR_BIT] = lumiere.clear_color()})
	render.enable_texture(0, input, render.BUFFER_COLOR_BIT)
	render.enable_texture(1, LUT_RT, render.BUFFER_COLOR_BIT)
	render.draw(APPLY_PREDICATE)
	render.disable_texture(0)
	render.disable_texture(1)
end

return M