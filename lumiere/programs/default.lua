local M = {}

--
-- projection that centers content with maintained aspect ratio and optional zoom
--
local function fixed_projection(near, far, zoom)
	local projected_width = render.get_window_width() / (zoom or 1)
	local projected_height = render.get_window_height() / (zoom or 1)
	local xoffset = -(projected_width - render.get_width()) / 2
	local yoffset = -(projected_height - render.get_height()) / 2
	return vmath.matrix4_orthographic(xoffset, xoffset + projected_width, yoffset, yoffset + projected_height, near, far)
end
--
-- projection that centers and fits content with maintained aspect ratio
--
local function fixed_fit_projection(near, far)
	local width = render.get_width()
	local height = render.get_height()
	local window_width = render.get_window_width()
	local window_height = render.get_window_height()
	local zoom = math.min(window_width / width, window_height / height)
	return fixed_projection(near, far, zoom)
end
--
-- projection that stretches content
--
local function stretch_projection(near, far)
	return vmath.matrix4_orthographic(0, render.get_width(), 0, render.get_height(), near, far)
end

function M.init(self)
	self.tile_pred = render.predicate({"tile"})
	self.gui_pred = render.predicate({"gui"})
	self.text_pred = render.predicate({"text"})
	self.particle_pred = render.predicate({"particle"})

	self.clear_color = vmath.vector4(0, 0, 0, 0)
	self.clear_color.x = sys.get_config("render.clear_color_red", 0)
	self.clear_color.y = sys.get_config("render.clear_color_green", 0)
	self.clear_color.z = sys.get_config("render.clear_color_blue", 0)
	self.clear_color.w = sys.get_config("render.clear_color_alpha", 0)

	self.view = vmath.matrix4()
end

function M.update(self)
	render.set_depth_mask(true)
	render.set_stencil_mask(0xff)
	render.clear({[render.BUFFER_COLOR_BIT] = self.clear_color, [render.BUFFER_DEPTH_BIT] = 1, [render.BUFFER_STENCIL_BIT] = 0})

	render.set_viewport(0, 0, render.get_window_width(), render.get_window_height())
	render.set_view(self.view)

	render.set_depth_mask(false)
	render.disable_state(render.STATE_DEPTH_TEST)
	render.disable_state(render.STATE_STENCIL_TEST)
	render.enable_state(render.STATE_BLEND)
	render.set_blend_func(render.BLEND_SRC_ALPHA, render.BLEND_ONE_MINUS_SRC_ALPHA)
	render.disable_state(render.STATE_CULL_FACE)

	-- default is stretch projection. copy from builtins and change for different projection
	--
	render.set_projection(stretch_projection(-1, 1))

	render.draw(self.tile_pred)
	render.draw(self.particle_pred)
	render.draw_debug3d()

	-- render GUI
	--
	render.set_view(vmath.matrix4())
	render.set_projection(vmath.matrix4_orthographic(0, render.get_window_width(), 0, render.get_window_height(), -1, 1))

	render.enable_state(render.STATE_STENCIL_TEST)
	render.draw(self.gui_pred)
	render.draw(self.text_pred)
	render.disable_state(render.STATE_STENCIL_TEST)

	render.set_depth_mask(false)
	render.draw_debug2d()
end

function M.on_message(self, message_id, message, sender)
	if message_id == hash("clear_color") then
		self.clear_color = message.color
	elseif message_id == hash("set_view_projection") then
		self.view = message.view
	end
end

return M