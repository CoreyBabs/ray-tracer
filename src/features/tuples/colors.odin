package tuples

import utils "src:utilities"

Color :: [3]f64

color :: proc(r, g, b: f64) -> Color {
	return [3]f64{r, g, b}
}

add_colors :: proc(a, b: Color) -> Color {
	return a + b
}

subtract_colors :: proc(a, b: Color) -> Color {
	return a - b
}

color_scalar_multiply :: proc(a: Color, scalar: f64) -> Color {
	return a * scalar
}

color_multiply :: proc(a, b: Color) -> Color {
	return a * b
}

color_equals :: proc(a, b: Color) -> bool {
	return utils.fp_equals(a.r, b.r) && utils.fp_equals(a.g, b.g) && utils.fp_equals(a.b, b.b)
}
