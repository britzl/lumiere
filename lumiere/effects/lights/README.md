# Lights
Adds simple 2D lightsources and ambient light

## Before
![](../../../doc/original.png)

## After
![](../../../doc/lights.png)


## Setup

Add `lights.go` to a collection in your project. You can tweak the ambient light and light intensity properties on the `lights.go`.

Next add the lights effect to luimiere:

```
local lights = require "lumiere.effects.lights.lights"
lumiere.use_effect(lights)
```

Finally you also need to add some lightsources. Each lightsource must consist of a sprite with a light mask (sphere, cone or any other shape you want for your light) and it must use the `lumiere/effects/lights/lightsource.material`.
