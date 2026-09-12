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

	local color_params = {
		format = graphics.TEXTURE_FORMAT_RGBA,
		width = LUT_WIDTH,
		height = LUT_HEIGHT,
		min_filter = graphics.TEXTURE_FILTER_LINEAR,
		mag_filter = graphics.TEXTURE_FILTER_LINEAR,
		u_wrap = graphics.TEXTURE_WRAP_CLAMP_TO_EDGE,
		v_wrap = graphics.TEXTURE_WRAP_CLAMP_TO_EDGE
	}

	LUT_RT = render.render_target({[graphics.BUFFER_TYPE_COLOR0_BIT] = color_params })	

	render.set_render_target(LUT_RT)
	render.set_camera()
	render.set_viewport(0, 0, LUT_WIDTH, LUT_HEIGHT)
	render.set_view(IDENTITY)
	render.set_projection(vmath.matrix4_orthographic(0, LUT_WIDTH, 0, LUT_HEIGHT, -1, 1))
	render.clear({[graphics.BUFFER_TYPE_COLOR0_BIT] = lumiere.clear_color()})
	render.draw(LUT_PREDICATE)
	render.set_render_target(render.RENDER_TARGET_DEFAULT)
end

function M.final()
	if LUT_RT then
		render.delete_render_target(LUT_RT)
		LUT_RT = nil
	end
end

function M.apply(input)
	render.set_view(IDENTITY)
	render.set_projection(IDENTITY)
	render.clear({[graphics.BUFFER_TYPE_COLOR0_BIT] = lumiere.clear_color()})
	render.enable_texture(0, input, graphics.BUFFER_TYPE_COLOR0_BIT)
	render.enable_texture(1, LUT_RT, graphics.BUFFER_TYPE_COLOR0_BIT)
	render.draw(APPLY_PREDICATE)
	render.disable_texture(0)
	render.disable_texture(1)
end

return M
