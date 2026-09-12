local lumiere = require("lumiere.lumiere")

local M = {}

local IDENTITY = vmath.matrix4()
local STRENGTH = nil
local PREDICATE = nil

function M.init(strength)
	STRENGTH = vmath.vector4(strength or 32, 0, 0, 0)
	PREDICATE = render.predicate({ hash("grain") })
end

function M.final()
end

function M.apply(input)
	local constants = render.constant_buffer()
	constants.strength = STRENGTH

	render.set_view(IDENTITY)
	render.set_projection(IDENTITY)
	render.clear({[graphics.BUFFER_TYPE_COLOR0_BIT] = lumiere.clear_color(), [graphics.BUFFER_TYPE_DEPTH_BIT] = 1})
	render.enable_texture(0, input, graphics.BUFFER_TYPE_COLOR0_BIT)
	render.draw(PREDICATE, { constants = constants })
	render.disable_texture(0)
end

return M