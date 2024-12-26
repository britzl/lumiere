local M = {}

local time = vmath.vector4(0)
local clear_color = vmath.vector4(0)
local resolution = vmath.vector4(0)

local IDENTITY = vmath.matrix4()

local lumiere = {
	rt1 = nil,
	rt2 = nil,
	effects = {},
	predicate = nil,
	timestamp = 0,
	clear_options = {[render.BUFFER_COLOR_BIT] = clear_color, [render.BUFFER_DEPTH_BIT] = 1}
}

function M.time()
	return time
end

function M.clear_color()
	return clear_color
end

function M.resolution()
	return resolution
end

function M.set_identity()
	render.set_view(IDENTITY)
	render.set_projection(IDENTITY)
end


local function create_render_targets(width, height)
	if lumiere.rt1 then
		render.delete_render_target(lumiere.rt1)
	end
	if lumiere.rt2 then
		render.delete_render_target(lumiere.rt2)
	end
		
	local color_params = { format = render.FORMAT_RGBA,
		width = width,
		height = height,
		min_filter = render.FILTER_LINEAR,
		mag_filter = render.FILTER_LINEAR,
		u_wrap = render.WRAP_CLAMP_TO_EDGE,
		v_wrap = render.WRAP_CLAMP_TO_EDGE }

	local depth_params = { format = render.FORMAT_DEPTH,
		width = width,
		height = height,
		u_wrap = render.WRAP_CLAMP_TO_EDGE,
		v_wrap = render.WRAP_CLAMP_TO_EDGE }

	lumiere.rt1 = render.render_target({[render.BUFFER_COLOR_BIT] = color_params, [render.BUFFER_DEPTH_BIT] = depth_params })
	lumiere.rt2 = render.render_target({[render.BUFFER_COLOR_BIT] = color_params, [render.BUFFER_DEPTH_BIT] = depth_params })
end

local function iterate_effects(fn)
	local count = #lumiere.effects
	for i=1,count do
		local effect = lumiere.effects[i]
		fn(i, effect)
	end
end

local function clear_effects()
	while #lumiere.effects > 0 do
		local effect = table.remove(lumiere.effects)
		effect.final()
	end
end

function M.use_effects(effects)
	assert(effects)

	lumiere.new_effects = effects
end

function M.init()
	assert(not lumiere.predicate, "You may only call lumiere.init() once")

	lumiere.timestamp = socket.gettime()
	
	lumiere.predicate = render.predicate({"lumiere"})

	local width = render.get_window_width()
	local height = render.get_window_height()
	resolution.x = width
	resolution.y = height
	create_render_targets(width, height)

	clear_color.x = sys.get_config("render.clear_color_red", 0)
	clear_color.y = sys.get_config("render.clear_color_green", 0)
	clear_color.z = sys.get_config("render.clear_color_blue", 0)
	clear_color.w = sys.get_config("render.clear_color_alpha", 0)
end

function M.final()
	assert(lumiere.predicate, "You must call lumiere.init() once before calling lumiere.final()")

	clear_effects()
	
	render.delete_render_target(lumiere.rt1)
	render.delete_render_target(lumiere.rt2)
	lumiere.rt1 = nil
	lumiere.rt2 = nil
	lumiere.predicate = nil
end

function M.update()
	local now = socket.gettime()
	local dt = now - lumiere.timestamp
	lumiere.timestamp = now
	
	time.x = time.x + dt

	-- detect updates to effects
	if lumiere.new_effects then
		clear_effects()
		for i,effect in ipairs(lumiere.new_effects or {}) do
			lumiere.effects[i] = {
				effect = effect,
				init = effect.init or function() end,
				final = effect.final or function() end,
				apply = effect.apply or function() end,
				update = effect.update or function() end,
			}
			effect.init()
		end
		lumiere.new_effects = nil
	end	

	-- detect resolution change
	local width = render.get_window_width()
	local height = render.get_window_height()
	if resolution.x ~= width or resolution.y ~= height then
		resolution.x = width
		resolution.y = height
		create_render_targets(width, height)

		-- refresh effects
		iterate_effects(function(i, effect)
			effect.final()
			effect.init()
		end)
	end
end


function M.draw(fn)
	local count = #lumiere.effects
	if count == 0 then
		fn()
		return
	end

	-- update effects
	iterate_effects(function(i, effect)
		effect.update()
	end)

	local input = lumiere.rt1
	local output = lumiere.rt2

	-- draw to the first render target
	render.set_render_target(input)
	render.clear(lumiere.clear_options)
	fn()
	render.set_render_target(render.RENDER_TARGET_DEFAULT)

	-- apply the sequence of effects
	iterate_effects(function(i, effect)
		render.set_render_target(output)
		effect.apply(input)
		render.set_render_target(render.RENDER_TARGET_DEFAULT)
		if i < count then
			input, output = output, input
		end
	end)

	-- draw final result
	render.enable_texture(0, output, render.BUFFER_COLOR_BIT)
	render.set_view(IDENTITY)
	render.set_projection(IDENTITY)
	render.draw(lumiere.predicate)
	render.disable_texture(0)
end

function M.on_message(message_id, message, sender)
	if message_id == hash("clear_color") then
		clear_color = message.color
		lumiere.clear_options[render.BUFFER_COLOR_BIT] = message.color
	end
end

return M