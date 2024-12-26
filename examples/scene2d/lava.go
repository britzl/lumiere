components {
  id: "fireballspawner"
  component: "/examples/scene2d/fireballspawner.script"
}
embedded_components {
  id: "sprite"
  type: "sprite"
  data: "default_animation: \"lava\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/examples/assets/lava.tilesource\"\n"
  "}\n"
  ""
}
embedded_components {
  id: "factory"
  type: "factory"
  data: "prototype: \"/examples/scene2d/fireball.go\"\n"
  ""
}
embedded_components {
  id: "light"
  type: "sprite"
  data: "default_animation: \"light_mask\"\n"
  "material: \"/lumiere/effects/lights/lightsource.material\"\n"
  "blend_mode: BLEND_MODE_ADD\n"
  "textures {\n"
  "  sampler: \"DIFFUSE_TEXTURE\"\n"
  "  texture: \"/examples/assets/lights.atlas\"\n"
  "}\n"
  ""
}
