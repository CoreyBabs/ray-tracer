package light

import "src:features/tuples"
import utils "src:utilities"

Material :: struct {
	color: tuples.Color,
	ambient: f32,
	diffuse: f32,
	specular: f32,
	shininess: f32
}

material :: proc(a: f32 = 0.1, d: f32 = 0.9, spec: f32 = 0.9, shine: f32 = 200.0) -> Material {
	c := tuples.color(1, 1, 1)
	return Material{c, a, d, spec, shine}
}

set_material_color :: proc(m: ^Material, color: tuples.Color) {
	m.color = color
}

material_equals :: proc(m1, m2: Material) -> bool {
	return tuples.color_equals(m1.color, m2.color) &&
		utils.fp_equals(m1.ambient, m2.ambient) &&
		utils.fp_equals(m1.diffuse, m2.diffuse) &&
		utils.fp_equals(m1.specular, m2.specular) &&
		utils.fp_equals(m1.shininess, m2.shininess)
}
