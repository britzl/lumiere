local lumiere = require "lumiere.lumiere"

local M = {}

local instance_count = 0

-- create a sequence of post effects to apply to a render target
-- @param ... List of post effect modules
-- @return Post effects instance
function M.create(...)
	local effects = { ... }

	for _,effect in ipairs(effects) do
		assert(effect.apply, "You must provide an apply() function for every post effect")
	end

	local rt1 = nil
	local rt2 = nil
	
	local instance = {}

	instance_count = instance_count + 1

	function instance.init()
		rt1 = lumiere.create_render_target("posteffect_rt1_" .. tostring(instance_count), { color = true })
		if #effects > 1 then
			rt2 = lumiere.create_render_target("posteffect_rt2_" .. tostring(instance_count), { color = true })
		end
		for _,effect in ipairs(effects) do
			if effect.init then effect.init() end
		end
	end

	function instance.final()
		lumiere.delete_render_target(rt1)
		if rt2 then lumiere.delete_render_target(rt2) end
		for _,effect in ipairs(effects) do
			if effect.final then effect.final() end
		end
	end

	function instance.update()
		local count = #effects
		for i=1,count do
			local effect = effects[i]
			if effect.update then
				effect.update()
			end
		end
	end
	
	function instance.apply(input, output)
		local count = #effects
		for i=1,count do
			local effect = effects[i]
			if count == 1 then
				effect.apply(input, output)
			elseif i == 1 then
				effect.apply(input, rt1)
			elseif i == count then
				effect.apply(rt1, output)
			else
				effect.apply(rt1, rt2)
				rt1, rt2 = rt2, rt1
			end
		end
	end

	return instance
end

--- initialize a sequence of post effects
function M.init(posteffects)
	assert(posteffects, "You must provide a post effect sequence")
	posteffects.init()
end

--- finalize a sequence of post effects
-- the post effects cannot be used after a call to final()
function M.final(posteffects)
	assert(posteffects, "You must provide a post effect sequence")
	posteffects.final()
end

--- update a sequence of post effects
function M.update(posteffects)
	assert(posteffects, "You must provide a post effect sequence")
	posteffects.update()
end

--- apply a sequence of post effects to a render target,
-- optionally rendering it to a destination target, otherwise to
-- the screen
function M.apply(posteffects, input, output)
	assert(posteffects, "You must provide a post effect sequence")
	assert(input, "You must provide a render target to apply effects to")
	posteffects.apply(input, output)
end


return M