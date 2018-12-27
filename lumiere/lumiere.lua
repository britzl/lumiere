
local M = {}

assert(render, "You must require Lumiere from your render script")

local width = tonumber(sys.get_config("display.width"))
local height = tonumber(sys.get_config("display.height"))

local IDENTITY = vmath.matrix4()

-- colors
M.BLACK = vmath.vector4(0,0,0,1.0)
M.TRANSPARENT = vmath.vector4(0)


-- messages
local USE_PROGRAM = hash("lumiere_use_program")
local REMOVE_PROGRAM = hash("lumiere_remove_program")


-- data structures
local predicates = {
	multiply = nil,
	copy = nil,
	mix = nil,
}

local clear_buffers = {}
local constants = {}
local programs = {}
local render_targets = {}

local current_program = nil
local current_render_target = nil

local time = 0
local const_time = vmath.vector4()
local const_window_size = vmath.vector4(0, 0, width, height)


M.MATERIAL_MIX = hash("mix")
M.MATERIAL_COPY = hash("copy")
M.MATERIAL_MULTIPLY = hash("multiply")

local function log(...)
	--print(...)
end

function M.time()
	return const_time
end

function M.window_size()
	return const_window_size
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
	render.draw(predicates.tile)
	render.draw(predicates.particle)
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
-- @param color
-- @param depth
-- @param stencil
function M.create_render_target(name, color, depth, stencil)
	assert(name, "You must specify a name")
	assert(not render_targets[name], "There is already a render target with that name")

	local instance = {
		name = name,
		color = color,
		depth = depth,
		stencil = stencil,
		handle = nil,
		constants = {},
		blend_mode = {
			source_factor = render.BLEND_SRC_ALPHA,
			dest_factor = render.BLEND_ONE_MINUS_SRC_ALPHA,
		},
	}

	log("create_render_target", name)
	log("RENDER TARGETS:")
	for k,v in pairs(render_targets) do
		log("  ", k)
	end
	render_targets[name] = instance

	
	-- initialize/create render target
	local function init(width, height)
		log("init render_target", name)
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
		local window_width = render.get_window_width()
		local window_height = render.get_window_height()

		-- recreate render targets if screen size has changed
		if instance.width ~= window_width or instance.height ~= window_height then
			init(window_width, window_height)
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
	time = socket.gettime()
end

function M.final(self)
	if current_program.final then
		current_program.final(current_program.context)
	end
end

function M.update(self, dt)
	local now = socket.gettime()
	local dt = now - time
	time = now
	
	-- update time constant
	const_time.x = const_time.x + dt
	const_time.y = dt;

	-- update window size constant
	width = render.get_window_width()
	height = render.get_window_height()
	const_window_size.x = width
	const_window_size.y = height

	-- update all render targets (check resize)
	for _,render_target in pairs(render_targets) do
		render_target.update()
	end

	-- update current program
	if current_program.update then
		current_program.update(current_program.context, dt)
	end
end


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