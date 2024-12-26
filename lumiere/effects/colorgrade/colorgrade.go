components {
  id: "colorgrade"
  component: "/lumiere/effects/colorgrade/colorgrade.script"
}
embedded_components {
  id: "model"
  type: "model"
  data: "mesh: \"/builtins/assets/meshes/quad_2x2.dae\"\n"
  "name: \"unnamed\"\n"
  "materials {\n"
  "  name: \"default\"\n"
  "  material: \"/lumiere/effects/colorgrade/colorgrade.material\"\n"
  "  textures {\n"
  "    sampler: \"original\"\n"
  "    texture: \"/lumiere/transparent.png\"\n"
  "  }\n"
  "  textures {\n"
  "    sampler: \"lut\"\n"
  "    texture: \"/lumiere/effects/colorgrade/lut16.png\"\n"
  "  }\n"
  "}\n"
  ""
}
embedded_components {
  id: "lut"
  type: "sprite"
  data: "default_animation: \"lut16\"\n"
  "material: \"/lumiere/effects/colorgrade/colorgrade_lut.material\"\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/lumiere/effects/colorgrade/colorgrade_lut.atlas\"\n"
  "}\n"
  ""
  position {
    x: 128.0
    y: 8.0
  }
}
