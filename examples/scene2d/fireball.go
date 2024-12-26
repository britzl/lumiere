embedded_components {
  id: "sprite"
  type: "sprite"
  data: "default_animation: \"fireball\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/examples/assets/items.tilesource\"\n"
  "}\n"
  ""
}
embedded_components {
  id: "light"
  type: "sprite"
  data: "default_animation: \"light_mask_yellow_64\"\n"
  "material: \"/lumiere/effects/lights/lightsource.material\"\n"
  "blend_mode: BLEND_MODE_ADD\n"
  "textures {\n"
  "  sampler: \"DIFFUSE_TEXTURE\"\n"
  "  texture: \"/examples/assets/lights.atlas\"\n"
  "}\n"
  ""
}
