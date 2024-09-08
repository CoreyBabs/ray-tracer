package utilities

import "core:math"
import "core:math/linalg"

EPS :: 0.00001

fp_equals :: proc(a, b: f32) -> bool {
	return math.abs(a - b) < EPS
}

fp_zero :: proc(a: f32) -> bool {
	return math.abs(a) < EPS
}

matrix4_equals_f32 :: proc(a, b: matrix[4,4]f32) -> bool {
	c := a - b
	for e in linalg.matrix_flatten(c) {
		if !fp_zero(e) {
			return false
		}
	}
	return true
}

matrix4_can_invert :: proc(a: matrix[4,4]f32) -> bool {
	return linalg.determinant(a) != 0
}

matrix4_identity :: proc() -> matrix[4,4]f32 {
	identity := matrix[4, 4]f32{
		1, 0, 0, 0,
		0, 1, 0, 0,
		0, 0, 1, 0,
		0, 0, 0, 1,
	}

	return identity
}
