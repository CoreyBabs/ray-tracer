package light

import "src:features/tuples"
import utils "src:utilities"

Material :: struct {
	color: tuples.Color,
	ambient: f64,
	diffuse: f64,
	specular: f64,
	shininess: f64
}

material :: proc(a: f64 = 0.1, d: f64 = 0.9, spec: f64 = 0.9, shine: f64 = 200.0) -> Material {
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
