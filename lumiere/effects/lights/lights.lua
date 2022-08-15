local lumiere = require "lumiere.lumiere"

local M = {}

local AMBIENT_LIGHT = vmath.vector4(0.3, 0.3, 0.3, 1.0)
local INTENSITY_MIN = 0.8
local INTENSITY_MAX = 1.0
local IDENTITY = vmath.matrix4()
local LIGHT_PREDICATE = nil
local APPLY_PREDICATE = nil
local LIGHT_RT = nil

local intensity_v4 = vmath.vector4()

function M.init()
	LIGHT_PREDICATE = render.predicate({ hash("light") })
	APPLY_PREDICATE = render.predicate({ hash("apply_lights") })

	local color_params = { format = render.FORMAT_RGBA,
		width = render.get_window_width(),
		height = render.get_window_height(),
		min_filter = render.FILTER_LINEAR,
		mag_filter = render.FILTER_LINEAR,
		u_wrap = render.WRAP_CLAMP_TO_EDGE,
		v_wrap = render.WRAP_CLAMP_TO_EDGE }

	LIGHT_RT = render.render_target({[render.BUFFER_COLOR_BIT] = color_params })	
end

function M.final()
	render.delete_render_target(LIGHT_RT)
	LIGHT_RT = nil
end

function M.update()
	intensity_v4.x = INTENSITY_MIN + math.random() * (INTENSITY_MAX - INTENSITY_MIN)

	local constants = render.constant_buffer()
	constants.intensity = intensity_v4

	-- draw everything that is a light to a separet render target
	render.set_render_target(LIGHT_RT)
	render.clear({[render.BUFFER_COLOR_BIT] = lumiere.clear_color()})
	render.draw(LIGHT_PREDICATE, { constants = constants })
	render.set_render_target(render.RENDER_TARGET_DEFAULT)
end

function M.apply(input)
	local constants = render.constant_buffer()
	constants.time = lumiere.time()
	constants.ambient_light = AMBIENT_LIGHT
	
	render.set_view(IDENTITY)
	render.set_projection(IDENTITY)
	render.clear({[render.BUFFER_COLOR_BIT] = lumiere.clear_color(), [render.BUFFER_DEPTH_BIT] = 1})
	render.enable_texture(0, input, render.BUFFER_COLOR_BIT)
	render.enable_texture(1, LIGHT_RT, render.BUFFER_COLOR_BIT)
	render.draw(APPLY_PREDICATE, { constants = constants })
	render.disable_texture(0)
	render.disable_texture(1)
end


return M
