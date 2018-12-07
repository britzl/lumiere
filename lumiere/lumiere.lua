
local M = {}

assert(render, "You must require Lumiere from your render script")

local width = tonumber(sys.get_config("display.width"))
local height = tonumber(sys.get_config("display.height"))

local IDENTITY = vmath.matrix4()

local clear_buffers = {}

local quad_pred = nil


local USE_PROGRAM = hash("lumiere_use_program")
local REMOVE_PROGRAM = hash("lumiere_remove_program")

local programs = {}
local current_program = nil




M.MATERIAL_MIX = hash("mix")
M.MATERIAL_COPY = hash("copy")
M.MATERIAL_MULTIPLY = hash("multiply")


-- call render.clear() with specified settings
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



-- set view projection to specified matrices
function M.set_view_projection(view, projection)
	render.set_view(view or IDENTITY)
	render.set_projection(projection or IDENTITY)
end


-- set view projection to identity matrix
function M.set_identity_view_projection()
	render.set_view(IDENTITY)
	render.set_projection(IDENTITY)
end


-- draw one or more render target to the Lumiere quad
-- the render targets will be set as textures and drawn
-- using the provided material
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


-- create a render target
-- @param name
-- @param color
-- @param depth
-- @param stencil
function M.create_render_target(name, color, depth, stencil)
	assert(name, "You must specify a name")

	local instance = {
		name = name,
		color = color,
		depth = depth,
		stencil = stencil,
		render_target = nil,
		constants = {},
	}

	local blend_mode = {
		source_factor = render.BLEND_SRC_ALPHA,
		dest_factor = render.BLEND_ONE_MINUS_SRC_ALPHA,
	}

	-- initialize/create render target
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

	-- update the render target if the width or height has changed
	function instance.update()
		local window_width = render.get_window_width()
		local window_height = render.get_window_height()

		-- recreate render targets if screen size has changed
		if instance.width ~= window_width or instance.height ~= window_height then
			init(window_width, window_height)
		end
	end

	function instance.delete()
		assert(instance.render_target, "Render target has already been deleted")
		render.delete_render_target(instance.render_target)
		instance.render_target = nil
	end

	-- clear the render target with a color, depth and stencil
	-- depending on render target settings
	function instance.clear(clear_color, clear_depth, clear_stencil)
		render.enable_render_target(instance.render_target)
		M.clear(color and clear_color, depth and clear_depth, stencil and clear_stencil)
		render.disable_render_target(instance.render_target)
	end

	-- set a render constant
	function instance.constant(key, value)
		assert(key, "You must provide a constant key")
		instance.constants[key] = value
	end

	-- set blend mode
	function instance.blend_mode(source_factor, dest_factor)
		blend_mode.source_factor = source_factor
		blend_mode.dest_factor = dest_factor
	end

	-- draw predicates to render target
	function instance.draw(predicates)
		assert(predicates, "You must provide a list of predicates")
		-- enable/disable depth mask
		if depth then
			render.set_depth_mask(true)
			render.enable_state(render.STATE_DEPTH_TEST)
		else
			render.set_depth_mask(false)
			render.disable_state(render.STATE_DEPTH_TEST)
		end

		-- enable/disable stencil mask
		if stencil then
			render.set_stencil_mask(0xff)
			render.enable_state(render.STATE_STENCIL_TEST)
		else
			render.disable_state(render.STATE_STENCIL_TEST)
		end

		-- disable polygon culling
		render.disable_state(render.STATE_CULL_FACE)

		-- set blend mode
		render.enable_state(render.STATE_BLEND)
		render.set_blend_func(blend_mode.source_factor, blend_mode.dest_factor)

		-- create constant buffer
		local constants = nil
		if next(instance.constants) then
			constants = render.constant_buffer()
			for k,v in pairs(instance.constants) do
				constants[k] = v
			end
		end

		-- enable, render, disable
		render.enable_render_target(instance.render_target)
		for _,pred in ipairs(predicates) do
			render.draw(pred, constants)
		end
		render.disable_render_target(instance.render_target)
	end

	return instance
end


function M.init(self)
	width = render.get_window_width()
	height = render.get_window_height()
	quad_pred = render.predicate({ hash("lumiere_quad") })
end

function M.final(self)
	print("final", current_program, current_program.final)
	if current_program.final then
		current_program.final(current_program.context)
	end
end

function M.update(self)
	if current_program.update then
		current_program.update(current_program.context)
	end
end


function M.on_message(self, message_id, message, sender)
	if message_id == USE_PROGRAM then
		local id = message.id
		assert(id, "You must provide a program id")
		assert(programs[id], "You must provide a valid program id")
		if current_program == programs[id] then
			print("Program already in use")
			return
		end
		if current_program and current_program.final then
			current_program.final(current_program.context)
		end
		current_program = programs[id]
		if current_program.init then
			current_program.init(current_program.context)
		end
	elseif message_id == REMOVE_PROGRAM then
		local id = message.id
		assert(id, "You must provide a program id")
		assert(programs[id], "You must provide a valid program id")
		if current_program == programs[id] then
			current_program.final(current_program.context)
			current_program = programs["default"]
		end
		programs[id] = nil
	elseif current_program.on_message then
		current_program.on_message(current_program.context, message_id, message, sender)
	end
end

function M.on_reload(self)
	if current_program.on_reload then
		current_program.on_reload(current_program.context)
	end
end

function M.add_program(id, program)
	assert(id, "You must provide a program id")
	assert(program and type(program) == "table", "You must provide a program")
	programs[id] = {
		id = id,
		context = {},
		init = program.init,
		update = program.update,
		final = program.final,
		on_message = program.on_message,
		on_reload = program.on_reload,
	}
end

function M.use_program(id)
	assert(id, "You must provide a program id")
	assert(programs[id], "You must provide a valid program id")
	msg.post("@render:", USE_PROGRAM, { id = id })
end

function M.remove_program(id)
	assert(id, "You must provide a program id")
	assert(programs[id], "You must provide a valid program id")
	msg.post("@render:", REMOVE_PROGRAM, { id = id })
end



return M