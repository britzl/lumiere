# Effects
Lumiere provides a system that makes it very easy to apply multiple post effects to a game. This could be anything from lights or blur to scanlines and LCD effects. The system is completely optional and is not active by default.

# Usage
You use the effects system by creating a post-effect chain and apply it as part of your Lumiere program. The effects you add will be applied one by one with a render target as input:

	local lumiere = require "lumiere.lumiere"
	local posteffects = require "lumiere.effects.posteffects"
	local grain = require "lumiere.effects.grain.grain"
	local blur = require "lumiere.effects.blur.blur"

	local PRG = {}

	function PRG.init(self)
		-- create a post effect chain, in this case first some blur then some grain
		self.blur_grain_effect = posteffects.create(blur, grain)

		-- create a render target as a source/input
		self.source_rt = lumiere.create_render_target("graphics2d", true, false, false)

		-- initialize the post effects
		posteffects.init(self.blur_grain_effect)
	end

	function PRG.final(self)
		lumiere.delete_render_target(self.source_rt)
		posteffects.final(self.blur_grain_effect)
	end

	function PRG.update(self, dt)
		-- draw graphics 2d to the source render target
		lumiere.enable_render_target(self.source_rt)
		lumiere.clear(lumiere.BLACK)
		lumiere.draw_graphics2d(view, projection)
		lumiere.disable_render_target()

		-- apply blur and grain
		posteffects.apply(self.blur_grain_effect, self.source_rt)
	end

	return PRG

Note: To use an effect you need to add it to a post effect sequence like in the example above. You also need to add the corresponding effect game object to your scene so that the effect material becomes available to render code. Read more about how effects are created below.

# Effects
Lumiere provides a number of standard effects:

* [Blur](blur/)
* Grain
* Lights
* Chromatic Aberration
* LCD
* Scanlines

You can also create your own effects and plug these into the effects system. A Lumiere effect is encapsulated into a Lua module with a single requirement that it provides an `apply()` function that takes a render target as input and an optional render target as output. Effects are usually comprised of a game object with a model component using a unit quad with a material that references the effect shader. The effect can do just about anything but the most typical use-case is that it enables the render target input as a texture, enables the output render target if available and draws using the predicate assigned to the effect material to apply the effect:

	local lumiere = require "lumiere.lumiere"

	local M = {}

	local PREDICATE = nil

	function M.init()
		PREDICATE = lumiere.predicate({ hash("myeffect") })
	end

	function M.final()
	end

	function M.apply(input, output)
		if output then lumiere.enable_render_target(output) end
		lumiere.set_identity_view_projection()
		lumiere.clear(lumiere.BLACK)
		lumiere.set_constant("foobar", vmath.vector4(1,2,3,4))
		lumiere.enable_texture(0, input)
		lumiere.draw(PREDICATE)
		lumiere.disable_texture(0)
		lumiere.reset_constants()
		if output then lumiere.disable_render_target() end
	end

	return M
