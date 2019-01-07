# Lumiere
The goal of Lumiere is to wrap the Defold render API and make the render script more flexible and easier to modify at runtime.

## Installation
You can use Lumiere in your own project by adding this project as a [Defold library dependency](http://www.defold.com/manuals/libraries/). Open your game.project file and in the dependencies field under project add:

https://github.com/britzl/lumiere/archive/master.zip

Or point to the ZIP file of a [specific release](https://github.com/britzl/lumiere/releases).

# Usage
Using Lumiere requires that `lumiere/lumiere.render` is set as the renderer in `game.project` in the Bootstrap section. Once this is done Lumiere can be used to swap out the default render script functionality with your own custom render pipeline, either as a one time thing at startup or any number of times while the game is running. The interchangeable part of the render script is called a program.

# Programs
Programs are essentially the contents of a render script that can easily be interchanged at run-time. Programs can be added and removed and a single program is active at any given time. The most basic program similar to the default render script looks like this:

	local lumiere = require "lumiere.lumiere"

	local PRG = {}

	function PRG.update(self, dt)
		lumiere.clear(lumiere.clear_color())
		lumiere.set_view_projection()
		lumiere.draw_graphics2d(view, projection)
		lumiere.set_identity_view_projection()
		lumiere.draw_gui()
	end

	return PRG

A program is added to and used by Lumiere through the `lumiere.add_program()` and `lumiere.use_program()` functions:

	local lumiere = require "lumiere.lumiere"
	local my_program = require "foobar.my_program"

	function init(self)
		lumiere.add_program("my_program", my_program)
		lumiere.use_program("my_program")
	end

If Lumiere is used without a custom program it will behave exactly like the default render script. The default program can be found in `lumiere.programs.default.lua`.

You create your own program by creating a Lua module with public functions that mirrors the Defold lifecycle functions (remove any function that you don't need):

	local PRG = {}

	function PRG.init(self)
		-- add any setup code here
	end

	function PRG.final(self)
		-- add any cleanup code here
	end

	function PRG.update(self, dt)
		-- add render code here to draw every frame
	end

	function PRG.on_message(self, message_id, message, sender)
		-- messages sent to the render script will be forwarded here
	end

	function PRG.on_reload(self)
		-- callback when the render script is reloaded
	end

The lifecycle functions can mix normal `render.*` functions with `lumiere.*` API functions (see below for a full API specification).


# API
The Lumiere API functions typically wrap the normal `render.*` functions and in some ways simplify them.

### lumiere.create_render_target(name, color, depth, stencil)
Create a Lumiere render target with the specified buffers.

**PARAMETERS**
* `name` (string) Unique name of the render target to create.
* `color` (boolean|table) Color buffer settings or true for default values. Nil to not create a color buffer.
* `depth` (boolean|table) Depth buffer settings or true for default values. Nil to not create a depth buffer.
* `stencil` (boolean) Stencil buffer settings or true for default values. Nil to not create stencil buffer.

**RETURN**
* ```render_target``` (table) The created render target. This is a table wrapping the render target and adding additional information about the render target (for use by other Lumiere functions)


### lumiere.delete_render_target(render_target)
Delete a previously created render target

**PARAMETERS**
* `render_target` (table) The render target to delete (created via `lumiere.create_render_target()`).


### lumiere.predicate(tags)
Create a predicate using the specified tags. Lumiere will cache created predicates and return an already created predicate if it matches the specified tags.

**PARAMETERS**
* `tags` (table) Table with tags (string[hash)

**RETURN**
* ```predicate``` (predicate) The created predicate


### lumiere.enable_render_target(render_target)
Enable a Lumiere render target. The render target will be used for any subsequent draw or clear operations until explicitly disabled.

**PARAMETERS**
* `render_target` (table) Lumiere render target (from `lumiere.create_render_target`)


### lumiere.disable_render_target()
Disable any currently enabled render target.


### lumiere.set_viewport(x, y, w, h)
Set or clear the viewport. If the viewport is cleared it will automatically use the entire window size and change whenever the window size changes. If the viewport is set using this method it will stay fixed to the size specified regardless if the window size changes.

**PARAMETERS**
* `x` (number) Left corner (nil to clear the viewport)
* `y` (number) Bottom corner
* `w` (number) Viewport width
* `h` (number) Viewport height


### lumiere.set_view_projection(view, projection)
Set the view projection to use.

**PARAMETERS**
* `view` (matrix4) View to use. Will use identity if not specified.
* `projection` (matrix4) Projection to use. Will use identity if not specified.


### lumiere.set_identity_view_projection()
Set the view and projection to identity matrices.


### lumiere.set_constant(key, value)
Set a shader constant to be provided in a constant buffer when drawing.

**PARAMETERS**
* `key` (string) Shader constant key
* `value` (vector4) Shader constant value


### lumiere.reset_constant(key)
Remove a previously set shader constant.

**PARAMETERS**
* `key` (string) Shader constant key to remove


### lumiere.reset_constants()
Remove all previously set shader constants.


### lumiere.time()
Get current time (for use as a shader constant)

**RETURN**
* `time` (vector4) Time (x = time in seconds, y = delta time)


### lumiere.resolution()
Get the current resolution (for use as a shader constant)

**RETURN**
* `resolution` (vector4) Resolution (x = width, y = height, z = original width, w = original height)


### lumiere.clear(color, depth, stencil)
Clear color, depth and stencil buffers. This will take into account the settings of the current render target (if any).

**PARAMETERS**
* `color` (vector4) Clear color or nil to not clear the color buffer.
* `depth` (number) Depth value or nil to not clear the depth buffer.
* `stencil` (number) Stencil value or nil to not clear the stencil buffer.


### lumiere.enable_texture(unit, render_target, buffer_type)
Sets the specified render target's specified buffer to be used as texture with the specified unit. A material shader can then use the texture to sample from.

**PARAMETERS**
* `unit` (number) Texture unit to enable texture for
* `render_target` (table) Lumiere render target
* `buffer_type` (constant) Buffer type from which to enable the texture (render.BUFFER_*)


### lumiere.disable_texture(unit)
Disables a texture unit for a render target that has previously been enabled.

**PARAMETERS**
* `unit` (number) Texture unit to disable texture for


### lumiere.draw(...)
Draw one or more predicates to the current render target using any previously set constants.

**PARAMETERS**
* `...` (vararg) List of predicates


### lumiere.add_program(id, program)
Add a program to Lumiere. See section on Lumiere programs.

**PARAMETERS**
* `id` (string|hash) Unique id of the program to add
* `program` (table) The Lumiere program to add


### lumiere.use_program(id)
Use a previously added program.

**PARAMETERS**
* `id` (string|hash) Id of the program to use


### lumiere.remove_program(id)
Remove a previously added program.

**PARAMETERS**
* `id` (string|hash) Id of the program to remove


### lumiere.init(self)
Initialize Lumiere. Automatically called from `lumiere.render_script`


### lumiere.final(self)
Finalize Lumiere. Automatically called from `lumiere.render_script`. This will also call `final()` on an active program.


### lumiere.update(self, dt)
Update Lumiere. Automatically called from `lumiere.render_script`. This will also call `update()` on an active program.


### lumiere.on_message(self, message_id, message, sender)
Message handler. Automatically called from `lumiere.render_script`. This will also call `on_message()` on an active program.


### lumiere.on_reload(self)
Hot-reload handler. Automatically called from `lumiere.render_script`. This will also call `on_reload()` on an active program.
