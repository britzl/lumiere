local lumiere = require("lumiere.lumiere")
local camera = require "orthographic.camera"

local CAMERA_ID = hash("/camera")

local M = {}

function M.init(self)
	lumiere.init()

	self.tile_pred = render.predicate({"tile"})
	self.gui_pred = render.predicate({"gui"})
	self.text_pred = render.predicate({"text"})
	self.particle_pred = render.predicate({"particle"})

	self.projection = vmath.matrix4()
	self.view = vmath.matrix4()
end

function M.final(self)
	lumiere.final()
end

function M.update(self, dt)
	lumiere.update(dt)

	local window_width = render.get_window_width()
	local window_height = render.get_window_height()
	if window_width == 0 or window_height == 0 then
		return
	end

	-- update from camera
	--
	self.view = camera.get_view(CAMERA_ID)
	self.projection = camera.get_projection(CAMERA_ID)
	self.viewport = camera.get_viewport(CAMERA_ID)

	-- clear screen buffers
	--
	render.set_depth_mask(true)
	render.set_stencil_mask(0xff)
	render.clear({[render.BUFFER_COLOR_BIT] = lumiere.clear_color(), [render.BUFFER_DEPTH_BIT] = 1, [render.BUFFER_STENCIL_BIT] = 0})

	-- render world (sprites, tilemaps, particles etc)
	--
	render.set_viewport(self.viewport.x, self.viewport.y, self.viewport.z, self.viewport.w)
	render.set_view(self.view)
	render.set_projection(self.projection)

	render.set_depth_mask(false)
	render.disable_state(render.STATE_DEPTH_TEST)
	render.disable_state(render.STATE_STENCIL_TEST)
	render.enable_state(render.STATE_BLEND)
	render.set_blend_func(render.BLEND_SRC_ALPHA, render.BLEND_ONE_MINUS_SRC_ALPHA)
	render.disable_state(render.STATE_CULL_FACE)

	-- draw world space content and apply effects
	lumiere.draw(function()
		local frustum = self.projection * self.view
		render.draw(self.tile_pred, { frustum = frustum })
		render.draw(self.particle_pred, { frustum = frustum })
	end)
	render.draw_debug3d()
	
	-- render GUI
	--
	local view_gui = vmath.matrix4()
	local proj_gui = vmath.matrix4_orthographic(0, window_width, 0, window_height, -1, 1)
	local frustum_gui = proj_gui * view_gui

	render.set_view(view_gui)
	render.set_projection(proj_gui)

	render.enable_state(render.STATE_STENCIL_TEST)
	render.draw(self.gui_pred, { frustum = frustum_gui })
	render.draw(self.text_pred, { frustum = frustum_gui })
	render.disable_state(render.STATE_STENCIL_TEST)
end

function M.on_message(self, message_id, message, sender)
	lumiere.on_message(message_id, message, sender)
end


return M