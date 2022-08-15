local lumiere = require "lumiere.lumiere"

local M = {}

local IDENTITY = vmath.matrix4()
local DISTORTION_PREDICATE = nil
local APPLY_PREDICATE = nil
local DISTORTION_RT = nil

function M.init()
	DISTORTION_PREDICATE = render.predicate({ hash("distortion") })
	APPLY_PREDICATE = render.predicate({ hash("apply_distortion") })

	local color_params = { format = render.FORMAT_RGBA,
		width = render.get_window_width(),
		height = render.get_window_height(),
		min_filter = render.FILTER_LINEAR,
		mag_filter = render.FILTER_LINEAR,
		u_wrap = render.WRAP_CLAMP_TO_EDGE,
		v_wrap = render.WRAP_CLAMP_TO_EDGE }

	DISTORTION_RT = render.render_target({[render.BUFFER_COLOR_BIT] = color_params })	
end

function M.final()
	render.delete_render_target(DISTORTION_RT)
	DISTORTION_RT = nil
end

function M.update()
	-- distortion mask
	-- draw everything that should be distorted
	render.set_render_target(DISTORTION_RT)
	render.clear({[render.BUFFER_COLOR_BIT] = lumiere.clear_color(), [render.BUFFER_DEPTH_BIT] = 1})
	render.draw(DISTORTION_PREDICATE)
	render.set_render_target(render.RENDER_TARGET_DEFAULT)
end

function M.apply(input)
	local constants = render.constant_buffer()
	constants.time = lumiere.time()

	-- apply distortion by combining the mask and input
	render.set_view(IDENTITY)
	render.set_projection(IDENTITY)
	render.clear({[render.BUFFER_COLOR_BIT] = lumiere.clear_color(), [render.BUFFER_DEPTH_BIT] = 1})
	render.enable_texture(0, input, render.BUFFER_COLOR_BIT)
	render.enable_texture(1, DISTORTION_RT, render.BUFFER_COLOR_BIT)
	render.draw(APPLY_PREDICATE, { constants = constants })
	render.disable_texture(0)
	render.disable_texture(1)
end


return M