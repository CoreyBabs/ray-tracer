package light

import "src:features/patterns"
import "src:features/tuples"
import utils "src:utilities"

Material :: struct {
	color: tuples.Color,
	ambient: f64,
	diffuse: f64,
	specular: f64,
	shininess: f64,
	reflective: f64,
	transparency: f64,
	refractive_index: f64,
	pattern: patterns.Pattern
}

material :: proc(
	a: f64 = 0.1,
	d: f64 = 0.9,
	spec: f64 = 0.9,
	shine: f64 = 200.0,
	reflective: f64 = 0.0,
	transparency: f64 = 0.0,
	refractive_index: f64 = 1.0) -> Material {
	c := tuples.color(1, 1, 1)
	return Material{c, a, d, spec, shine, reflective, transparency, refractive_index, patterns.empty_pattern()}
}

set_material_color :: proc(m: ^Material, color: tuples.Color) {
	m.color = color
}

set_material_pattern :: proc(m: ^Material, pattern: patterns.Pattern) {
	m.pattern = pattern
}

material_equals :: proc(m1, m2: ^Material) -> bool {
	return tuples.color_equals(m1.color, m2.color) &&
		utils.fp_equals(m1.ambient, m2.ambient) &&
		utils.fp_equals(m1.diffuse, m2.diffuse) &&
		utils.fp_equals(m1.specular, m2.specular) &&
		utils.fp_equals(m1.shininess, m2.shininess) &&
		utils.fp_equals(m1.reflective, m2.reflective) &&
		utils.fp_equals(m1.transparency, m2.transparency) &&
		utils.fp_equals(m1.refractive_index, m2.refractive_index) &&
		patterns.pattern_equals(&m1.pattern, &m2.pattern)
}
