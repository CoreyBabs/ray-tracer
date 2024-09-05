package tuples


Color :: [3]f32

color :: proc(r, g, b: f32) -> Color {
	return [3]f32{r, g, b}
}

add_colors :: proc(a, b: Color) -> Color {
	return a + b
}

subtract_colors :: proc(a, b: Color) -> Color {
	return a - b
}

color_scalar_multiply :: proc(a: Color, scalar: f32) -> Color {
	return a * scalar
}

color_multiply :: proc(a, b: Color) -> Color {
	return a * b
}

color_equals :: proc(a, b: Color) -> bool {
	return fp_equals(a.r, b.r) && fp_equals(a.g, b.g) && fp_equals(a.b, b.b)
}
