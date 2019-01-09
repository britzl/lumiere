# Blur
Simple on-pass blur shader

# Usage
You can use the effect as is or create a blur instance where the blur distance is configurable:

	local posteffects = require "lumiere.effects.posteffects"
	local blur = require "lumiere.effects.blur.blur"

	-- use blur with default settings (blur distance = 2)
	local blur_effect = posteffects.create(blur)

	-- use blur with custom settings (blur distance = 3)
	local custom_blur = blur.create(3)
	local blur_effect = posteffects.create(custom_blur)

	-- distance can also be changed afterwards
	custom_blur.distance = 4
