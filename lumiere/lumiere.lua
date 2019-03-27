
local M = {}

assert(render, "You must require Lumiere from your render script")

local width = tonumber(sys.get_config("display.width"))
local height = tonumber(sys.get_config("display.height"))

local IDENTITY = vmath.matrix4()

-- colors
M.BLACK = vmath.vector4(0,0,0,1.0)
M.RED = vmath.vector4(1.0,0,0,0.1)
M.TRANSPARENT = vmath.vector4(0)


-- messages
local USE_PROGRAM = hash("lumiere_use_program")
local REMOVE_PROGRAM = hash("lumiere_remove_program")
local SET_VIEW_PROJECTION = hash("set_view_projection")
local CLEAR_COLOR = hash("clear_color")

-- predicates creates using lumiere.predicate()
local predicates = {
	multiply = nil,
	copy = nil,
	mix = nil,
}

local clear_color = vmath.vector4()

-- for use with lumiere.clear()
local clear_buffers = {}

-- constants set using lumiere.set_constant()
local constants = {}

-- programs added using lumiere.add_program()
local programs = {}

-- render targets created using lumiere.create_render_target()
local render_targets = {}

-- the currently used program
local current_program = nil

-- the currently enabled render target
local current_render_target = nil

local time = 0
local const_time = vmath.vector4()
local const_resolution = vmath.vector4(0, 0, width, height)



local view_settings = {
	viewport = nil,
	view = vmath.matrix4(),
	projection = vmath.matrix4_orthographic(0, width, 0, height, -1, 1),
	screen_projection = vmath.matrix4_orthographic(0, width, 0, height, -1, 1),
}

M.MATERIAL_MIX = hash("mix")
M.MATERIAL_COPY = hash("copy")
M.MATERIAL_MULTIPLY = hash("multiply")

local function log(...)
	--print(...)
end

function M.time()
	return const_time
end

function M.resolution()
	return const_resolution
end

function M.clear_color()
	return clear_color
end

-- enable a render target
function M.enable_render_target(render_target)
	assert(render_target, "You must provide a render target")
	--log("enable_render_target", render_target.name)
	current_render_target = render_target
	render.set_render_target(render_target.handle)
	return M
end

-- disable the current render target
function M.disable_render_target()
	assert(current_render_target, "There is no enabled render target to disable")
	--log("disable_render_target", current_render_target.name)
	current_render_target = nil
	render.set_render_target(render.RENDER_TARGET_DEFAULT)
	return M
end


function M.set_viewport(x, y, w, h)
	if not x then
		view_settings.viewport = nil
		render.set_viewport(0, 0, width, height)
	else
		view_settings.viewport = vmath.vector4(x, y, w, h)
		render.set_viewport(x, y, w, h)
	end
end

-- set view projection to specified matrices
function M.set_view_projection(view, projection)
	render.set_view(view or view_settings.view or IDENTITY)
	render.set_projection(projection or view_settings.projection or IDENTITY)
end


-- set view projection to identity matrix
function M.set_identity_projection()
	render.set_view(IDENTITY)
	render.set_projection(IDENTITY)
end

-- set view projection to identity screen space
function M.set_screen_projection()
	render.set_view(IDENTITY)
	render.set_projection(view_settings.screen_projection)
end

-- set a constant that will be passed to
-- the shader when drawing
function M.set_constant(key, value)
	assert(key, "You must provide a constant key")
	constants[key] = value
end

-- reset/remove a constant
function M.reset_constant(key)
	assert(key, "You must provide a constant key")
	constants[key] = nil
end

-- reset/remove all constants
function M.reset_constants()
	for k,v in pairs(constants) do
		constants[k] = nil
	end
end

-- call render.clear() with specified settings
function M.clear(color, depth, stencil)
	if current_render_target then
		color = current_render_target.color and color or false
		depth = current_render_target.depth and depth or false
		stencil = current_render_target.stencil and stencil or false
	end
	if depth then
		render.set_depth_mask(true)
	end
	if stencil then
		render.set_stencil_mask(0xff)
	end
	clear_buffers[render.BUFFER_COLOR_BIT] = color or nil
	clear_buffers[render.BUFFER_DEPTH_BIT] = depth or nil
	clear_buffers[render.BUFFER_STENCIL_BIT] = stencil or nil
	render.clear(clear_buffers)
end


function M.enable_texture(unit, render_target, buffer_type)
	assert(unit, "You must provide a texture unit")
	assert(render_target, "You must provide a render target")
	buffer_type = buffer_type or render.BUFFER_COLOR_BIT
	render.enable_texture(unit, render_target.handle, buffer_type)
end

function M.disable_texture(unit)
	assert(unit, "You must provide a texture unit")
	render.disable_texture(unit)
end

-- convenience function for using the Lumiere multiply
-- predicate to multiply the content of two render targets
function M.multiply(render_target1, render_target2)
	assert(render_target1, "You must provide a first render target")
	assert(render_target2, "You must provide a second render target")
	render.enable_texture(0, render_target1.handle, render.BUFFER_COLOR_BIT)
	render.enable_texture(1, render_target2.handle, render.BUFFER_COLOR_BIT)
	M.draw(predicates.multiply)
	render.disable_texture(0)
	render.disable_texture(1)
end

-- draw gui
function M.draw_gui(view, projection)
	if view then render.set_view(view) end
	if projection then render.set_projection(projection) end
	render.enable_state(render.STATE_STENCIL_TEST)
	render.draw(predicates.gui)
	render.draw(predicates.text)
	render.disable_state(render.STATE_STENCIL_TEST)
end

function M.draw_graphics2d(view, projection)
	if view then render.set_view(view) end
	if projection then render.set_projection(projection) end
	M.draw(predicates.tile, predicates.particle)
end

-- draw the specified predicates
function M.draw(...)
	-- enable/disable depth mask
	if current_render_target and current_render_target.depth then
		render.set_depth_mask(true)
		render.enable_state(render.STATE_DEPTH_TEST)
	else
		render.set_depth_mask(false)
		render.disable_state(render.STATE_DEPTH_TEST)
	end

	-- enable/disable stencil mask
	if current_render_target and current_render_target.stencil then
		render.set_stencil_mask(0xff)
		render.enable_state(render.STATE_STENCIL_TEST)
	else
		render.disable_state(render.STATE_STENCIL_TEST)
	end

	-- disable polygon culling
	render.disable_state(render.STATE_CULL_FACE)

	-- set blend mode
	render.enable_state(render.STATE_BLEND)
	if current_render_target then
		render.set_blend_func(current_render_target.blend_mode.source_factor, current_render_target.blend_mode.dest_factor)
	else
		render.set_blend_func(render.BLEND_SRC_ALPHA, render.BLEND_ONE_MINUS_SRC_ALPHA)
	end

	-- create constant buffer
	local constant_buffer = nil
	if next(constants) then
		constant_buffer = render.constant_buffer()
		for k,v in pairs(constants) do
			constant_buffer[k] = v
		end
	end

	-- draw predicates
	local count = select("#", ...)
	for i=1,count do
		local pred = select(i, ...)
		render.draw(pred, constant_buffer)
	end
end


-- create a render target
-- @param name
-- @param config Table with render target configuration values. Valid keys::
--	color - True for defaults or color params table (or nil for none)
--  depth - True for defaults or depth params table (or nil for none)
--  stencil - True for defaults or stencil params table (or nil for none)
function M.create_render_target(name, config)
	assert(name, "You must specify a name")
	assert(not render_targets[name], "There is already a render target with that name")

	config = config or {}
	local instance = {
		name = name,
		color = config.color,
		depth = config.depth,
		stencil = config.stencil,
		handle = nil,
		blend_mode = {
			source_factor = render.BLEND_SRC_ALPHA,
			dest_factor = render.BLEND_ONE_MINUS_SRC_ALPHA,
		},
	}

	render_targets[name] = instance

	local color_params = nil
	if config.color then
		local color_config = type(config.color) == "table" and config.color or nil
		color_params = {
			format = color_config and color_config.format or render.FORMAT_RGBA,
			min_filter = color_config and color_config.min_filter or render.FILTER_LINEAR,
			mag_filter = color_config and color_config.mag_filter or render.FILTER_LINEAR,
			u_wrap = color_config and color_config.u_wrap or render.WRAP_CLAMP_TO_EDGE,
			v_wrap = color_config and color_config.v_wrap or render.WRAP_CLAMP_TO_EDGE
		}
	end

	local depth_params = nil
	if config.depth then
		local depth_config = type(config.depth) == "table" and config.depth or nil
		depth_params = {
			format = depth_config and depth_config.format or render.FORMAT_DEPTH,
			u_wrap = depth_config and depth_config.u_wrap or render.WRAP_CLAMP_TO_EDGE,
			v_wrap = depth_config and depth_config.v_wrap or render.WRAP_CLAMP_TO_EDGE
		}
	end

	local stencil_params = nil
	if config.stencil then
		local stencil_config = type(config.stencil) == "table" and config.stencil or nil
		stencil_params = {
			format = stencil_config and stencil_config.format or render.FORMAT_STENCIL,
			u_wrap = stencil_config and stencil_config.u_wrap or render.WRAP_CLAMP_TO_EDGE,
			v_wrap = stencil_config and stencil_config.v_wrap or render.WRAP_CLAMP_TO_EDGE
		}
	end

	-- initialize/create render target
	local function init(width, height)
		log("init render_target", name, width, height)
		instance.width = width
		instance.height = height

		if color_params then
			color_params.width = width
			color_params.height = height
		end
		if depth_params then
			depth_params.width = width
			depth_params.height = height
		end
		if stencil_params then
			stencil_params.width = width
			stencil_params.height = height
		end

		if instance.handle then
			render.delete_render_target(instance.handle)
		end

		instance.handle = render.render_target(name, {
			[render.BUFFER_COLOR_BIT] = color_params,
			[render.BUFFER_DEPTH_BIT] = depth_params,
			[render.BUFFER_STENCIL_BIT] = stencil_params,
		})
	end

	-- update the render target if the width or height has changed
	function instance.update()
		local width = config.width or render.get_window_width()
		local height = config.height or render.get_window_height()

		-- recreate render targets if screen size has changed
		if instance.width ~= width or instance.height ~= height then
			init(width, height)
		end
	end

	return instance
end

--  delete a render target
function M.delete_render_target(render_target)
	assert(render_target, "You must provide a render target")
	log("delete_render_target", render_target.name)
	render.delete_render_target(render_target.handle)
	render_targets[render_target.name] = nil
end


-- create a predicate
-- this will cache the predicate and return the same one if requested more than
-- once
function M.predicate(tags)
	for i,tag in ipairs(tags) do
		tag = type(tag) == "string" and hash(tag) or tag
	end

	for _,predicate in ipairs(predicates) do
		local found_predicate = true
		for _,tag in ipairs(tags) do
			if not predicate.tags_lut[tag] then
				found_predicate = false
				break
			end
		end
		if found_predicate then
			return predicate.handle
		end
	end

	local predicate = {
		tags_lut = {},
		handle = render.predicate(tags),
	}
	for _,tag in ipairs(tags) do
		predicate.tags_lut[tag] = true
	end

	predicates[#predicates + 1] = predicate
	return predicate.handle
end

-- initialize lumiere
function M.init(self)
	width = render.get_window_width()
	height = render.get_window_height()
	predicates.multiply = render.predicate({ hash("lumiere_multiply") })
	predicates.mix = render.predicate({ hash("lumiere_mix") })
	predicates.copy = render.predicate({ hash("lumiere_copy") })
	predicates.gui = render.predicate({ hash("gui") })
	predicates.text = render.predicate({ hash("text") })
	predicates.tile = render.predicate({ hash("tile") })
	predicates.particle = render.predicate({ hash("particle") })
	clear_color.x = sys.get_config("render.clear_color_red", 0)
	clear_color.y = sys.get_config("render.clear_color_green", 0)
	clear_color.z = sys.get_config("render.clear_color_blue", 0)
	clear_color.w = sys.get_config("render.clear_color_alpha", 0)
	time = socket.gettime()
end

-- finalize lumiere
function M.final(self)
	if current_program.final then
		current_program.final(current_program.context)
	end
end

-- update lumiere
function M.update(self, dt)
	local now = socket.gettime()
	local dt = now - time
	time = now

	-- update time constant
	const_time.x = const_time.x + dt
	const_time.y = dt;

	-- update window size constant
	-- also update screen space projection if needed
	width = render.get_window_width()
	height = render.get_window_height()
	if const_resolution.x ~= width or const_resolution.y ~= height then
		view_settings.screen_space_projection = vmath.matrix4_orthographic(0, width, 0, height, -1, 1)
		const_resolution.x = width
		const_resolution.y = height
	end

	local viewport = view_settings.viewport
	if viewport then
		render.set_viewport(viewport.x, viewport.y, viewport.z, viewport.w)
	else
		render.set_viewport(0, 0, width, height)
	end

	-- update all render targets (check resize)
	for _,render_target in pairs(render_targets) do
		render_target.update()
	end

	-- update current program
	if current_program.update then
		current_program.update(current_program.context, dt)
	end
end

-- handle messages
-- mainly switching of programs and handling default render messages
function M.on_message(self, message_id, message, sender)
	if message_id == USE_PROGRAM then
		local id = message.id
		assert(id, "You must provide a program id")
		assert(programs[id], "You must provide a valid program id")
		log("USE_PROGRAM", id)
		if current_program == programs[id] then
			print("Program already in use")
			return
		end
		if current_program and current_program.final then
			log("calling final on current_program", current_program.id)
			current_program.final(current_program.context)
		end
		current_program = programs[id]
		current_program.id = id
		if current_program.init then
			log("calling init on current_program", current_program.id)
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
	else
		if message_id == SET_VIEW_PROJECTION then
			view_settings.view = message.view
			view_settings.projection = message.projection
		elseif message_id == CLEAR_COLOR then
			clear_color = message.color
		end
		if current_program.on_message then
			current_program.on_message(current_program.context, message_id, message, sender)
		end
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
