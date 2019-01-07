embedded_components {
  id: "sprite"
  type: "sprite"
  data: "tile_set: \"/examples/assets/torch.tilesource\"\n"
  "default_animation: \"torch\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "blend_mode: BLEND_MODE_ALPHA\n"
  ""
  position {
    x: 0.0
    y: 0.0
    z: 0.0
  }
  rotation {
    x: 0.0
    y: 0.0
    z: 0.0
    w: 1.0
  }
}
embedded_components {
  id: "light"
  type: "sprite"
  data: "tile_set: \"/examples/assets/lights.atlas\"\n"
  "default_animation: \"light_mask\"\n"
  "material: \"/lumiere/effects/lights/lightsource.material\"\n"
  "blend_mode: BLEND_MODE_ADD\n"
  ""
  position {
    x: 0.0
    y: 10.0
    z: 0.0
  }
  rotation {
    x: 0.0
    y: 0.0
    z: 0.0
    w: 1.0
  }
}
