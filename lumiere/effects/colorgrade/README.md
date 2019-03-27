# Colorgrade
Adds support for colorgrading

## Before
![](../doc/original.png)

## After
![](../doc/colorgrade.png)

# Usage
You use the effect by specifying the path to a custom resource containing a colorgrading look-up table:

	local posteffects = require "lumiere.effects.posteffects"
	local colorgrade = require "lumiere.effects.colorgrade.colorgrade"

	local lut_filename = "/myassets/lut.png"
	local colorgrade_effect = posteffects.create(colorgrade.create(lut_filename))

You must also add `colorgrade.go` to an active collection.
