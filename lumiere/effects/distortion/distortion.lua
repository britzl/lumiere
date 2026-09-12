local lumiere = require "lumiere.lumiere"

local M = {}

local IDENTITY = vmath.matrix4()
local DISTORTION_PREDICATE = nil
local APPLY_PREDICATE = nil
local DISTORTION_RT = nil

function M.init()
	DISTORTION_PREDICATE = render.predicate({ hash("distortion") })
	APPLY_PREDICATE = render.predicate({ hash("apply_distortion") })

	local color_params = { format = graphics.TEXTURE_FORMAT_RGBA,
		width = render.get_window_width(),
		height = render.get_window_height(),
		min_filter = graphics.TEXTURE_FILTER_LINEAR,
		mag_filter = graphics.TEXTURE_FILTER_LINEAR,
		u_wrap = graphics.TEXTURE_WRAP_CLAMP_TO_EDGE,
		v_wrap = graphics.TEXTURE_WRAP_CLAMP_TO_EDGE }

	DISTORTION_RT = render.render_target({[graphics.BUFFER_TYPE_COLOR0_BIT] = color_params })	
end

function M.final()
	render.delete_render_target(DISTORTION_RT)
	DISTORTION_RT = nil
end

function M.update()
	-- distortion mask
	-- draw everything that should be distorted
	render.set_render_target(DISTORTION_RT)
	render.clear({[graphics.BUFFER_TYPE_COLOR0_BIT] = lumiere.clear_color(), [graphics.BUFFER_TYPE_DEPTH_BIT] = 1})
	render.draw(DISTORTION_PREDICATE)
	render.set_render_target(render.RENDER_TARGET_DEFAULT)
end

function M.apply(input)
	-- apply distortion by combining the mask and input
	render.set_view(IDENTITY)
	render.set_projection(IDENTITY)
	render.clear({[graphics.BUFFER_TYPE_COLOR0_BIT] = lumiere.clear_color(), [graphics.BUFFER_TYPE_DEPTH_BIT] = 1})
	render.enable_texture(0, input, graphics.BUFFER_TYPE_COLOR0_BIT)
	render.enable_texture(1, DISTORTION_RT, graphics.BUFFER_TYPE_COLOR0_BIT)
	render.draw(APPLY_PREDICATE)
	render.disable_texture(0)
	render.disable_texture(1)
end


return M