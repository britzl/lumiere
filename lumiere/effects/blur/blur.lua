local lumiere = require "lumiere.lumiere"

local M = {}

local IDENTITY = vmath.matrix4()
local PREDICATE = nil
local DISTANCE = 4

local distance_vector = vmath.vector4(DISTANCE, 0, 0, 0)

function M.init()
	PREDICATE = render.predicate({ hash("blur") })
end

function M.final()
end

function M.apply(input)
	local constants = render.constant_buffer()
	constants.resolution = lumiere.resolution()
	constants.distance = distance_vector
	
	render.set_view(IDENTITY)
	render.set_projection(IDENTITY)
	render.clear({[render.BUFFER_COLOR_BIT] = lumiere.clear_color(), [render.BUFFER_DEPTH_BIT] = 1})
	render.enable_texture(0, input, render.BUFFER_COLOR_BIT)
	render.draw(PREDICATE, { constants = constants })
	render.disable_texture(0)
end


return M