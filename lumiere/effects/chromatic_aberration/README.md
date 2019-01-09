# Chromatic Aberration
Adds a chromatic aberration effect (red, green and blue colors are temporarily shifted out of place)

## Before
![](../doc/original.png)

## After
![](../doc/chromatic_aberration.png)

# Usage
You use the effect as is by adding it to a posteffect sequence:

	local posteffects = require "lumiere.effects.posteffects"
	local chromatic_aberration = require "lumiere.effects.chromatic_aberration.chromatic_aberration"

	-- use chromatic_aberration with default settings
	local chromatic_aberration_effect = posteffects.create(chromatic_aberration)
