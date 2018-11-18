local M = {}

assert(render, "You must require Lumiere from your render script")

local width = tonumber(sys.get_config("display.width"))
local height = tonumber(sys.get_config("display.height"))

local IDENTITY = vmath.matrix4()

local clear_buffers = {}

local quad_pred = nil


M.MATERIAL_MIX = hash("mix")
M.MATERIAL_COPY = hash("copy")
M.MATERIAL_MULTIPLY = hash("multiply")

function M.init()
	width = render.get_window_width()
	height = render.get_window_height()
	quad_pred = render.predicate({ hash("lumiere_quad") })
end


function M.clear(color, depth, stencil)
	if color then
		clear_buffers[render.BUFFER_COLOR_BIT] = color
	end

	if depth then
		render.set_depth_mask(true)
		clear_buffers[render.BUFFER_DEPTH_BIT] = depth
	end

	if stencil then
		render.set_stencil_mask(0xff)
		clear_buffers[render.BUFFER_STENCIL_BIT] = stencil
	end
	render.clear(clear_buffers)
end


function M.set_identity_view_projection()
	render.set_view(IDENTITY)
	render.set_projection(IDENTITY)
end


function M.draw(predicates, constants)
	if depth then
		render.set_depth_mask(true)
		render.enable_state(render.STATE_DEPTH_TEST)
	else
		render.set_depth_mask(false)
		render.disable_state(render.STATE_DEPTH_TEST)
	end

	if stencil then
		render.set_stencil_mask(0xff)
		render.enable_state(render.STATE_STENCIL_TEST)
	else
		render.disable_state(render.STATE_STENCIL_TEST)
	end

	render.disable_state(render.STATE_CULL_FACE)

	render.enable_state(render.STATE_BLEND)
	render.set_blend_func(render.BLEND_SRC_ALPHA, render.BLEND_ONE_MINUS_SRC_ALPHA)

	render.enable_render_target(render_target)
	for _,pred in ipairs(predicates) do
		render.draw(pred, constants)
	end
	render.disable_render_target(render_target)
end



function M.draw_render_targets(render_targets, material)
	material = material or M.MATERIAL_COPY
	
	render.set_depth_mask(false)
	render.disable_state(render.STATE_DEPTH_TEST)
	render.disable_state(render.STATE_STENCIL_TEST)
	render.disable_state(render.STATE_CULL_FACE)

	render.enable_state(render.STATE_BLEND)
	render.set_blend_func(render.BLEND_SRC_ALPHA, render.BLEND_ONE_MINUS_SRC_ALPHA)

	render.enable_material(material)
	for i=1,#render_targets do
		render.enable_texture(i - 1, render_targets[i].render_target, render.BUFFER_COLOR_BIT)
	end
	render.draw(quad_pred)
	for i=1,#render_targets do
		render.disable_texture(i - 1, render_targets[i].render_target, render.BUFFER_COLOR_BIT)
	end
	render.disable_material()
end


function M.create_quad(predicate)
	assert(predicate, "You must provide a predicate")
	local instance = {}

	function instance.clear(color, depth, stencil)
		M.clear(color, depth, stencil)
	end

	return instance
end







function M.create_render_target(name, color, depth, stencil)
	assert(name, "You must specify a name")

	local instance = {
		name = name,
		color = color,
		depth = depth,
		stencil = stencil,
		render_target = nil,
	}

	local function init(width, height)
		instance.width = width
		instance.height = height

		local color_params = nil
		if color then
			color_params = { 
				format = render.FORMAT_RGBA,
				width = width,
				height = height,
				min_filter = render.FILTER_LINEAR,
				mag_filter = render.FILTER_LINEAR,
				u_wrap = render.WRAP_CLAMP_TO_EDGE,
				v_wrap = render.WRAP_CLAMP_TO_EDGE
			}
		end

		local depth_params = nil
		if depth then
			depth_params = {
				format = render.FORMAT_DEPTH,
				width = width,
				height = height,
				u_wrap = render.WRAP_CLAMP_TO_EDGE,
				v_wrap = render.WRAP_CLAMP_TO_EDGE
			}
		end

		local stencil_params = nil
		if stencil then
			stencil_params = {
				format = render.FORMAT_STENCIL,
				width = width,
				height = height,
				u_wrap = render.WRAP_CLAMP_TO_EDGE,
				v_wrap = render.WRAP_CLAMP_TO_EDGE
			}
		end

		instance.render_target = render.render_target(name, {
			[render.BUFFER_COLOR_BIT] = color_params,
			[render.BUFFER_DEPTH_BIT] = depth_params,
			[render.BUFFER_STENCIL_BIT] = stencil_params,
		})
	end
	


	function instance.update()
		local window_width = render.get_window_width()
		local window_height = render.get_window_height()

		-- recreate render targets if screen size has changed
		if instance.width ~= window_width or instance.height ~= window_height then
			init(window_width, window_height)
		end
	end

	function instance.clear(clear_color, clear_depth, clear_stencil)
		render.enable_render_target(instance.render_target)
		M.clear(color and clear_color, depth and clear_depth, stencil and clear_stencil)
		render.disable_render_target(instance.render_target)
	end

	function instance.draw(predicates, constants)
		if depth then
			render.set_depth_mask(true)
			render.enable_state(render.STATE_DEPTH_TEST)
		else
			render.set_depth_mask(false)
			render.disable_state(render.STATE_DEPTH_TEST)
		end

		if stencil then
			render.set_stencil_mask(0xff)
			render.enable_state(render.STATE_STENCIL_TEST)
		else
			render.disable_state(render.STATE_STENCIL_TEST)
		end
		
		render.disable_state(render.STATE_CULL_FACE)
		
		render.enable_state(render.STATE_BLEND)
		render.set_blend_func(render.BLEND_SRC_ALPHA, render.BLEND_ONE_MINUS_SRC_ALPHA)

		render.enable_render_target(instance.render_target)
		for _,pred in ipairs(predicates) do
			render.draw(pred, constants)
		end
		render.disable_render_target(instance.render_target)
	end
	

	return instance
end



return M