components {
  id: "lights"
  component: "/lumiere/effects/lights/lights.script"
}
embedded_components {
  id: "model"
  type: "model"
  data: "mesh: \"/builtins/assets/meshes/quad.dae\"\n"
  "name: \"unnamed\"\n"
  "materials {\n"
  "  name: \"default\"\n"
  "  material: \"/lumiere/effects/lights/apply_lights.material\"\n"
  "  textures {\n"
  "    sampler: \"input_tex\"\n"
  "    texture: \"/lumiere/transparent.png\"\n"
  "  }\n"
  "  textures {\n"
  "    sampler: \"lights_tex\"\n"
  "    texture: \"/lumiere/transparent.png\"\n"
  "  }\n"
  "}\n"
  ""
}
