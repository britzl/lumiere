# Lumiere - Work In Progress

Lumiere is a collection of post processing effects for use in Defold.

## Installation

You can use Lumiere in your own project by adding this project as a [Defold library dependency](http://www.defold.com/manuals/libraries/). Open your game.project file and in the dependencies field under project add:

<https://github.com/britzl/lumiere/archive/master.zip>

Or point to the ZIP file of a [specific release](https://github.com/britzl/lumiere/releases).

## Usage

Lumiere has to be integrated with your render script to be able to apply effects.

## Effects

Lumiere provides a system to apply multiple post-effects to a game.

Examples of effects provided:

* [Blur](lumiere/effects/blur/)
* [Grain](lumiere/effects/grain/)
* [Lights](lumiere/effects/lights/)
* [Chromatic Aberration](lumiere/effects/chromatic_aberration/)
* [LCD](lumiere/effects/lcd/)
* [Scanlines](lumiere/effects/scanlines/)
* [Colorgrade](lumiere/effects/colorgrade/)

## Quick Start

1. Add `/lumiere/lumiere.go` to your collection.
2. Add an effect you want to use to your collection, e.g. `/lumiere/effects/grain/grain.go`
3. Integrate Lumiere in the render script.
4. Add `lumiere.use_effects({})` into your script.

More precise instructions are below.

## Add lumiere.go

Add `/lumiere/lumiere.go` to a loaded collection, either the bootstrap collection or a loaded proxy collection. This game object contains a full screen quad to which the final composition of post processing effects is drawn.

## Using effects

Each effect consists of some shader code, a Lua module and a game object. To use an effect the game object for the effect has to be added to a loaded collection, either the bootstrap collection or a loaded proxy collection.

## Render script integration

```lua
-- require lumiere for use in the render script
local lumiere = require("lumiere.lumiere")


function init(self)
    -- initialize lumiere
    lumiere.init()

    -- the rest of your init code
    ...
end

function update(self)
    -- update lumiere each frame
    lumiere.update()

    -- your render script update code
    ...

    -- wrap any render.draw() calls that should be affected by lumiere effects
    lumiere.draw(function()
        ...
 end)

    ...
end

function M.on_message(self, message_id, message)
    -- pass messages to lumiere (to detect change in clear color etc)
    lumiere.on_message(message_id, message)

    -- the rest of your on_message code
    ...
end
```

Note: See the [example.render_script](examples/example.render_script) for a full example.

## Add effects to your script

 The Lua module for the effect has to be added to Lumiere in your script:

```lua
local lumiere = require("lumiere.lumiere")
local blur = require("lumiere.effects.blur.blur")
local grain = require("lumiere.effects.grain.grain")


function init(self)
    -- use the blur and grain effect (in that order)
    lumiere.use_effects({ blur, grain })
end
```
