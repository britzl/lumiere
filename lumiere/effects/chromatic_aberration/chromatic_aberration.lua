local lumiere = require "lumiere.lumiere"

local M = {}

local IDENTITY = vmath.matrix4()
local PREDICATE = nil

function M.init()
	PREDICATE = render.predicate({ hash("chromatic_aberration") })
end

function M.final()
end

function M.apply(input)
	render.set_view(IDENTITY)
	render.set_projection(IDENTITY)
	render.clear({[graphics.BUFFER_TYPE_COLOR0_BIT] = lumiere.clear_color(), [graphics.BUFFER_TYPE_DEPTH_BIT] = 1})
	render.enable_texture(0, input, graphics.BUFFER_TYPE_COLOR0_BIT)
	render.draw(PREDICATE)
	render.disable_texture(0)
end

return M
